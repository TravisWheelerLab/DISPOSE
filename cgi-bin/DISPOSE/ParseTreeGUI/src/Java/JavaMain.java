package Java;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import javax.imageio.ImageIO;
import javax.print.PrintException;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import org.abego.treelayout.TreeForTreeLayout;
import org.abego.treelayout.TreeLayout;
import org.abego.treelayout.demo.TextInBox;
import org.abego.treelayout.demo.TextInBoxNodeExtentProvider;
import org.abego.treelayout.demo.swing.TextInBoxTreePane;
import org.abego.treelayout.util.DefaultConfiguration;
import org.antlr.v4.gui.TreeViewer;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.Trees;

import Java.FlatTree.Node;

public class JavaMain {
	public static void main(String[] args) {
        //prepare token stream
        CharStream stream = null;
		try {
			stream = CharStreams.fromFileName("./example.java");
		} catch (IOException e) {
			e.printStackTrace();
		}
        Java8Lexer lexer  = new Java8Lexer(stream);
        TokenStream tokenStream = new CommonTokenStream(lexer);
        Java8Parser parser = new Java8Parser(tokenStream);
        ParseTree tree = parser.compilationUnit(); 
        

        // Show AST in console
        // System.out.println(tree.toStringTree(parser) + "\n");
        FlatTree myTree = new FlatTree(tree.toStringTree(parser));
        FlatTree myLeaflessTree = new FlatTree(tree.toStringTree(parser));
        myLeaflessTree.leafless = true;
        
        // Create hash values to count subtrees
        myLeaflessTree.createHashes(myLeaflessTree.firstNode);
//      myTree.createHashes(myTree.firstNode);
        
        // Keep track of how often a subtree appears below every node
//      myTree.updateAllCounts(myTree.firstNode);
//      myTree.firstNode.printCounts();
        myLeaflessTree.updateAllCounts(myLeaflessTree.firstNode);
        myLeaflessTree.firstNode.printCounts();
 		
        // Show AST in image
        TreeViewer viewr = new TreeViewer(Arrays.asList(
                parser.getRuleNames()),tree);
        try {
			viewr.save("tree.png");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (PrintException e) {
			e.printStackTrace();
		}
        
        FlatTreeViewer viewr2 = new FlatTreeViewer(Arrays.asList(
                parser.getRuleNames()),myTree);
        
        try {
			viewr2.save("flat_tree.png");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (PrintException e) {
			e.printStackTrace();
		}
        
        FlatTreeViewer viewr3 = new FlatTreeViewer(Arrays.asList(
                parser.getRuleNames()),myLeaflessTree);
        
        try {
			viewr3.save("flat_tree_leafless.png");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (PrintException e) {
			e.printStackTrace();
		}
    }
}