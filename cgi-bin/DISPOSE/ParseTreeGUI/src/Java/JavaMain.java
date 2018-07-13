package Java;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.stream.Stream;

import javax.print.PrintException;
import org.antlr.v4.gui.TreeViewer;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

import Java.FlatTree.Node;

public class JavaMain {

	static ArrayList<FlatTree> allTrees = new ArrayList<FlatTree>();

	public final static double MIN_MATCH = 0.30;
	static JavaMain ref = new JavaMain();

	public static void main(String[] args) throws IOException {

		boolean intFlag = args[0].equals("1");
		String subDir = args[1];
		String sourcesDir = args[2];
		String pastDir = args[3];
		String userFolder = args[4];
		
//		boolean intFlag = true;
//		String subDir = "example";
//		String pastDir = "???";
//		String sourcesDir = "???";
//		String userFolder = "../../../workFiles/nohbodyz@gmail.com";
		
		try (Stream<Path> paths = Files.walk(Paths.get(userFolder + "/" + subDir + "/Java"))) {
		    paths
		        .filter(Files::isRegularFile)
		        .forEach(path -> ref.prepareTree(path));
		}
		
		if (!sourcesDir.equals("???")) {
			try (Stream<Path> paths = Files.walk(Paths.get(userFolder + "/" + sourcesDir + "/Java"))) {
			    paths
			        .filter(Files::isRegularFile)
			        .forEach(path -> ref.prepareTree(path));
			}
		}
		
		if (!pastDir.equals("???")) {
			try (Stream<Path> paths = Files.walk(Paths.get(userFolder + "/" + pastDir + "/Java"))) {
			    paths
			        .filter(Files::isRegularFile)
			        .forEach(path -> ref.prepareTree(path));
			}
		}

//		try (Stream<Path> paths = Files.walk(Paths.get("./test"))) {
//			paths
//			.filter(Files::isRegularFile)
//			.forEach(JavaMain::prepareTree);
//		}


		// Count files that contain a particular tree 
		HashMap<String, Integer> fileCounts = new HashMap<String, Integer>();

		for (FlatTree ft: allTrees) {
			Iterator<Entry<String, Integer>> it = ft.firstNode.treeCounts.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, Integer> pair = (Map.Entry<String, Integer>) it.next();
				if (fileCounts.get(pair.getKey()) == null)
					fileCounts.put(pair.getKey(), 0);
				fileCounts.put(pair.getKey(), fileCounts.get(pair.getKey())+1);
			}
		}


		List<String> stopWords = Arrays.asList(")", "(", "[", "]", "{", "}", ";", ",");

		for (FlatTree ft: allTrees) {
			ft.assignWeights(ft.firstNode, stopWords, fileCounts, ft.firstNode, allTrees.size());
		}

		ArrayList<PairValue> myScores = new ArrayList<PairValue>(); 

		HashMap<String, Double> scoreHistory = new HashMap<String, Double>();
		HashMap<String, HashMap<String, Double>> scoreHistory2 = new HashMap<String, HashMap<String, Double>>();


		FlatTree tree1, tree2;
		//		long startTime = System.nanoTime();
		
		PairValue minScore = new PairValue("aaa", "bbb", 0);
		myScores.add(minScore);

		for (int i=0; i<allTrees.size(); i++) {
			// TODO: Remove = test case for same comparison
			for (int j=0; j < i; j++) {
				tree1 = allTrees.get(i);
				tree2 = allTrees.get(j);

				if (tree1.fileDirSouce.equals(subDir) || tree2.fileDirSouce.equals(subDir)) {
					System.out.println(tree1.subSource + " " + tree2.subSource);
					if ((tree1.subSource.equals(tree2.subSource) && intFlag) 
							|| !tree1.subSource.equals(tree2.subSource)) {
						if (tree1.allChildren.size() == 0)
							tree1.allChildren(tree1.firstNode);
						if (tree2.allChildren.size() == 0)
							tree2.allChildren(tree2.firstNode);
		
						PairValue next = new PairValue(tree1.originFile, tree2.originFile, 0);
						System.out.println("Calculating: " + tree1.originFile + " " + tree2.originFile);
						//next.score = next.assignSimilarity(tree1, tree2, scoreHistory, false);
						next.score = next.assignSimilarity2(tree1, tree2, false);
						//next.score = next.assignSimilarity4(tree1, tree2, scoreHistory2, false);
		
						if (!Double.isNaN(next.score)) {
							if (next.score > MIN_MATCH) {
								if (myScores.size() >= 250) {
									if (next.score > minScore.score) {
										myScores.add(next);
										myScores.remove(minScore);
										Collections.sort(myScores);
										minScore = myScores.get(myScores.size()-1);
									}
								}
								else {
									myScores.add(next);
									Collections.sort(myScores);
									minScore = myScores.get(myScores.size()-1);
								}
							}
							else
								next = null;
						}
					}
				}
			}
		}

		//		long endTime = System.nanoTime();
		//		
		//		System.out.println("TEST TIME: " + (endTime-startTime)/1000000000.0 + "\n");

		if (myScores.size() < 250) {
			myScores.remove(minScore);
		}

		Collections.sort(myScores);
		
		int reportLim = Math.min(250, myScores.size());
		
		System.out.println("BLAHBLAH " + reportLim);

		for (int i=0; i<reportLim; i++) {
			System.out.println(myScores.get(i).file1 + " " + myScores.get(i).file2 + " " + myScores.get(i).score);
			myScores.get(i).makeMatchFile(userFolder);
			//myScores.get(i).makeMatchFile(".");
		}
	}
	
	String fileName;
	String[] filePathSplit;
	String fileDirSource;
	String subSource;
	String[] subSourceSplit;
	
	static Java8Lexer lexer;
	static TokenStream tokenStream;
	static Java8Parser parser;
	static ParseTree tree;
	
	static List<? extends Token> myTokens;
	static Vocabulary myVocab;
	
	ArrayList<Integer> startPos = new ArrayList<Integer>();
	ArrayList<Integer> endPos = new ArrayList<Integer>();
	ArrayList<Integer> line = new ArrayList<Integer>();
	
	Token myToken;
	String[] remFlags = new String[] {"LINE_COMMENT", "COMMENT", "WS"};
	
	Node myNode;
	FlatTree myTree;
	ArrayList<Node> nodesList = new ArrayList<Node>(1000);

	public void prepareTree(Path filePath) {

		fileName = filePath.toString();
		filePathSplit = fileName.split("/");
		fileDirSource = filePathSplit[5];
		subSource = filePathSplit[7];
		subSourceSplit = subSource.split("_");
		subSource = subSourceSplit[0] + "_" + subSourceSplit[1];
		System.out.println("Creating tree: " + fileName);

//		try {

			//prepare token stream
			CharStream stream = null;
			try {
				stream = CharStreams.fromFileName(fileName);
			} catch (IOException e) {
				e.printStackTrace();
			}

			// Prepare parser and lexer 
			lexer = new Java8Lexer(stream);
			tokenStream = new CommonTokenStream(lexer);
			parser = new Java8Parser(tokenStream);
			tree = parser.compilationUnit();

			lexer.reset();
			myTokens = lexer.getAllTokens();
			myVocab = lexer.getVocabulary();
			
			System.out.println(myTokens.size() + " " + startPos.size());
			
			while (startPos.size() < myTokens.size()) {
				startPos.add(-1);
				endPos.add(-1);
				line.add(-1);
			}
			
			System.out.println(startPos.size() + " " + myTokens.size());
			
			int nodeCount = 1;

			// Store position information for each token in stream
			// Tokens are retrieved in the same order as an in-order leaf traversal
			for (int i = 0; i < myTokens.size(); i++) {
				myToken = myTokens.get(i);
				if (Arrays.asList(remFlags).contains(myVocab.getSymbolicName(myToken.getType())) == false) {
					startPos.set(i, myToken.getStartIndex());
					endPos.set(i, myToken.getStopIndex());
					line.set(i, myToken.getLine());
					//            	System.out.println(myToken.getStartIndex() + ":" + myToken.getStopIndex() + " " + myToken.getLine()
					//	            		+ " " + myToken.getText() + " " + myVocab.getSymbolicName(myToken.getType()));
					nodeCount++;
				}
				else {
					startPos.set(i, -1);
					endPos.set(i, -1);
					line.set(i, -1);
				}
			}


			// Show AST in console
			// System.out.println(tree.toStringTree(parser) + "\n");

			// Flatten the ANTLR generated parse tree
			// FlatTree myLeaflessTree = new FlatTree(tree.toStringTree(parser)); 
			// myLeaflessTree.leafless = true;
			myTree = new FlatTree(tree.toStringTree(parser));
			myTree.originFile = fileName;
			myTree.fileDirSouce = fileDirSource;
			myTree.subSource = subSource;

			// Keep information on where in the source code the tree represents
			while (nodesList.size() < nodeCount) {
				nodesList.add(myTree.new Node());
			}
			myTree.traverseLeavesList(nodesList, myTree.firstNode);

			for (int i = 0; i < nodeCount; i++) {
				if (startPos.get(i) != -1) {
					myNode = nodesList.get(i);
					myNode.startPos = startPos.get(i);
					myNode.endPos = endPos.get(i);
					myNode.startLine = line.get(i);
					myNode.endLine = line.get(i);
				}
				//System.out.println(myNode.startPos + ":" + myNode.endPos + " " + myNode.startLine + " " + myNode.endLine);
			}
			
			myTree.assignPositions(myTree.firstNode);

			// Replace the subtree of an expressionStatement with in-order
			// traversal string of leaves
			// myTree.replaceExpr(myTree.firstNode);

			// Create image representations of the trees
			//generateAntlrTreeImage(parser, tree, fileName.substring(fileName.lastIndexOf('/')+1, fileName.lastIndexOf('.')) + "_antlr.png");
			//generateFlatTreeImage(parser, myTree, "./trees/" + fileName.substring(fileName.lastIndexOf('/')+1, fileName.lastIndexOf('.')) + ".png");

			// Create hash values to count subtrees
			// Note: children are no longer in-order afterwards
			myTree.createHashes(myTree.firstNode);

			// Keep track of how often a subtree appears below every node
			myTree.updateAllCounts(myTree.firstNode);
			//myTree.firstNode.printCounts();

			allTrees.add(myTree);

//		} catch (Exception e) {
//			System.out.println("FAILED");
//		}
	}

	public static void generateFlatTreeImage(Java8Parser myParser, FlatTree myTree, String fileName) {

		System.out.println("Generating flat tree image: " + fileName);
		FlatTreeViewer viewr2 = new FlatTreeViewer(Arrays.asList(
				myParser.getRuleNames()),myTree);

		try {
			viewr2.save(fileName);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (PrintException e) {
			e.printStackTrace();
		}
	}

	public static void generateAntlrTreeImage(Java8Parser myParser, ParseTree antlrTree, String fileName) {

		System.out.println("Generating ANTLR tree image: " + fileName);
		TreeViewer viewr = new TreeViewer(Arrays.asList(
				myParser.getRuleNames()),antlrTree);

		try {
			viewr.save(fileName);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (PrintException e) {
			e.printStackTrace();
		}
	}
}