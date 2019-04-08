package Java;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.PriorityQueue;
import Java.FlatTree.Node;
import org.apache.commons.text.StringEscapeUtils;


public class PairValue implements Comparable<PairValue>{
	String file1;
	String file2;
	double score;
	
	int n1 = -1;
	int n2 = -1;
	
	int startPos1, startPos2;
	int endPos1, endPos2;
	int startLine1, startLine2;
	int endLine1, endLine2;
	
	int globalEnd1 = 0;
	int globalEnd2 = 0;
	
	ArrayList<PairValue> scoreList = new ArrayList<PairValue>();
	
	public PairValue (String file1, String file2, double score, int n1, int n2) {
		this.file1 = file1;
		this.file2 = file2;
		this.score = score;
		this.n1 = n1;
		this.n2 = n2;
	}
	@Override
	public int compareTo(PairValue o) {
		if (score < o.score)
			return 1;
		else if (score > o.score)
			return -1;
		return 0;
	}
	
	@Override
	public String toString() {
		String escapedStr = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(this.file1));
		String escapedStr2 = StringEscapeUtils.escapeJson(StringEscapeUtils.escapeJson(this.file2));
		return "[\"" + escapedStr+ "\", \"" + escapedStr2 + "\"," + this.score +  "]";
	}
	
	double nextScore;
	ArrayList<PairValue> nodePath;
	PairValue nextPair;
	
	int R, C;
	double[] scoreHist;
	boolean[] checked;
	
	FlatTree t1, t2;
	
	// TODO: Remove test method for all subtree calculations again
	public double assignSimilarity2(FlatTree tree1, FlatTree tree2, boolean recurse, HashMap<FlatTree, Double> selfScore, double decayFactor) {
		double totalScore = 0;
		
		t1 = tree1;
		t2 = tree2;
		
		R = tree1.allChildren.size(); // num rows
		C = tree2.allChildren.size(); // num cols
		
		scoreHist = new double[R*C+1];
		checked = new boolean[R*C+1]; // flags for pair scoring computation
		
		for (FlatTree.Node s1 : tree1.allChildren) {
				if (s1.endPos > globalEnd1)
					globalEnd1 = s1.endPos;
			for (FlatTree.Node s2: tree2.allChildren) {
				
				if (s2.endPos > globalEnd2)
					globalEnd2 = s2.endPos;
				
				if (checked[C*s1.id+s2.id] == true) {
					nextScore = scoreHist[C*s1.id+s2.id];
				}
				else  {
					nextScore = nScore(s1, s2, scoreHist, checked, C, decayFactor);
					scoreHist[C*s1.id+s2.id] = nextScore;
					checked[C*s1.id+s2.id] = true;
				}
				
				totalScore += nextScore;
				
				if (!recurse && nextScore>0) {
					nextPair = new PairValue(s1.hashVal.toString(), s2.hashVal.toString(), nextScore, s1.id, s2.id);
					nextPair.startPos1 = s1.startPos;
					nextPair.startPos2 = s2.startPos;
					nextPair.endPos1 = s1.endPos;
					nextPair.endPos2 = s2.endPos;
					nextPair.startLine1 = s1.startLine;
					nextPair.startLine2 = s2.startLine;
					nextPair.endLine1 = s1.endLine;
					nextPair.endLine2 = s2.endLine;
					scoreList.add(nextPair);
				}
			}
		}
		
		if (!recurse) {
			double treeVal1 = selfScore.get(tree1);
			double treeVal2 = selfScore.get(tree2);
			totalScore /= Math.sqrt(treeVal1 * treeVal2);
			System.out.println(treeVal1 + " " + treeVal2 + " " + totalScore + "\n");
		}
		return Math.abs(totalScore);
	}
	
	public double nScore(FlatTree.Node s1, FlatTree.Node s2, double[] scoreHist, boolean[] checked, int C, double decayFactor) {
		double nodeScore = 0;
		
		double prodScore = 1;
		
		// If both subtrees are the leaves of an expr statement
		if (s1.isExpr() && s2.isExpr()) {
			nodeScore = Math.max(0, editDistance(s1.data, s2.data)) * s1.weight * s2.weight;
		}
		// If both subtrees' roots are different
		else if (!s1.data.equals(s2.data)) {
			nodeScore = 0;
		}
		// If both subtrees are leaves
		else if (s1.isLeaf() && s2.isLeaf()) {
			nodeScore = s1.weight*s2.weight;
		}
		
		
		// Otherwise
		else {
			double maxScore, testScore;
			int tied;
			Node c1, c2;
//			ArrayList<PairValue> maxPair = new ArrayList<PairValue>();
			for (int i = 0; i < s1.getChildCount(); i++) {
				maxScore = 0;
				tied = 1;
				for (int j=0; j<s2.getChildCount(); j++) {
					c1 = s1.getChild(i);
					c2 = s2.getChild(j);
					if (checked[c1.id*C+c2.id] == true) {
						testScore = scoreHist[c1.id*C+c2.id] ;
					}
					else{
						testScore = nScore(c1, c2, scoreHist, checked, C, decayFactor);
						scoreHist[c1.id*C+c2.id] = testScore;
						checked[c1.id*C+c2.id] = true;
					}
					if (testScore > maxScore) {
						maxScore = testScore;
//						tied = 1;
					}
//					else if (testScore == maxScore) {
//						tied++;
//					}
				}
				
				prodScore *= (1 + maxScore);
			}
			nodeScore = prodScore*s1.weight*s2.weight;
		}
		
		return decayFactor*nodeScore;
	}
	
	public double editDistance(String str1, String str2) {
		double score = 0;
		
		int[][] optMatrix = new int[str1.length()+1][str2.length()+1];
		
		// Initialization
		for(int j = 0; j <= str2.length(); j++)
			optMatrix[0][j] = -j;
		for(int i = 0; i <= str1.length(); i++)
			optMatrix[i][0] = -i;
		
		// Needleman-Wunsch
		for (int j = 1; j <= str2.length(); j++) {
			for (int i = 1; i <= str1.length(); i++) {
				optMatrix[i][j] = Math.max(optMatrix[i-1][j-1] + charScore(str1.charAt(i-1),str2.charAt(j-1)), Math.max(optMatrix[i-1][j] - 1, optMatrix[i][j-1] - 1));
			}
		}
		
		score = optMatrix[str1.length()][str2.length()];
	
		return Math.max(0, score / Math.max(str1.length(), str2.length()));
	}

	public int charScore(char a, char b) {
		if (a==b)
			return 1;
		else
			return -1;
	}
	
	public void makeMatchFile(String userFolder) throws IOException {
		File matchFile = new File(userFolder + "/matchFiles2/" + file1.substring(file1.lastIndexOf(File.separatorChar) + 1, file1.lastIndexOf('.')) + "_" + file2.substring(file2.lastIndexOf(File.separatorChar) + 1, file2.lastIndexOf('.')) + ".txt");
		FileWriter myWriter = new FileWriter(matchFile);

		myWriter.write("'" + file1.substring(file1.lastIndexOf(File.separatorChar) + 1) + "' '" + file1  + "' '" + file2.substring(file2.lastIndexOf(File.separatorChar) + 1) + "' '" + file2 + "' '" + score + "' \n");
		
		PriorityQueue<PairValue> prq = new PriorityQueue<PairValue>();
		prq.addAll(scoreList);
		
		boolean[] marked1 = new boolean[globalEnd1];
		boolean[] marked2 = new boolean[globalEnd2];
		
//		for (int i=0; i<scoreList.size(); i++) {
//			PairValue next = scoreList.get(i);
//			myWriter.write(next.startPos1 + ":" + next.startLine1 + " " + next.endPos1 + ":" + next.endLine1 + " " + next.file1 + "\n");
//			myWriter.write(next.startPos2 + ":" + next.startLine2 + " " + next.endPos2 + ":" + next.endLine2 + " " + next.file2 + "\n");
//			myWriter.write(next.score + "\n\n");
//		}
		
		while (prq.size() != 0) {
			PairValue next = prq.poll();
			boolean prevMarked1 = true;
			boolean prevMarked2 = true;
			for (int i = next.startPos1; i < next.endPos1; i++) {
				prevMarked1 &= marked1[i];
				marked1[i] = true;
			}
			for (int i = next.startPos2; i < next.endPos2; i++) {
				prevMarked2 &= marked2[i];
				marked2[i] = true;
			}
			
//			System.out.println(next.startPos1 + ":" + next.endPos1 + " " + next.startPos2 + ":" +
//					next.endPos2 + " " + prevMarked1 + " " + prevMarked2 + " " + next.score);
			
			if ((prevMarked1 || prevMarked2) == false) {
				myWriter.write(next.startPos1 + ":" + next.startLine1 + " " + next.endPos1 + ":" + next.endLine1 + " " + next.n1 + "\n");
				myWriter.write(next.startPos2 + ":" + next.startLine2 + " " + next.endPos2 + ":" + next.endLine2 + " " + next.n2 + "\n");
				myWriter.write(next.score + "\n\n");
			}
		}
		
		myWriter.close();
	}
	
	public void makeScoreFile(String userFolder) throws IOException {
		File scoreFile = new File(userFolder + "/scoreFiles/" + file1.substring(file1.lastIndexOf(File.separatorChar) + 1, file1.lastIndexOf('.')) + "_" + file2.substring(file2.lastIndexOf(File.separatorChar) + 1, file2.lastIndexOf('.')) + ".txt");
		FileWriter myWriter = new FileWriter(scoreFile);
		
		ArrayList<String> matches;
		
		myWriter.write("{");
		
		boolean hasMatch = false;
		boolean firstMatch = true;
		
		for (int i=0; i < R; i++) {
			
			hasMatch = false;
			matches = new ArrayList<String>();
			
			for (int j=0; j < C; j++) {
				if (scoreHist[i*C+j] != 0) {
					matches.add("\"" + j +"\": " + Math.round(1000000.0*scoreHist[i*C+j]));
					hasMatch = true;
				}
			}
			
			if (hasMatch) {
				if (firstMatch) {
					myWriter.write("\"" + i + "\": {");
					firstMatch = false;
				}
				else {
					myWriter.write(",\"" + i + "\": {");
				}
				myWriter.write(String.join(", ", matches) + "}");
			}
		}
		
		myWriter.write("}");
		
		myWriter.close();
		

		scoreHist = null;
		checked = null;
	}
}
