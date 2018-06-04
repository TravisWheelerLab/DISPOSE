package Java;

import java.util.HashMap;

public class PairValue implements Comparable<PairValue>{
	String file1;
	String file2;
	double score;
	
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
	
	public double assignSimilarity(FlatTree tree1, FlatTree tree2, HashMap<String, Double> scoreHistory, boolean recurse) {
		double score = 0;
		
		tree1.allChildren(tree1.firstNode);
		tree2.allChildren(tree2.firstNode);
		
		
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
					long startTime = System.nanoTime();
					Double nextScore = nScore(s1, s2);
					long endTime = System.nanoTime();
					System.out.println((endTime-startTime)/1000000000.0);
					score += nextScore;
					scoreHistory.put(combinedHash, nextScore);
				}
			}
		}
		
		if (!recurse) {
			score /= Math.sqrt(assignSimilarity(tree1, tree1, scoreHistory, true) * assignSimilarity(tree2, tree2, scoreHistory, true));
		}
		
		return score;
	}
	
	public double nScore(FlatTree.Node s1, FlatTree.Node s2) {
		double nodeScore = 0;
		double decayFactor = 0.99;
		
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
}
