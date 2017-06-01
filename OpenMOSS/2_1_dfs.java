/**
 * This class reads an adjacency list from a file and performs a depth first search on it.
 * 
 * @author Zhen Chen
 * @AUID 6438580
 * 
 */

import java.util.ArrayList;
import java.util.Stack;

public class dfs {
	private static int[][] list, dfslist;
	private static final String INPUT_FILE_NAME = "list.txt";
	private static final String OUTPUT_FILE_NAME = "dfs.txt";

	public static void main(String[] args) {
		list = fileHelper.readFile(INPUT_FILE_NAME);
		try {
			dfslist = fulldfs(list);
			fileHelper.writeFile(OUTPUT_FILE_NAME, dfslist);
		} catch (NullPointerException e) {
			System.out.println("Argument is null!");
		}
	}

	/**
	 * Perform a full depth first search on the input graph and give a result
	 * list.
	 * 
	 * @param list
	 *            An adjacency list.
	 * 
	 * @return A dfs list which contains a bunch of arrays. Empty arrays are
	 *         used to separate different search trees. Other arrays have two
	 *         elements. The first element is the label of the vertex assigned
	 *         to it during the search. The second element is the vertex number.
	 */
	public static int[][] fulldfs(int[][] list) {
		int i, n, counter;
		int[][] dfslist;
		n = list.length;
		counter = 0;
		boolean[] white = new boolean[n];
		ArrayList<int[]> temp = new ArrayList<int[]>();

		// colour all vertices white initially
		for (i = 0; i < n; i++) {
			white[i] = true;
		}

		// do we have any white vertices?
		for (i = 0; i < n; i++) {
			if (white[i] == true) {
				// run dfs once based on the source vertex
				counter = onedfs(list, white, i, temp, counter);
			}
		}

		n = temp.size();
		dfslist = new int[n][];
		for (i = 0; i < n; i++) {
			dfslist[i] = temp.get(i);
		}

		return dfslist;
	}

	/**
	 * Perform a single depth first search based on the source vertex.
	 * 
	 * @param list
	 *            An adjacency list.
	 * @param white
	 *            An array containing colour information of each vertex.
	 * @param source
	 *            The source vertex to start a search.
	 * @param temp
	 *            Store the information of this search tree.
	 * @param counter
	 *            Give a label to each output vertex according to its order.
	 * 
	 * @return The updated counter.
	 * 
	 */
	public static int onedfs(int[][] list, boolean[] white, int source,
			ArrayList<int[]> temp, int counter) {
		int i, father, child;
		int[] line;
		Stack<Integer> dfsStack = new Stack<Integer>();

		dfsStack.push(source);
		white[source] = false;
		while (!dfsStack.isEmpty()) {
			father = dfsStack.peek();
			// try to find a white vertex from the children of father
			i = 0;
			while (i < list[father].length && white[list[father][i]] == false) {
				i++;
			}
			if (i < list[father].length) {
				// add a child vertex into the stack
				child = list[father][i];
				dfsStack.push(child);
				white[child] = false;
			} else {
				// pop father vertex from the stack
				dfsStack.pop();
				line = new int[2];
				line[0] = counter++;
				line[1] = father;
				temp.add(line);
			}
		}

		// stack is empty and we have built a search tree
		temp.add(new int[0]);

		return counter;
	}
}
