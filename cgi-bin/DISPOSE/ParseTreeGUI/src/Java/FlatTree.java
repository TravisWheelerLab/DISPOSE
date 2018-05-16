package Java;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Stack;

import org.abego.treelayout.demo.TextInBox;
import org.abego.treelayout.util.DefaultTreeForTreeLayout;


public class FlatTree {
	
	class Node implements Comparable<Node>{
		String data;
		String hashVal;
		Node parent;
		int weight = 1;
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
				return hashVal;
			}
			
			hashVal = "1" + data;
			ArrayList<Node> sortedChildren = new ArrayList<Node>();
			sortedChildren.addAll(children);
			Collections.sort(sortedChildren);
			
			for (Node n: sortedChildren) {
				hashVal += n.toHash();
			}
			
			return hashVal;
		}
		
		public void updateCounts() {
			if (getChildCount() == 0 && leafless && !hashVal.equals("")) {
				treeCounts.put(hashVal, 1);
			}
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
		        it.remove(); // avoids a ConcurrentModificationException
		    }
		    
		    System.out.println("\nTotal subtrees: " + total);
		}
	}
	
	boolean leafless = false;
	
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
		
		for (int i = 3; i < treeTokens.length; i++) {
//			System.out.println(treeTokens[i]);
		      if (treeTokens[i].length() == 0);
			  else if (treeTokens[i].equals("(")) {
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
		      else if (treeTokens[i].equals(")")) {
		    	  Node curParent = parentStack.pop();
//		    	  TextInBox curParentBox = parentBoxStack.pop();
		    	  if (curParent.children.size() == 1 && !parentStack.isEmpty() && curParent.children.get(0).children.size() != 0) {
		    		  curParent.children.get(0).parent = curParent.parent;
		    		  curParent.parent.children.add(curParent.children.get(0));
		    		  curParent.parent.children.remove(curParent);		  
		    	  }
		    	  
		      }
		      else {
		    	  Node childNode = new Node();
		    	  childNode.parent = parentStack.peek();
		    	  childNode.data = treeTokens[i];
		    	  
//		    	  System.out.println("PARENT: " + childNode.parent.data);
		    
		    	  parentStack.peek().children.add(childNode);
		    	  
//		    	  TextInBox childBox = new TextInBox(childNode.data, 200, 50);
//		    	  treeLayout.addChild(parentBoxStack.peek(), childBox);
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
	
}
