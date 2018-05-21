package CSharp;
import java.io.IOException;
import java.util.Arrays;
import javax.print.PrintException;
import org.antlr.v4.gui.TreeViewer;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

public class CSharpMain {
	public static void main(String[] args) {
        //prepare token stream
        CharStream stream = null;
		try {
			stream = CharStreams.fromFileName("./1_12_788_DijkstraAlgorithm.cs");
		} catch (IOException e) {
			e.printStackTrace();
		}
        CSharpLexer lexer  = new CSharpLexer(stream);
        TokenStream tokenStream = new CommonTokenStream(lexer);
        CSharpParser parser = new CSharpParser(tokenStream);
        ParseTree tree = parser.compilation_unit(); 
        

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