package Java;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;

public class PairValue implements Comparable<PairValue>{
	String file1;
	String file2;
	double score;
	
	ArrayList<PairValue> scoreList = new ArrayList<PairValue>();
	
	public PairValue (String file1, String file2, double score) {
		this.file1 = file1;
		this.file2 = file2;
		this.score = score;
	}
	@Override
	public int compareTo(PairValue o) {
		if (score < o.score)
			return 1;
		else if (score > o.score)
			return -1;
		return 0;
	}
	
	// TODO: Remove slower method
	public double assignSimilarity(FlatTree tree1, FlatTree tree2, HashMap<String, Double> scoreHistory, boolean recurse) {
		double score = 0;
		
		//long startTime = System.nanoTime();
		
		for (FlatTree.Node s1 : tree1.allChildren) {
			for (FlatTree.Node s2: tree2.allChildren) {
				String combinedHash;
				if (s1.compareTo(s2) == -1)
					combinedHash = s1.hashVal + s2.hashVal;
				else
					combinedHash = s2.hashVal + s1.hashVal;
				
				
				if (scoreHistory.get(combinedHash) != null) {
					score += scoreHistory.get(combinedHash);
				}
				else {
					//long startTime = System.nanoTime();
					Double nextScore = nScore(s1, s2);
					//long endTime = System.nanoTime();
					//System.out.println((endTime-startTime)/1000000000.0);
					score += nextScore;
					scoreHistory.put(combinedHash, nextScore);
				}
				
			}
		}
		
		//long endTime = System.nanoTime();
		
		//System.out.println("TEST2: " + (endTime-startTime)/1000000000.0);
		
		if (!recurse)
			score /= Math.sqrt(assignSimilarity(tree1, tree1, scoreHistory, true) * assignSimilarity(tree2, tree2, scoreHistory, true));
		
		return score;
	}
	
	// TODO: Remove test method for all subtree calculations again
	public double assignSimilarity2(FlatTree tree1, FlatTree tree2, boolean recurse) {
		double score = 0;
		
		//long startTime = System.nanoTime();
		
		for (FlatTree.Node s1 : tree1.allChildren) {
			for (FlatTree.Node s2: tree2.allChildren) {
					Double nextScore = nScore(s1, s2);
					score += nextScore;
					
					if (!recurse && s1.hashVal.equals(s2.hashVal))
						System.out.println(s1.hashVal + " " + nextScore);
					
					if (!recurse && nextScore>0)
						scoreList.add(new PairValue(s1.hashVal, s2.hashVal, nextScore));
			}
		}
		
		//long endTime = System.nanoTime();
		
		//System.out.println("TEST2: " + (endTime-startTime)/1000000000.0);
		
		if (!recurse) {
			double treeVal1 = assignSimilarity2(tree1, tree1, true);
			double treeVal2 = assignSimilarity2(tree2, tree2, true);
			score /= Math.sqrt(assignSimilarity2(tree1, tree1, true) * assignSimilarity2(tree2, tree2, true));
			System.out.println(treeVal1 + " " + treeVal2 + " " + score + "\n");
		}
		return score;
	}
	
	public double assignSimilarity4(FlatTree tree1, FlatTree tree2, HashMap<String, HashMap<String, Double>> scoreHistory, boolean recurse) {
		double score = 0;
		
		//long startTime = System.nanoTime();
		
		for (FlatTree.Node s1 : tree1.allChildren) {
			for (FlatTree.Node s2: tree2.allChildren) {
				
				Double nextScore = 0.0;
				
				if (scoreHistory.get(s1.hashVal) != null) {
					if (scoreHistory.get(s1.hashVal).get(s2.hashVal) != null)
						score += scoreHistory.get(s1.hashVal).get(s2.hashVal);
					else {
						nextScore = nScore(s1, s2);
						score += nextScore;
						scoreHistory.get(s1.hashVal).put(s2.hashVal, nextScore);
					}
				}
				else {
					scoreHistory.put(s1.hashVal, new HashMap<String, Double>());
					
					if (scoreHistory.get(s2.hashVal) != null) {
						if (scoreHistory.get(s2.hashVal).get(s1.hashVal) != null) {
							nextScore = scoreHistory.get(s2.hashVal).get(s1.hashVal);
							score += nextScore;
						}
						else {
							nextScore = nScore(s1, s2);
							score += nextScore;
							scoreHistory.get(s1.hashVal).put(s2.hashVal, nextScore);
						}
					}
					else {
						//long startTime = System.nanoTime();
						nextScore = nScore(s1, s2);
						//long endTime = System.nanoTime();
						//System.out.println((endTime-startTime)/1000000000.0);
						score += nextScore;
						scoreHistory.get(s1.hashVal).put(s2.hashVal, nextScore);
					}
				}
				
				System.out.println(score);
				
				if (nextScore > 0)
					scoreList.add(new PairValue(s1.hashVal, s2.hashVal, nextScore));
			}
		}
		
		//long endTime = System.nanoTime();
		
		//System.out.println("TEST3: " + (endTime-startTime)/1000000000.0);
		
		if (!recurse)
			score /= Math.sqrt(assignSimilarity4(tree1, tree1, scoreHistory, true) * assignSimilarity4(tree2, tree2, scoreHistory, true));
		
		return score;
	}
	
	public double nScore(FlatTree.Node s1, FlatTree.Node s2) {
		double nodeScore = 0;
		double decayFactor = 0.2;
		
		double prodScore = 1;
		
		
		// If both subtrees are the leaves of an expr statement
		if (s1.isExpr() && s2.isExpr()) {
			nodeScore = decayFactor * editDistance(s1.data, s2.data) * s1.weight * s2.weight;
		}
		// If both subtrees' roots are different
		else if (!s1.data.equals(s2.data)) {
			nodeScore = 0;
		}
		// If both subtrees are leaves
		else if (s1.isLeaf() && s2.isLeaf()) {
			nodeScore = decayFactor*s1.weight*s2.weight;
		}
		// Otherwise
		else {
			for (int i = 0; i < s1.getChildCount(); i++) {
				double maxScore = 0;
				for (int j=0; j<s2.getChildCount(); j++) {
					double testScore = nScore(s1.getChild(i), s2.getChild(j));
//					if (s1.getChild(i).hashVal.equals(s2.getChild(j).hashVal))
//						System.out.println("TEST: " + s1.getChild(i).hashVal + " " + s2.getChild(j).hashVal + " " + testScore);
					if (testScore > maxScore)
						maxScore = testScore;
				}
				prodScore *= (1 + maxScore);
			}
			nodeScore = decayFactor*prodScore*s1.weight*s2.weight;
			
		}
		
		
		return nodeScore;
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
	
		return score / Math.max(str1.length(), str2.length());
	}

	public int charScore(char a, char b) {
		if (a==b)
			return 1;
		else
			return -1;
	}
	
	public void makeMatchFile() throws IOException {
		File matchFile = new File("./matchFiles/" + file1.substring(7) + file2.substring(7) + ".txt");
		FileWriter myWriter = new FileWriter(matchFile);
		
		Collections.sort(scoreList);
		
		for (int i=0; i<scoreList.size(); i++) {
			PairValue next = scoreList.get(i);
			myWriter.write(next.file1 + " " + next.file2 + " " + next.score + "\n");
		}
		
		myWriter.close();
	}
}
