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

	        What do those buttons do, etc.
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

	        <h3>File and Author Names</h3>
	        <p>The file names in the list will be abbreviated by ids at their start in this order: groupID_submissionID_fileID_name. Group ID is determined by the origin of the files (e.g. "2" for user-provided files). Submission ID is determined by the ordering of the folder or archive in the group list. File ID is further determined by the listing of files within the submission. The full original path the source material came from is provided upon hovering the cursor above the abbreviated name.</p>
	        <p>Author names will match with a submission ID. The names are truncated to fit the results list. Full names can be viewed by hovering the cursor above the abbreviated name.</p>

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
	        How does this visual work, etc.
    	</div>

	</body>
</html>