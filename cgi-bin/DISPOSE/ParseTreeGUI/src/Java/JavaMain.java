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

public class JavaMain {

	static ArrayList<FlatTree> allTrees = new ArrayList<FlatTree>();
	
	public static void main(String[] args) throws IOException {
		
		try (Stream<Path> paths = Files.walk(Paths.get("./Java"))) {
		    paths
		        .filter(Files::isRegularFile)
		        .forEach(JavaMain::prepareTree);
		}
		
//		prepareTree(FileSystems.getDefault().getPath("./Java", "1_3_17_HASEL.java"));
		
		
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
		
		
		List<String> stopWords = Arrays.asList(")", "(", "[", "]");
		
		for (FlatTree ft: allTrees) {
			ft.assignWeights(ft.firstNode, stopWords, fileCounts, ft.firstNode, allTrees.size());
		}
		
		ArrayList<PairValue> myScores = new ArrayList<PairValue>();
		
		for (int i=0; i<allTrees.size(); i++) {
			for (int j=0; j < i; j++) {
				PairValue next = new PairValue(allTrees.get(i).originFile, allTrees.get(j).originFile, 0);
				System.out.println("Calculating: " + allTrees.get(i).originFile + " " + allTrees.get(j).originFile);
				next.score = next.assignSimilarity(allTrees.get(i), allTrees.get(j), false);
				myScores.add(next);
			}
		}
		
		Collections.sort(myScores);
		
		int reportLim = Math.min(50, myScores.size());
		
		for (int i=0; i<reportLim; i++)
			System.out.println(myScores.get(i).file1 + " " + myScores.get(i).file2 + " " + myScores.get(i).score);
        
    }
	
	public static void prepareTree(Path filePath) {
		
		String fileName = filePath.toString();
		System.out.println("Creating tree: " + fileName);
		
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
        
        // Show AST in console
//        System.out.println(tree.toStringTree(parser) + "\n");
        
        // Flatten the ANTLR generated parse tree
		// FlatTree myLeaflessTree = new FlatTree(tree.toStringTree(parser));
		// myLeaflessTree.leafless = true;
        FlatTree myTree = new FlatTree(tree.toStringTree(parser));
        myTree.originFile = fileName;
        
        // Replace the subtree of an expressionStatement with in-order
        // traversal string of leaves
        myTree.replaceExpr(myTree.firstNode);
        
        // Create image representations of the trees
        // generateAntlrTreeImage(parser, tree, "tree.png");
        // generateFlatTreeImage(parser, myTree, "flat_tree.png");
        
        // Create hash values to count subtrees
        myTree.createHashes(myTree.firstNode);
        
        // Keep track of how often a subtree appears below every node
        myTree.updateAllCounts(myTree.firstNode);
        //myTree.firstNode.printCounts();
        
        allTrees.add(myTree);
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