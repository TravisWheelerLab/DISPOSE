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
	        <h2>
	        	<center>
	            	<a href="./submit.php" target="_blank">
	            		Submission Help
	            	</a>
	    		</center>
	        </h2>
	        What do those buttons do, etc.
    	</div>

    	<!-- Results tab -->
    	<div id="results" class="tabcontent">
	        <h2>
	            <center>
	            	<a href="./results.php" target="_blank">
	            		Results Help
	            	</a>
	        	</center>
	        </h2>
	        What do those numbers mean, etc.
    	</div>

    	<!-- WASTE tab -->
    	<div id="waste" class="tabcontent">
	        <h2>
	            <center>
	            	<a href="./results.php" target="_blank">
	            		WASTE Help
	            	</a>
	        	</center>
	        </h2>
	        How does this visual work, etc.
    	</div>

	</body>
</html>