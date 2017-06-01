/**
 * This class reads an adjacency matrix from a file and finds what edges are needed to make it strongly connected.
 * 
 * @author Zhen Chen
 * @AUID 6438580
 *
 */

import java.util.ArrayList;

public class combinecomponents {
	private static int[][] matrix, recommendation, newstreets;
	private static final String INPUT_FILE_NAME = "matrix.txt";
	private static final String OUTPUT_FILE_NAME = "newstreets.txt";
	private static final int AUID = 6438580;

	public static void main(String[] args) {
		matrix = fileHelper.readFile(INPUT_FILE_NAME);
		try {
			recommendation = combine(matrix);
			newstreets = prepareFile(recommendation);
			fileHelper.writeFile(OUTPUT_FILE_NAME, newstreets);
		} catch (NullPointerException e) {
			System.out.println("Argument is null!");
		}
	}

	public static int[][] combine(int[][] matrix) {
		int i, j, k, n, m, edge;
		int[] indegree, outdegree, line;
		int[][] components, recommendation;
		ArrayList<int[]> temp = new ArrayList<int[]>();
		ArrayList<Integer> source = new ArrayList<Integer>();
		ArrayList<Integer> sink = new ArrayList<Integer>();

		components = findcomponents.componentsInMatrix(matrix);
		n = components.length;
		if (n > 1) {
			// find in-degree and out-degree of each component
			indegree = new int[n];
			outdegree = new int[n];
			for (i = 0; i < n; i++) {
				indegree[i] = findDegree(matrix, components, i, true);
				outdegree[i] = findDegree(matrix, components, i, false);
			}

			// find source component and sink component
			for (i = 0; i < n; i++) {
				if (indegree[i] == 0) {
					// this component is a source
					source.add(components[i][0]);
				}
				if (outdegree[i] == 0) {
					// this component is a sink
					sink.add(components[i][0]);
				}
			}

			n = source.size();
			m = sink.size();
			edge = Math.max(n, m);
			i = j = 0;
			for (k = 0; k < edge; k++) {
				if (source.get(i).equals(sink.get(j))) {
					i = (i + 1) % n;
				}
				line = new int[2];
				line[0] = sink.get(j);
				line[1] = source.get(i);
				temp.add(line);
				i = (i + 1) % n;
				j = (j + 1) % m;
			}
		}

		n = temp.size();
		recommendation = new int[n][];
		for (i = 0; i < n; i++) {
			recommendation[i] = temp.get(i);
		}

		return recommendation;
	}

	private static int[][] prepareFile(int[][] recommendation) {
		int i, n;
		n = recommendation.length + 1;
		int[][] newstreets = new int[n][];

		// add AUID to the first line
		newstreets[0] = new int[1];
		newstreets[0][0] = AUID;

		for (i = 1; i < n; i++) {
			newstreets[i] = recommendation[i - 1];
		}
		return newstreets;
	}

	public static boolean contains(final int[] array, final int value) {
		for (final int element : array) {
			if (element == value) {
				return true;
			}
		}
		return false;
	}

	public static int findDegree(int[][] matrix, int[][] components, int order,
			boolean flag) {
		int i, j, n, m, counter;
		boolean[] white;
		n = matrix.length;
		m = components.length;
		counter = 0;
		white = new boolean[m];

		for (i = 0; i < m; i++) {
			white[i] = false;
		}
		white[order] = true;

		for (final int vertex : components[order]) {
			for (i = 0; i < n; i++) {
				for (j = 0; j < m; j++) {
					// vertices in the same component are the same
					if (white[j] == false && contains(components[j], i)) {
						if (flag == true && matrix[i][vertex] > 0
								|| flag == false && matrix[vertex][i] > 0) {
							counter++;
							white[j] = true;
						}
					}
				}
			}
		}
		return counter;
	}
}
