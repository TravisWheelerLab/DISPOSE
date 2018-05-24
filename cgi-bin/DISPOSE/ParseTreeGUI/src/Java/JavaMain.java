package Java;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;

import javax.print.PrintException;
import org.antlr.v4.gui.TreeViewer;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

public class JavaMain {
	public static void main(String[] args) {
		
		// Number of files that contain a particular tree
		HashMap<String, Integer> fileCounts = new HashMap<String, Integer>();
		
		prepareFile("./example.java");
        
        
    }
	
	public static void prepareFile(String fileName) {
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
        // System.out.println(tree.toStringTree(parser) + "\n");
        
        // Flatten the ANTLR generated parse tree
		// FlatTree myLeaflessTree = new FlatTree(tree.toStringTree(parser));
		// myLeaflessTree.leafless = true;
        FlatTree myTree = new FlatTree(tree.toStringTree(parser));
        
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
        
        
	}
	
	public static void generateFlatTreeImage(Java8Parser myParser, FlatTree myTree, String fileName) {
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