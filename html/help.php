<?php
	session_start();
?>

<!DOCTYPE html>
<html>
	<head>
		<title>DISPOSE | Help</title>

	    <!-- tabs appearance -->
	    <link rel="stylesheet" type="text/css" href="../../../css/tabs.css">
	    <!-- additional help appearance -->
	    <link rel="stylesheet" type="text/css" href="../../../css/style3.css">
	    <!-- source code appearance -->
	    <link rel="stylesheet" type="text/css" href="../../../css/sources.css">
	    <link rel="stylesheet" type="text/css" href="../../../css/monokai-sublime.css">
	    <!-- load highlight.js for coding appearance -->
	    <script charset="utf-8" src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"></script>
	    <!-- load jquery for element selection -->
	    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
	    <script>hljs.initHighlightingOnLoad();</script>

	    <script src="../../../js/tabs_control.js"></script>
	    <script src="../../../js/help_control.js"></script>
	</head>
	<body>

		<a href="./">&#8592; Home</a> | 
		<a href="./login/profile.php">Profile &#8594;</a>

		<center>
			<h1>How to Use This Website</h1>
		</center>

		<!-- Pretty tabulation to separate the information displayed -->
	    <div class="tab">
	      <a href="#sub">
	      	<button class="tablinks" onclick="openTab(event, 'submission')">Submission</button>
	      </a>
	      <a href="#res">
	      	<button class="tablinks" onclick="openTab(event, 'results')">Results</button>
	      </a>
	      <a href="#waste">
	      	<button class="tablinks" onclick="openTab(event, 'waste')">WASTE</button>
	  	   </a>
	    </div>

	    <!-- Submission tab -->
    	<div id="submission" class="tabcontent">
	        <center>
		        <h2>
	            	<a href="./submit.php" target="_blank">
	            		Submission Help
	            	</a>
		        </h2>
		        <img src="./img/submit_example.png" alt="screenshot of submission page" width="25%" border="2px"></img>
	        </center>

	        <h3>Comparison Method</h3>
	        <p>
		        <b>DISPOSE MOSS</b> is based on the <a href="http://theory.stanford.edu/~aiken/publications/papers/sigmod03.pdf">winnowing algorithm</a> used in <a href="https://theory.stanford.edu/~aiken/moss/">MOSS</a>. Scoring is computed from consecutive fingerprints that are representative of document sections.
		        <br>
		        <b>DISPOSE WASTE</b> is based on the WASTK algorithm described <a href="https://www.hindawi.com/journals/sp/2017/7809047/">here</a>. Scoring is computed depending on the similarity of the source files' abstract syntax trees.
	    	</p>
	    	<hr>
	        <h3>Internet Queries</h3>
	        <p>
		        To utilize the "online-sourced evidence" features of DISPOSE, choose to use internet queries and upload a text document in the proper format described in the "Required Files" section.
		        <br>
		    	To only compare your submissions amongst themselves, such as with a unique, in-house assignment, choose to compare without queries for faster and focused results.
		    </p>
		    <hr>
	        <h3>WASTE Parameters</h3>
	        <p>
	        	The decay factor is the weighting factor to penalize accumulating a level up the tree. The goal of the decay factor is to offset the similarity score of nodes closer to the root so that they are not over-represented in the final measurement. This value is allowed to run from 0.01 to 1.0 (inclusive) and is set to 0.3 by default.
	        </p>
	        <p>
	        	<b>Inverse Term Frequency</b> (ITF) is an experimental idea which suggests that a node should be weighted higher if it appears less in a document. This is contrary to the original implementation of the node weight which uses a metric called <b>Term Frequency</b> (TF). TF weighs nodes that appear more often in a document as higher in the similarity score. It should be noted that using ITF is not currently numerically stable for more robust calculations. <b>It is recommended to keep this box unchecked except for experimental small problems for now.</b>
	        </p>
	        <hr>
	        <h3>Required Files</h3>
	        <p>If the "Use Internet Queries" option has been selected, then a Queries File must be uploaded into the form. The Queries File must be a text document (preferably .txt) where each line in the file is a query for the system to search for. An example of what a Queries File might look like is the following:</p>
	        <img src="./img/query_example.png" alt="list of query search terms" width="20%"></img>
	        <br>
	        <p>The Archive File is the collection of primary sourced files that you are interested in comparing. It is organized such that the immediate top-level domain is where each submission can be found in their own folders or in archived formats themselves. An example of creating a proper Archive File for this system is as follows:</p>
	        <ol>
			  <li>Organize Files</li>
			  (screenshot)
			  <li>Archive Folder</li>
			  (code snippets)
			  <li>Upload Archive</li>
			  (explanation of what this organization provides)
			</ol>
	        <hr>
	        <h3>Other Files</h3>
	        <p>
	        	The Past Archive File is an opportunity to provide additional files to compare to the primary sourced material in the "Archive File" from before. For example, if you had a collection of previous years' submissions for an assignment. The files in the Past Archive File will not be compared internally to each other which will allow the job to be completed faster. This also eliminates the need to filter out their matches to themselves in the results, as you are most concerned with the potential plagiarism that includes the primary archived files.
	        </p>
	        <p>
	        	The Ignore List file is a text document (preferably .txt) which lists the names of files which should be ignored in the similarity algorithms for determining weights and final results. Each line of the Ignore List should be the single name of a file to exclude. For example:
	        </p>
	        <img src="./img/ignore_example.png" alt="list of file names to exclude from algorithms" width="20%"></img>
    	</div>

    	<!-- Results tab -->
    	<div id="results" class="tabcontent">
	        <center>
		        <h2>
	            	<a href="./results.php" target="_blank">
	            		Results Help
	            	</a>
		        </h2>
		        <img src="./img/results_example.png" alt="screenshot of results page" width="50%" border="2px"></img>
	        </center>

	        <h3>Languages</h3>
	        <p>DISPOSE currently only supports Java 8, but the methods are extendable to using other ANTLR-defined grammars. Use the selector at the top of the page to filter results based on the desired language.</p>
	        <hr>
	        <h3>File and Author Names</h3>
	        <p>The file names in the list will be abbreviated by ids at their start in this order: groupID_submissionID_fileID_name. Group ID is determined by the origin of the files (e.g. "2" for user-provided files). Submission ID is determined by the ordering of the folder or archive in the group list. File ID is further determined by the listing of files within the submission. The full original path the source material came from is provided upon hovering the cursor above the abbreviated name.</p>
	        <p>Author names will match with a submission ID. The names are truncated to fit the results list. Full names can be viewed by hovering the cursor above the abbreviated name.</p>
	        <hr>
	        <h3>Score</h3>
	        <p>The relative similarity metric is listed for the pair of files shown by the rest of the columns. For MOSS, this score is an accumulation of total consecutive hash window matches. For WASTE, this is the cosine similarity between unique scorings for tree comparisons. There's an arrow next to WASTE pairs linking to the overall tree comparison view.</p>
    	</div>

    	<!-- WASTE tab -->
    	<div id="waste" class="tabcontent">
	        <center>
		        <h2>
	            	<a href="./results.php" target="_blank">
	            		WASTE Help
	            	</a>
		        </h2>
		        <img src="./img/waste_example.png" alt="screenshot of WASTE page" width="80%" border="2px"></img>
	        </center>

	        <h3>How to Access</h3>
	        <p>In order to access this visual you must first run a <a href="./submit.php">submission</a> using the DISPOSE WASTE option as your comparison method. Once you've been notified that your results are ready, head over to the <a href="./results.php">results</a> page. All WASTE data pages have been generated for the top scoring matches presented here. They can be accessed with the arrows next to the numerical score in the Score column.</p>
	        <hr>
	        <h3>Files Tab</h3>
	        <p>The Files Tab represents the source code for the files in the current pair being visualized. For convenience, the source code is labeled with line numbers. These lines are highlighted to show where the current selected nodes in the Trees tab correspond.</p>
	        <hr>
	        <h3>Trees Tab</h3>
	        <p>This is where you can find the trees!</p>
	        <hr>
	        <h3>Stats Tab</h3>
	        <p>
	        	This is where you can find additional stats for the tree match and overall job such as height, score, and node sensitivity distributions.
	        	<br><br>
	        	<b>This feature has yet to be implemented.</b>
	    	</p>

    	</div>

	</body>
</html>