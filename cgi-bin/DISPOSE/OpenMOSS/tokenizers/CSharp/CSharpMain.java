package CSharp;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;

public class CSharpMain {


	public static void main(String[] args) throws IOException {
		
		String subDir = args[0];
		File[] submissions = new File("./" + subDir).listFiles();
		
		FileWriter myWriter;
		BufferedWriter myBufferedWriter = null;
		
		for (File sub:submissions) {
			CharStream stream = CharStreams.fromFileName("./" + subDir + "/" + sub.getName());
//			CharStream stream = CharStreams.fromFileName("./" + "src" + "/" + "113_0_Aux.java");
			System.out.println("Tokenizing: ./" + subDir + "/" + sub.getName());
			CSharpLexer lexer = new CSharpLexer(stream);
			List<? extends Token> myTokens = lexer.getAllTokens();
			Vocabulary myVocab = lexer.getVocabulary();
			
			myWriter = new FileWriter("./TokenFiles/CSharp/" + sub.getName().substring(0, sub.getName().lastIndexOf('.')) + "_token.txt");
//			myWriter = new FileWriter("./TokenFiles/" + "113_0_Aux_token.txt");
			myBufferedWriter = new BufferedWriter(myWriter);
			
	        for(int i = 0; i < myTokens.size(); i++) {
	            Token myToken = myTokens.get(i);
	            String[] remFlags = new String[] {"SINGLE_LINE_DOC_COMMENT", "DELIMITED_DOC_COMMENT", "SINGLE_LINE_COMMENT", "DELIMITED_COMMENT", "WHITESPACES"};
	            if (Arrays.asList(remFlags).contains(myVocab.getSymbolicName(myToken.getType())) == false) {
	            	 myBufferedWriter.write(myToken.getText() + " " + myToken.getStartIndex() + " " + myToken.getLine() + " " + myVocab.getSymbolicName(myToken.getType()) + "\n");
	            }
	        }
	        
	        myBufferedWriter.close();
		}
		
		
	
	}

}
