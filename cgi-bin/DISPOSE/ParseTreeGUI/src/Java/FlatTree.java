package Java;

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



public class FlatTree {

	class Node implements Comparable<Node>{
		String data;
		String hashVal;
		int size;
		Node parent;
		double weight = 1;
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
			if (hashVal != null)
				return hashVal;
			if (getChildCount() == 0) {
				if (!leafless)
					hashVal = "0" + data;
				else
					hashVal = "";
				size = 1;
				return hashVal;
			}

			size = 1;

			hashVal = "1" + data;
			ArrayList<Node> sortedChildren = new ArrayList<Node>();
			sortedChildren.addAll(children);
			Collections.sort(sortedChildren);

			for (Node n: sortedChildren) {
				hashVal += n.toHash();
				size += n.size;
			}

			return hashVal;
		}

		public void updateCounts() {
			if (getChildCount() != 0 && !hashVal.equals("")) {
				for (Node n: children) {
					Iterator<Entry<String, Integer>> it = n.treeCounts.entrySet().iterator();
					while (it.hasNext()) {
						Map.Entry<String, Integer> pair = (Map.Entry<String, Integer>) it.next();
						if (treeCounts.get(pair.getKey()) == null)
							treeCounts.put(pair.getKey(), 0);
						treeCounts.put(pair.getKey(), treeCounts.get(pair.getKey())+pair.getValue());
						it.remove(); // avoids a ConcurrentModificationException
					}
				}
			}
			// Include this node in count
			if (treeCounts.get(hashVal) == null && !hashVal.equals(""))
				treeCounts.put(hashVal, 1);
			else if (!hashVal.equals(""))
				treeCounts.put(hashVal, treeCounts.get(hashVal) + 1);
			
		}

		@Override
		public int compareTo(Node other) {
			return hashVal.compareTo(other.hashVal);
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

		public void assignWeight(List<String> stopWords, HashMap<String, Integer> fileCounts, Node root, int totalFileCount) {
			if (stopWords.contains(data)) {
				weight = 0;
			}
			else {
				// double TF = (double) root.treeCounts.get(hashVal) /  root.size;
				// double ITF = Math.log(1 + ((double) root.size / root.treeCounts.get(hashVal))) / Math.log(2);
				double ITF = Math.log((double) root.size / root.treeCounts.get(hashVal)) / Math.log (root.size);
				double IDF = Math.log(1 + ((double) totalFileCount / fileCounts.get(hashVal))) / Math.log(2);
				// double IDF = Math.log((double) totalFileCount / fileCounts.get(hashVal)) / Math.log(totalFileCount);

				if (hashVal.equals
						("0\"Scribbleblah()blah\""))
					System.out.println("WEIGHT: " + root.treeCounts.get(hashVal) + " " + root.size
							+ " " + totalFileCount + " " + fileCounts.get(hashVal));
				// weight = Math.log(TF * IDF);
				weight = Math.log(ITF * IDF);
			}
		}
		
		public void assignPosition() {
			startPos = children.get(0).startPos;
			endPos = children.get(0).endPos;
			startLine = children.get(0).startLine;
			endLine = startLine;
			
			for (Node c: children) {
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

	boolean leafless = false;

	String originFile;
	ArrayList<Node> allChildren = new ArrayList<Node>();

	Node firstNode;
	TextInBox firstBox;

	Stack<Node> parentStack = new Stack<Node>();
	Stack<TextInBox> parentBoxStack = new Stack<TextInBox>();
	DefaultTreeForTreeLayout<TextInBox> treeLayout;

	public FlatTree (String lispTree) {
		String[] treeTokens = lispTree.split(" ");
		//		for (int i = 3; i < treeTokens.length-1; i++) {
		//			System.out.print(treeTokens[i] + " ");
		//			System.out.println(treeTokens[i-1] + treeTokens[i]  + treeTokens[i+1]);
		//		}

		//System.out.println("\n");

		Node rootNode = new Node();
		rootNode.parent = null;
		rootNode.data = treeTokens[0].substring(1);
		parentStack.push(rootNode);
		firstNode = rootNode;

		TextInBox rootBox = new TextInBox(rootNode.data, 200, 50);
		treeLayout = new DefaultTreeForTreeLayout<TextInBox>(rootBox);
		//    	parentBoxStack.push(rootBox);
		firstBox = rootBox;


		String literal = "";
		boolean inString = false;

		for (int i = 1; i < treeTokens.length; i++) {
			//System.out.println(treeTokens[i]);

			int lastParen = -1;
			
			if (treeTokens[i].length() == 0 || parentStack.isEmpty())
				continue;
			
			if (treeTokens[i].charAt(treeTokens[i].length()-1) == ')')
				lastParen = treeTokens[i].length() - 1;

			while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
				lastParen--;
			}

			lastParen++;


			if (parentStack.peek().data.equals("literal")) {
				//System.out.println(lastParen);
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
					Node curParent = parentStack.peek();

					Node childNode = new Node();
					literal += treeTokens[i].substring(0, lastParen);
					childNode.data = literal;
					//System.out.println("LITERAL: " + literal);
					literal = "";
					childNode.parent = curParent;

					curParent.children.add(childNode);
					
					lastParen = treeTokens[i].length() -1;

					while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
						//System.out.println("POP: " + parentStack.pop().data);
						Node nextParent = parentStack.pop();
						//System.out.println("POP: " + nextParent.data + " " + nextParent.children.size() + " " + nextParent.children.get(0).children.size());
						if (!parentStack.isEmpty()) {
							if (nextParent.children.size() == 1 && nextParent.children.get(0).children.size() != 0) {
								nextParent.children.get(0).parent = nextParent.parent.parent;
								nextParent.parent.children.add(nextParent.children.get(0));
								nextParent.parent.children.remove(nextParent);
								
								//System.out.println("Replacing " + nextParent.data + " " + nextParent.children.size() + " with " + nextParent.children.get(0).data + " " + nextParent.children.get(0).children.size());
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

				Node curParent = parentStack.peek();
				
				Node childNode = new Node();
//				if (curParent.data.equals("variableDeclaratorId")|| curParent.data.equals("expressionName"))
//					childNode.data = "temp";
//				else
					childNode.data = treeTokens[i].substring(0, lastParen);
				childNode.parent = curParent;

				curParent.children.add(childNode);
				
				lastParen = treeTokens[i].length() -1;

				while (lastParen > 0 && treeTokens[i].charAt(lastParen) == ')') {
					//System.out.println("POP: " + parentStack.pop().data);
					Node nextParent = parentStack.pop();
					//System.out.println("POP: " + nextParent.data + " " + nextParent.children.size() + " " + nextParent.children.get(0).children.size());
					if (!parentStack.isEmpty()) {
						if (nextParent.children.size() == 1 && nextParent.children.get(0).children.size() != 0) {
							nextParent.children.get(0).parent = nextParent.parent.parent;
							nextParent.parent.children.add(nextParent.children.get(0));
							nextParent.parent.children.remove(nextParent);
							
							//System.out.println("Replacing " + nextParent.data + " " + nextParent.children.size() + " with " + nextParent.children.get(0).data + " " + nextParent.children.get(0).children.size());
						}
					}
					lastParen--;
				}
				

			}

			else {
				Node childNode = new Node();
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

		while (!nodeStack.isEmpty()) {
			Node curParent = nodeStack.pop();
			TextInBox curParentBox = boxStack.pop();
			for (Node n: curParent.children) {
				TextInBox childBox = new TextInBox(n.data, 200, 50);
				treeLayout.addChild(curParentBox, childBox);
				//				System.out.println(n.data + " " + nodeStack.peek().data);
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

		while (!nodeStack.isEmpty()) {
			Node curParent = nodeStack.pop();
			for (Node n: curParent.children) {
				if (!leafless || n.children.size() != 0) {
					treeLayout.addChild(curParent, n);
					//					System.out.println(n.data + " " + nodeStack.peek().data);
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
			n.hashVal = n.toHash();
		else {
			for (Node nChild : n.children)
				createHashes(nChild);
			n.hashVal = n.toHash();
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
	public void traverseLeavesList(ArrayList<Node> result, Node n) {
		if (n.getChildCount() != 0)
			for (Node c: n.children)
				traverseLeavesList(result, c);
		else
			result.add(n);
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
	public void assignWeights(Node n, List<String> stopWords, HashMap<String, Integer> fileCounts, Node root, int totalFileCount) {
		if (n.getChildCount() == 0) {
			n.assignWeight(stopWords, fileCounts, root, totalFileCount);
		}
		else {
			for (Node nChild : n.children)
				assignWeights(nChild, stopWords, fileCounts, root, totalFileCount);
			n.assignWeight(stopWords, fileCounts, root, totalFileCount);
		}
	}

	// Create the set of all children subtrees within the tree
	public void allChildren(Node n) {
		if (n.getChildCount() == 0)
			allChildren.add(n);
		else {
			for (Node c: n.children)
				allChildren(c);
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

}
