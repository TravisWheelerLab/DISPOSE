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
				size++;
			}
			
			return hashVal;
		}
		
		public void updateCounts() {
			if (getChildCount() == 0 && !hashVal.equals(""))
				treeCounts.put(hashVal, 1);
			else
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
				double TF = root.treeCounts.get(hashVal) /  root.size;
				double IDF = Math.log(1 + (totalFileCount / fileCounts.get(hashVal))) / Math.log(2);
				
				weight = TF * IDF;
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
		String[] treeTokens = lispTree.replace("(", " ( ").replace(")", " ) ").split(" ");
//		for (int i = 0; i < treeTokens.length; i++) {
//			System.out.print(treeTokens[i] + " ");
//		}
//
//		System.out.println("\n");
		
		Node rootNode = new Node();
		rootNode.parent = null;
		rootNode.data = treeTokens[2];
		parentStack.push(rootNode);
		firstNode = rootNode;
		
		TextInBox rootBox = new TextInBox(rootNode.data, 200, 50);
    		treeLayout = new DefaultTreeForTreeLayout<TextInBox>(rootBox);
//    	parentBoxStack.push(rootBox);
		firstBox = rootBox;
		
		boolean insideString = false;
		
		for (int i = 3; i < treeTokens.length; i++) {
//			System.out.println(treeTokens[i]);
		      if (treeTokens[i].length() == 0);
		      
			  else if (treeTokens[i].equals("(")) {
				  if (insideString) {
			    	  	parentStack.peek().children.get(parentStack.peek().getChildCount()-1).data += "(";
			      }
				  else {
				    	  Node parentNode = new Node();
				    	  parentNode.parent = parentStack.peek();
				    	  i++;
				    	  parentNode.data = treeTokens[i];
				    	  parentStack.peek().children.add(parentNode);
				    	  parentStack.push(parentNode);
				    	  
		//		    	  TextInBox parentBox = new TextInBox(parentNode.data, 200, 50);
		//		    	  treeLayout.addChild(parentBoxStack.peek(), parentBox);
		//		    	  parentBoxStack.push(parentBox);
				  }
		      }
		      else if (treeTokens[i].equals(")")) {
			    	  if (insideString) {
			    		  parentStack.peek().children.get(parentStack.peek().getChildCount()-1).data += ")";
			    	  }
			    	  else {
				    	  Node curParent = parentStack.pop();
		//		    	  TextInBox curParentBox = parentBoxStack.pop();
				    	  if (curParent.children.size() == 1 && !parentStack.isEmpty() && curParent.children.get(0).children.size() != 0) {
				    		  curParent.children.get(0).parent = curParent.parent;
				    		  curParent.parent.children.add(curParent.children.get(0));
				    		  curParent.parent.children.remove(curParent);		  
				    	  }
			    	  }
		      }
		      else {
		    	  
		    	  	if (insideString) {
		    	  		parentStack.peek().children.get(parentStack.peek().getChildCount()-1).data += " " + treeTokens[i];
		    	  		if (treeTokens[i].charAt(treeTokens[i].length()-1) == '"' && treeTokens[i+1].equals(")")) {
		    	  			  if (treeTokens[i].length() > 1) {
		    	  				  if (treeTokens[i].charAt(treeTokens[i].length()-2) != '\\')
		    	  					  insideString = false;
		    	  			  }
		    	  			  else
		    	  				  insideString = false;
		    	  		}
		    	  	}  
		    	  	else {
			    	  Node childNode = new Node();
			    	  childNode.parent = parentStack.peek();
			    	  if (childNode.parent.data.equals("expressionName") || childNode.parent.data.equals("variableDeclaratorId"))
			    		  childNode.data = "temp";
			    	  else
			    		  childNode.data = treeTokens[i];
			    	  
			    	  if (treeTokens[i].charAt(0) == '"')
			    	  	insideString = true;
			    	  if (treeTokens[i].charAt(treeTokens[i].length()-1) == '"' && treeTokens[i].length() > 1)
			    		  insideString = false;
			    	  
	//		    	  System.out.println("PARENT: " + childNode.parent.data);
			    
			    	  parentStack.peek().children.add(childNode);
			    	  
	//		    	  TextInBox childBox = new TextInBox(childNode.data, 200, 50);
	//		    	  treeLayout.addChild(parentBoxStack.peek(), childBox);
		    	  	}
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
	
	public void createHashes(Node n) {
		if (n.getChildCount() == 0)
			n.hashVal = n.toHash();
		else {
			for (Node nChild : n.children)
				createHashes(nChild);
			n.hashVal = n.toHash();
		}
	}
	
	public void updateAllCounts(Node n) {
		if (n.getChildCount() == 0)
			n.updateCounts();
		else {
			for (Node nChild : n.children)
				updateAllCounts(nChild);
			n.updateCounts();
		}
	}
	
	public void traverseLeaves(StringBuilder result, Node n) {
		if (n.getChildCount() != 0)
			for (Node c: n.children)
				traverseLeaves(result, c);
		else
			result.append(n.data);
	}
	
	public void replaceExpr(Node n) {
		if (n.getChildCount() == 0)
			return;
		else {
			for (Node nChild : n.children) {
				if (nChild.data.equals("expressionStatement")) {
					StringBuilder result = new StringBuilder();
					traverseLeaves(result, nChild);
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
	
	
	public void allChildren(Node n) {
		if (n.getChildCount() == 0)
			allChildren.add(n);
		else {
			for (Node c: n.children)
				allChildren(c);
			allChildren.add(n);
		}
	}
	
}
