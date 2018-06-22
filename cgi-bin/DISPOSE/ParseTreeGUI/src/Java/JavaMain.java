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

	public static void main(String[] args) throws IOException {

				String subDir = args[0];
				String userFolder = args[1];


				try (Stream<Path> paths = Files.walk(Paths.get(userFolder + "/" + subDir + "/Java"))) {
				    paths
				        .filter(Files::isRegularFile)
				        .forEach(JavaMain::prepareTree);
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

		for (int i=0; i<allTrees.size(); i++) {
			// TODO: Remove = test case for same comparison
			for (int j=0; j < i; j++) {
				tree1 = allTrees.get(i);
				tree2 = allTrees.get(j);

				if (tree1.allChildren.size() == 0)
					tree1.allChildren(tree1.firstNode);
				if (tree2.allChildren.size() == 0)
					tree2.allChildren(tree2.firstNode);

				PairValue next = new PairValue(tree1.originFile, tree2.originFile, 0);
				System.out.println("Calculating: " + tree1.originFile + " " + tree2.originFile);
				//next.score = next.assignSimilarity(tree1, tree2, scoreHistory, false);
				next.score = next.assignSimilarity2(tree1, tree2, false);
				//next.score = next.assignSimilarity4(tree1, tree2, scoreHistory2, false);

				if (!Double.isNaN(next.score))
					myScores.add(next);
			}
		}

		//		long endTime = System.nanoTime();
		//		
		//		System.out.println("TEST TIME: " + (endTime-startTime)/1000000000.0 + "\n");

		Collections.sort(myScores);

		int reportLim = Math.min(250, myScores.size());

		for (int i=0; i<reportLim; i++) {
			System.out.println(myScores.get(i).file1 + " " + myScores.get(i).file2 + " " + myScores.get(i).score);
			myScores.get(i).makeMatchFile(userFolder);
			//myScores.get(i).makeMatchFile(".");
		}
	}

	public static void prepareTree(Path filePath) {


		String fileName = filePath.toString();
		System.out.println("Creating tree: " + fileName);

		try {

			//prepare token stream
			CharStream stream = null;
			try {
				stream = CharStreams.fromFileName(fileName);
			} catch (IOException e) {
				e.printStackTrace();
			}

			// Prepare parser and lexer
			Java8Lexer lexer  = new Java8Lexer(stream);

			TokenStream tokenStream = new CommonTokenStream(lexer);
			Java8Parser parser = new Java8Parser(tokenStream);
			ParseTree tree = parser.compilationUnit();

			lexer.reset();
			List<? extends Token> myTokens = lexer.getAllTokens();
			Vocabulary myVocab = lexer.getVocabulary();

			ArrayList<Integer> startPos = new ArrayList<Integer>();
			ArrayList<Integer> endPos = new ArrayList<Integer>();
			ArrayList<Integer> line = new ArrayList<Integer>();

			for (int i = 0; i < myTokens.size(); i++) {
				Token myToken = myTokens.get(i);
				String[] remFlags = new String[] {"LINE_COMMENT", "COMMENT", "WS"};
				if (Arrays.asList(remFlags).contains(myVocab.getSymbolicName(myToken.getType())) == false) {
					startPos.add(myToken.getStartIndex());
					endPos.add(myToken.getStopIndex());
					line.add(myToken.getLine());
					//            	System.out.println(myToken.getStartIndex() + ":" + myToken.getStopIndex() + " " + myToken.getLine()
					//	            		+ " " + myToken.getText() + " " + myVocab.getSymbolicName(myToken.getType()));
				}
			}


			// Show AST in console
			System.out.println(tree.toStringTree(parser) + "\n");

			// Flatten the ANTLR generated parse tree
			// FlatTree myLeaflessTree = new FlatTree(tree.toStringTree(parser));
			// myLeaflessTree.leafless = true;
			FlatTree myTree = new FlatTree(tree.toStringTree(parser));
			myTree.originFile = fileName;

			// Keep information on where in the source code the tree represents
			ArrayList<Node> nodesList = new ArrayList<Node>();
			myTree.traverseLeavesList(nodesList, myTree.firstNode);

			for (int i = 0; i < nodesList.size()-1; i++) {
				Node myNode = nodesList.get(i);
				myNode.startPos = startPos.get(i);
				myNode.endPos = endPos.get(i);
				myNode.startLine = line.get(i);
				myNode.endLine = line.get(i);
				//System.out.println(myNode.startPos + ":" + myNode.endPos + " " + myNode.line + " " + myNode.data);
			}

			myTree.assignPositions(myTree.firstNode);


			// Replace the subtree of an expressionStatement with in-order
			// traversal string of leaves
			// myTree.replaceExpr(myTree.firstNode);

			// Create image representations of the trees
			//generateAntlrTreeImage(parser, tree, fileName.substring(fileName.lastIndexOf('/')+1, fileName.lastIndexOf('.')) + "_antlr.png");
			//generateFlatTreeImage(parser, myTree, "./trees/" + fileName.substring(fileName.lastIndexOf('/')+1, fileName.lastIndexOf('.')) + ".png");

			// Create hash values to count subtrees
			myTree.createHashes(myTree.firstNode);

			// Keep track of how often a subtree appears below every node
			myTree.updateAllCounts(myTree.firstNode);
			//myTree.firstNode.printCounts();

			allTrees.add(myTree);

		} catch (Exception e) {
			System.out.println("FAILED");
		}
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