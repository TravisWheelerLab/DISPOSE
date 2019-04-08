package Java;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Stack;

import org.abego.treelayout.demo.TextInBox;
import org.abego.treelayout.util.DefaultTreeForTreeLayout;

import org.apache.commons.text.StringEscapeUtils;


public class FlatTree {
	class Node implements Comparable<Node>{
		int id;
		String data;
		StringBuilder hashVal = new StringBuilder();
		int size;
		Node parent;
		double weight = 1;
		double freqTerm_g, IDF_g;
		ArrayList<Node> children = new ArrayList<Node>();
		HashMap<String, Integer> treeCounts = new HashMap<String, Integer>();

		int startPos;
		int endPos;
		int startLine;
		int endLine;

		public int getChildCount() {
			return children.size();
		}
		public Node getChild(int i) {
			return children.get(i);
		}

		public String toHash() {
			if (!hashVal.toString().equals(""))
				return hashVal.toString();
			if (getChildCount() == 0) {
				if (!leafless)
					hashVal.append("0").append(data);
				size = 1;
				return hashVal.toString();
			}

			size = 1;

			hashVal.append("1").append(data);
			
			Collections.sort(children);
			
			for (Node n: children) {
				hashVal.append(n.toHash());
				size += n.size;
			}

			return hashVal.toString();
		}
		
		Iterator<Entry<String, Integer>> it;
		Map.Entry<String, Integer> pair;

		public void updateCounts() {
			if (getChildCount() != 0 && !hashVal.toString().equals("")) {
				for (Node n: children) {
					it = n.treeCounts.entrySet().iterator();
					while (it.hasNext()) {
						pair = (Map.Entry<String, Integer>) it.next();
						if (treeCounts.get(pair.getKey()) == null)
							treeCounts.put(pair.getKey(), 0);
						treeCounts.put(pair.getKey(), treeCounts.get(pair.getKey())+pair.getValue());
						it.remove(); // avoids a ConcurrentModificationException
					}
				}
			}
			// Include this node in count
			if (treeCounts.get(hashVal.toString()) == null && !hashVal.toString().equals(""))
				treeCounts.put(hashVal.toString(), 1);
			else if (!hashVal.toString().equals(""))
				treeCounts.put(hashVal.toString(), treeCounts.get(hashVal.toString()) + 1);
			
		}

		@Override
		public int compareTo(Node other) {
			return hashVal.toString().compareTo(other.hashVal.toString());
		}

		public void printCounts() {
			int total = 0;

			Iterator<Entry<String, Integer>> it = treeCounts.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, Integer> pair = (Map.Entry<String, Integer>) it.next();
				System.out.println(pair.getKey() + " : " + pair.getValue());
				total += pair.getValue();
			}

			System.out.println("\nTotal subtrees: " + total);
		}

		public void assignWeight(List<String> stopWords, HashMap<String, Integer> fileCounts, Node root, int totalFileCount, boolean useITF) {
			if (stopWords.contains(data)) {
				weight = 0;
			}
			else {
				double freqTerm;
				double IDF;
				
				if (useITF) {
					freqTerm = Math.log(1 + root.size / (double) root.treeCounts.get(hashVal.toString())) / Math.log(root.size + 1);
					IDF = Math.log(1 + (double) totalFileCount / fileCounts.get(hashVal.toString())) / Math.log(totalFileCount + 1);
				}
				else {
					freqTerm = (double) root.treeCounts.get(hashVal.toString()) /  root.size;
					IDF = Math.log(1 + ((double) totalFileCount / fileCounts.get(hashVal.toString()))) / Math.log(2);
				}
				
//				if (hashVal.equals
//						("0\"Scribbleblah()blah\""))
//					System.out.println("WEIGHT: " + root.treeCounts.get(hashVal) + " " + root.size
//							+ " " + totalFileCount + " " + fileCounts.get(hashVal));
				weight = freqTerm * IDF;
				freqTerm_g = freqTerm;
				IDF_g = IDF;
			}
		}
		
		public void assignPosition() {
			startPos = children.get(0).startPos;
			endPos = children.get(0).endPos;
			startLine = children.get(0).startLine;
			endLine = startLine;
			
			for (Node c: children) {
				if (c.data.equals("<EOF>"))
					continue;
				if (c.startPos < startPos)
					startPos = c.startPos;
				if (c.endPos > endPos)
					endPos = c.endPos;
				if (c.startLine < startLine)
					startLine = c.startLine;
				if (c.endLine > endLine)
					endLine = c.endLine;
			}
			
		}

		public boolean isLeaf() {
			if (hashVal.charAt(0) == '0')
				return true;
			else
				return false;
		}

		public boolean isExpr() {
			if (parent == null)
				return false;
			if (parent.data.equals("expressionStatement"))
				return true;
			else
				return false;
		}
	}
	
	int nodeCount = 0;

	boolean leafless = false;
	boolean treeMade = false;

	String originFile;
	String fileDirSouce;
	String subSource;
	ArrayList<Node> allChildren = new ArrayList<Node>();

	Node firstNode;
	TextInBox firstBox;

	Stack<Node> parentStack = new Stack<Node>();
	Stack<TextInBox> parentBoxStack;
	DefaultTreeForTreeLayout<TextInBox> treeLayout;

	public FlatTree (String lispTree) {
		String[] treeTokens = lispTree.split(" ");

		Node rootNode = new Node();
		rootNode.parent = null;
		rootNode.data = treeTokens[0].substring(1);
		parentStack.push(rootNode);
		firstNode = rootNode;

		parentBoxStack = new Stack<TextInBox>();
		firstBox = new TextInBox(rootNode.data, 200, 50);
		treeLayout = new DefaultTreeForTreeLayout<TextInBox>(firstBox);

		String literal = "";
		boolean inString = false;
		
		Node curParent;
		Node nextParent;
		
		int lastParen;
		int nodeId = 0;

		for (int i = 1; i < treeTokens.length; i++) {
			lastParen = -1;
			
			if (treeTokens[i].length() == 0 || parentStack.isEmpty())
				continue;
			
			if (treeTokens[i].charAt(treeTokens[i].length()-1) == ')')
				lastParen = treeTokens[i].length() - 1;

			while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
				lastParen--;
			}

			lastParen++;
			
			


			if (parentStack.peek().data.equals("literal")) {
				if (treeTokens[i].charAt(0) == '\"' || treeTokens[i].charAt(0) == '\'') {
					inString = true;
				}
				
				if (inString) {
					if (lastParen != 0)
						if (treeTokens[i].charAt(lastParen-1) == '\'' || treeTokens[i].charAt(lastParen-1) == '\"')
							inString = false;
						
					if (inString)
						literal += treeTokens[i];
				}
				
				if (!inString) {
					curParent = parentStack.peek();

					Node childNode = new Node();
					literal += treeTokens[i].substring(0, lastParen);
					childNode.data = literal;
					literal = "";
					childNode.parent = curParent;

					curParent.children.add(childNode);
					
					lastParen = treeTokens[i].length() -1;

					while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
						nextParent = parentStack.pop();
						if (!parentStack.isEmpty()) {
							if (nextParent.children.size() == 1 && nextParent.children.get(0).children.size() != 0) {
								nextParent.children.get(0).parent = nextParent.parent.parent;
								nextParent.parent.children.add(nextParent.children.get(0));
								nextParent.parent.children.remove(nextParent);
							}
						}
						lastParen--;
					}
				}
			}

			else if (treeTokens[i].charAt(0) == '(') {
				Node childNode = new Node();
				if (treeTokens[i].length() > 1)
					childNode.data = treeTokens[i].substring(1);
				else
					childNode.data = treeTokens[i];
				childNode.parent = parentStack.peek();

				parentStack.peek().children.add(childNode);

				if (!treeTokens[i].equals("("))
					parentStack.push(childNode);
			}
			else if (treeTokens[i].charAt(treeTokens[i].length()-1) == ')') {

				curParent = parentStack.peek();
				
				Node childNode = new Node();
				childNode.data = treeTokens[i].substring(0, lastParen);
				childNode.parent = curParent;

				curParent.children.add(childNode);
				
				lastParen = treeTokens[i].length() -1;

				while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
					nextParent = parentStack.pop();
					if (!parentStack.isEmpty()) {
						if (nextParent.children.size() == 1 && nextParent.children.get(0).children.size() != 0) {
							nextParent.children.get(0).parent = nextParent.parent.parent;
							nextParent.parent.children.add(nextParent.children.get(0));
							nextParent.parent.children.remove(nextParent);
						}
					}
					lastParen--;
				}
			}

			else {
				Node childNode = new Node();
				childNode.id = nodeId;
				nodeId++;
				childNode.data = treeTokens[i];
				childNode.parent = parentStack.peek();

				parentStack.peek().children.add(childNode);
			}
		}
	}

	public DefaultTreeForTreeLayout<TextInBox> toTree() {

		Stack<Node> nodeStack = new Stack<Node>();
		Stack<TextInBox> boxStack = new Stack<TextInBox>();

		nodeStack.push(firstNode);
		boxStack.push(firstBox);
		
		Node curParent;
		TextInBox curParentBox;

		while (!nodeStack.isEmpty()) {
			curParent = nodeStack.pop();
			curParentBox = boxStack.pop();
			for (Node n: curParent.children) {
				TextInBox childBox = new TextInBox(n.data, 200, 50);
				treeLayout.addChild(curParentBox, childBox);
				
				if (n.children.size() > 0) {
					nodeStack.push(n);
					boxStack.push(childBox);
				}
			}
		}


		return treeLayout;
	}

	public DefaultTreeForTreeLayout<Node> toNodeTree() {

		DefaultTreeForTreeLayout<Node> treeLayout = new DefaultTreeForTreeLayout<Node>(firstNode);

		Stack<Node> nodeStack = new Stack<Node>();

		nodeStack.push(firstNode);
		
		Node curParent;

		while (!nodeStack.isEmpty()) {
			curParent = nodeStack.pop();
			for (Node n: curParent.children) {
				if (!leafless || n.children.size() != 0) {
					treeLayout.addChild(curParent, n);
					
					if (n.children.size() > 0) {
						nodeStack.push(n);
					}
				}
			}
		}
		return treeLayout;
	}

	public int getChildCount() {
		return firstNode.children.size();
	}

	public Node getChild(int i) {
		return firstNode.children.get(i);
	}

	// Create every hash value representation of a tree
	// (e.g.) alphabetical sorting of all the children's hashes
	public void createHashes(Node n) {
		if (n.getChildCount() == 0)
			n.toHash();
		else {
			for (Node nChild : n.children)
				createHashes(nChild);
			n.toHash();
		}
	}

	// Update every node's subtree counts
	public void updateAllCounts(Node n) {
		if (n.getChildCount() == 0)
			n.updateCounts();
		else {
			for (Node nChild : n.children)
				updateAllCounts(nChild);
			n.updateCounts();
		}
	}

	// Build the in-order traversal string of a tree's leaves
	public void traverseLeavesString(StringBuilder result, Node n) {
		if (n.getChildCount() != 0)
			for (Node c: n.children)
				traverseLeavesString(result, c);
		else
			result.append(n.data);
	}
	
	// Build the in-order traversal list of a tree's leaves
	public int checkIndex = -1;
	
	public void traverseLeavesList(ArrayList<Node> result, Node n) {
		if (n.getChildCount() != 0)
			for (Node c: n.children)
				traverseLeavesList(result, c);
		else {
			checkIndex++;
			result.set(checkIndex, n);
		}
	}

	// Remove any subtree that is rooted by as an expr statement
	// and replace it with the in-order traversal string of its
	// leaves
	public void replaceExpr(Node n) {
		if (n.getChildCount() == 0)
			return;
		else {
			for (Node nChild : n.children) {
				if (nChild.data.equals("expressionStatement")) {
					StringBuilder result = new StringBuilder();
					traverseLeavesString(result, nChild);
					Node newChild = new Node();
					newChild.parent = nChild;
					newChild.data = result.toString();
					nChild.children = new ArrayList<Node>();
					nChild.children.add(newChild);
				}
				else
					replaceExpr(nChild);
			}
		}
	}

	// Assign the node-by-node weight starting at the leaves
	public void assignWeights(Node n, List<String> stopWords, HashMap<String, Integer> fileCounts, Node root, int totalFileCount, boolean useITF) {
		if (n.getChildCount() == 0) {
			n.assignWeight(stopWords, fileCounts, root, totalFileCount, useITF);
		}
		else {
			for (Node nChild : n.children)
				assignWeights(nChild, stopWords, fileCounts, root, totalFileCount, useITF);
			n.assignWeight(stopWords, fileCounts, root, totalFileCount, useITF);
		}
	}

	// Create the set of all children subtrees within the tree
	// Also, assign the ids for all children
	public void allChildren(Node n) {
		if (n.getChildCount() == 0) {
			n.id = nodeCount;
			nodeCount++;

			allChildren.add(n);
		}
		else {
			for (Node c: n.children)
				allChildren(c);
			
			n.id = nodeCount;
			nodeCount++;
			allChildren.add(n);
		}
	}
	
	public void assignPositions(Node n) {
		if (n.getChildCount() != 0) {
			for (Node nChild : n.children)
				assignPositions(nChild);
			n.assignPosition();
		}
	}
	
	public void createJavascriptTree(Node n, String userFolder) throws IOException {
		File treeFile = new File(userFolder + "/trees/" + originFile.substring(originFile.lastIndexOf(File.separator) + 1, originFile.lastIndexOf('.')) + ".txt");
		FileWriter myWriter = new FileWriter(treeFile);
		
		String escapedStr = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(n.data));
		String escapedStr2 = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(n.hashVal.toString()));
		
		myWriter.write("[{" + "\"name\":\"" + escapedStr + "\"," +
						"\"nid\": " + n.id + "," +
						"\"hashVal\": \"" + escapedStr2 + "\"," +
						"\"start\": " + n.startLine + "," +
						"\"end\": " + n.endLine + ", " +
						"\"weight\": \"" + 
						Math.round(n.freqTerm_g*10000.0)/10000.0 + " * " + 
						Math.round(n.IDF_g*10000.0)/10000.0 + " = " + 
						Math.round(n.weight*10000.0)/10000.0 + "\"");
		
		StringBuilder childString = new StringBuilder();
		
		createChildArrayJS(n, childString);
		
		myWriter.write(childString.toString() + "]");
		
		myWriter.close();
		
		treeMade = true;
	}
	
	public void createChildArrayJS(Node n, StringBuilder myString) {
		if (n.getChildCount() == 0) {
			myString.append("}");
		}
		else {
			myString.append(",\"children\":[");
			int c_size = n.children.size();
			int count = 0;
			for (Node c:n.children) {
				count++;
				String escapedStr = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(c.data));
				String escapedStr2 = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(c.hashVal.toString()));
				
//				System.out.println(c.id);
				
				myString.append("{\"name\":\"" + escapedStr + "\", ");
				myString.append("\"nid\": " + c.id + ", ");
				myString.append("\"hashVal\": \"" + escapedStr2 + "\", ");
				myString.append("\"start\": " + c.startLine + ", ");
				myString.append("\"end\": " + c.endLine + ", ");
				myString.append("\"weight\": \"" + 
						Math.round(c.freqTerm_g*10000.0)/10000.0 + " * " +
						Math.round(c.IDF_g*10000.0)/10000.0 + " = " + 
						Math.round(c.weight*10000.0)/10000.0 + "\"");
				createChildArrayJS(c,myString);
				if (count < c_size)
					myString.append(",");
			}
			myString.append("]}");
		}
	}

}
