<?php
	session_start();

	if ($_SESSION['logged_in'] != 1) {
		$_SESSION['error'] = "Log in to make a submission!";
		header("location: /login/index.php");    
	}

	if ($_SESSION['active'] != 1) {
		$_SESSION['error'] = "Activate your account to make a submission!";
		header("location: /login/profile.php");
	}

?>

<!DOCTYPE html>
<html>
	<head>
		<title>DISPOSE | Submission</title>
		<style>
			input[type="file"] {
				display: none;
			}
			input[type="submit"] {
				display: none;
			}
			.custom-but {
				border: 1px solid #ccc;
				padding: 6px 12px;
				cursor: pointer;
				color: white;
			}
			.needed {
				background-color: #f44336; /* Red */
			}
			.accepted {
				background-color: #4CAF50; /* Green */
			}
			.optional {
				background-color: #ff9900; /* Orange */
			}
			.unselected {
				background-color: #424242; /* Grey */
			}

			div {
				display: inline-block;
			}

			.fileLabel {
				height: 100%;
				width: 120px;
				display: block;
			}

			.onLabel {
				opacity: 0.5;
    			filter: alpha(opacity=50); /* For IE8 and earlier */
			}

			#instructText {
				cursor: pointer;
				color: blue;
				text-decoration: underline;
				font-weight: bold;
			}

			.instructPanel {
				padding: 10px;
				text-align: justify;
				background-color: #f9deb8;
				position: absolute;

				height: 50px;
				width: 370px;

				visibility: hidden;
			}

			.leftPanel {
				border-left: 6px solid #aa977c;
				border-top: 2px solid grey;
				border-right: 2px solid grey;
				border-bottom: 2px solid grey;
				left: 50px;
			}

			.rightPanel {
				border-left: 2px solid grey;
				border-top: 2px solid grey;
				border-right: 6px solid #aa977c;
				border-bottom: 2px solid grey;
				right: 50px;
			}

			#instructMethod1 {
				top: 140px;
			}

			#instructMethod2 {
				top: 140px;
			}

			#instructQueries1 {
				top: 230px;
			}

			#instructQueries2 {
				top: 230px;
			}

			#instructQueriesFile {
				top: 320px;
			}

			#instructArchiveFile {
				top: 320px;
			}

			#instructPastFile {
				top: 430px;
			}
			#instructIgnoreFile {
				top: 430px;
			}
		</style>

		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>

		<script>

			var querySubmitted = false;
			var archiveSubmitted = false;

			var showInstruct = false;
			var showInstructQueries = false;
			var showInstructFiles = false;

			$(document).ready(function(){

				$('#subForm').css('display', 'none');
				$('#subHeader').css('visibility', 'hidden');

				$('#queriesChoice').css('visibility', 'hidden');

				$("#submitButton").attr('disabled', true);
				$("#submitLabel").css('cursor', 'default');

				$('#subArchive').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];

					if (fileName.length > 20)
						fileName = fileName.substring(0, 16) + "...";

					$('#subArchiveLabel').html("Archive File: <br>" + fileName);
					$('#subArchiveLabel').attr('class', 'fileLabel custom-but accepted');

					archiveSubmitted = true;

					if (querySubmitted) {
						$('#submitLabel').attr('class', 'fileLabel custom-but accepted');
						$("#submitLabel").css('cursor', 'pointer');
						$('#submitButton').attr('disabled', false);
					}
				});

				$('#queriesFile').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];

					if (fileName.length > 20)
						fileName = fileName.substring(0, 16) + "...";

					$('#queriesLabel').html("Queries File: <br>" + fileName);
					$('#queriesLabel').attr('class', 'fileLabel custom-but accepted');

					querySubmitted = true;

					if (archiveSubmitted) {
						$('#submitLabel').attr('class', 'fileLabel custom-but accepted');
						$("#submitLabel").css('cursor', 'pointer');
						$('#submitButton').attr('disabled', false);
					}
				});

				$('#pastFile').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];

					if (fileName.length > 20)
						fileName = fileName.substring(0, 16) + "...";

					$('#pastLabel').html("Past Archive File: <br>" + fileName);
					$('#pastLabel').attr('class', 'fileLabel custom-but accepted');

					$('#pastInput').val('TRUE');
				});

				$('#ignoreFile').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];

					if (fileName.length > 20)
						fileName = fileName.substring(0, 16) + "...";

					$('#ignoreLabel').html("Ignore List File: <br>" + fileName);
					$('#ignoreLabel').attr('class', 'fileLabel custom-but accepted');

					$('#ignoreInput').val('TRUE');
				});

				var $fileLabels = $('.fileLabel');
				var $queriesLabel = $('#queriesLabel');
				var $subArchiveLabel = $('#subArchiveLabel');
				var $pastLabel = $('#pastLabel');
				var $ignoreLabel = $('#ignoreLabel');

				$fileLabels.on('drop dragover dragenter', function(evt) {
					evt.preventDefault();
				});

				$queriesLabel.on('dragenter dragover', function(evt) {
					$queriesLabel.addClass('onLabel');
				});
				$subArchiveLabel.on('dragenter dragover', function(evt) {
					$subArchiveLabel.addClass('onLabel');
				});
				$pastLabel.on('dragenter dragover', function(evt) {
					$pastLabel.addClass('onLabel');
				});
				$ignoreLabel.on('dragenter dragover', function(evt) {
					$ignoreLabel.addClass('onLabel');
				});

				queriesLabel.ondrop = function(evt) {
				  queriesFile.files = evt.dataTransfer.files;
				  $queriesLabel.removeClass('onLabel');
				};
				subArchiveLabel.ondrop = function(evt) {
				  subArchive.files = evt.dataTransfer.files;
				  $queriesLabel.removeClass('onLabel');
				};
				pastLabel.ondrop = function(evt) {
				  pastFile.files = evt.dataTransfer.files;
				  $pastLabel.removeClass('onLabel');
				};
				ignoreLabel.ondrop = function(evt) {
				  ignoreFile.files = evt.dataTransfer.files;
				  $ignoreLabel.removeClass('onLabel');
				};

				$queriesLabel.on('dragleave dragend', function() {
				  $queriesLabel.removeClass('onLabel');
				});
				$subArchiveLabel.on('dragleave dragend', function() {
				  $subArchiveLabel.removeClass('onLabel');
				});
				$pastLabel.on('dragleave dragend', function() {
				  $pastLabel.removeClass('onLabel');
				});
				$ignoreLabel.on('dragleave dragend', function() {
				  $ignoreLabel.removeClass('onLabel');
				});
			});

			function withQueriesClick() {

				querySubmitted = false;
				archiveSubmitted = false;

				$('#queriesFile').val('');
				$('#queriesLabel').html('Upload <br> Queries File');
				$('#queriesLabel').attr('class', 'fileLabel custom-but needed');
				$('#subArchive').val('');
				$('#subArchiveLabel').html('Upload <br> Archive File');
				$('#subArchiveLabel').attr('class', 'fileLabel custom-but needed');
				$('#pastFile').val('');
				$('#pastLabel').html('Upload <br> Past Archive File');
				$('#pastLabel').attr('class', 'fileLabel custom-but optional');
				$('#ignoreFile').val('');
				$('#ignoreLabel').html('Upload <br> Ignore List File');
				$('#ignoreLabel').attr('class', 'fileLabel custom-but optional');

				$('#submitButton').attr('disabled', true);
				$('#submitLabel').css('cursor', 'default');
				$('#submitLabel').attr('class', 'fileLabel custom-but needed');

				$('#withQueriesBut').attr('class', 'custom-but accepted');
				$('#withoutQueriesBut').attr('class', 'custom-but unselected');

				$('#subHeader').css('visibility', 'visible');
				$('#subForm').css('display', 'inline-block');
				$('#queriesInfo').css('display', 'inline-block');
				$('#queriesInput').val('TRUE');
				$('#pastInput').val('FALSE');
				$('#ignoreInput').val('FALSE');

				showInstructFiles = true;

				if (showInstruct) {
					showInstruct = false;
					toggleInstruct();
				}
			};

			function withoutQueriesClick() {

				querySubmitted = true;
				archiveSubmitted = false;

				$('#queriesFile').val('');
				$('#subArchive').val('');
				$('#subArchiveLabel').html('Upload <br> Archive File');
				$('#subArchiveLabel').attr('class', 'fileLabel custom-but needed');
				$('#pastLabel').html('Upload <br> Past Archive File');
				$('#pastLabel').attr('class', 'fileLabel custom-but optional');
				$('#ignoreFile').val('');
				$('#ignoreLabel').html('Upload <br> Ignore List File');
				$('#ignoreLabel').attr('class', 'fileLabel custom-but optional');

				$('#submitButton').attr('disabled', true);
				$('#submitLabel').css('cursor', 'default');
				$('#submitLabel').attr('class', 'fileLabel custom-but needed');

				$('#withoutQueriesBut').attr('class', 'custom-but accepted');
				$('#withQueriesBut').attr('class', 'custom-but unselected');

				$('#subHeader').css('visibility', 'visible');
				$('#subForm').css('display', 'inline-block');
				$('#queriesInfo').css('display', 'none');
				$('#queriesInput').val('FALSE');
				$('#pastInput').val('FALSE');
				$('#ignoreInput').val('FALSE');

				showInstructFiles = true;

				if (showInstruct) {
					showInstruct = false;
					toggleInstruct();
				}
			};

			function withMOSSClick() {
				$('#queriesChoice').css('visibility', 'visible');
				$('#methodInput').val('1');
				$('#withMOSSBut').attr('class', 'custom-but accepted');
				$('#withWASTEBut').attr('class', 'custom-but unselected');

				showInstructQueries = true;

				if (showInstruct) {
					showInstruct = false;
					toggleInstruct();
				}
			};

			function withWASTEClick() {
				$('#queriesChoice').css('visibility', 'visible');
				$('#methodInput').val('2');
				$('#withWASTEBut').attr('class', 'custom-but accepted');
				$('#withMOSSBut').attr('class', 'custom-but unselected');

				showInstructQueries = true;

				if (showInstruct) {
					showInstruct = false;
					toggleInstruct();
				}
			};

			function toggleInstruct() {
				showInstruct = !showInstruct;

				if (showInstruct) {
					$('#instructText').css('color', '#4CAF50');
					$('#instructText').html('Hide instructions');

					$('#instructMethod1').css('visibility', 'visible');
					$('#instructMethod2').css('visibility', 'visible');

					if (showInstructQueries) {
						$('#instructQueries1').css('visibility', 'visible');
						$('#instructQueries2').css('visibility', 'visible');
					}

					if (showInstructFiles) {
						$('.instructPanel').css('visibility', 'visible');
					}
				}
				else {
					$('#instructText').css('color', '#f44336');
					$('#instructText').html('Show instructions');

					$('.instructPanel').css('visibility', 'hidden');
				}
			}

		</script>
	</head>

	<body>
		<div id="instructMethod1" class="instructPanel leftPanel">
			<b>DISPOSE MOSS</b> is based on the <a href="http://theory.stanford.edu/~aiken/publications/papers/sigmod03.pdf">winnowing algorithm</a> used in <a href="https://theory.stanford.edu/~aiken/moss/">MOSS</a>. Scoring is computed from consecutive fingerprints that are representative of document sections.
		</div>

		<div id="instructMethod2" class="instructPanel rightPanel">
			<b>DISPOSE WASTE</b> is based on the WASTK algorithm described <a href="https://www.hindawi.com/journals/sp/2017/7809047/">here</a>. Scoring is computed depending on the similarity of the source files' abstract syntax trees.
		</div>

		<div id="instructQueries1" class="instructPanel leftPanel">
			To utilize the "online-sourced evidence" features of DISPOSE, choose to use internet queries and upload a text document in the proper format described below.
		</div>

		<div id="instructQueries2" class="instructPanel rightPanel">
			To only compare your submissions amongst themselves, such as with a unique, in-house assignment, choose this option for faster and focused results.
		</div>

		<div id="instructQueriesFile" class="instructPanel leftPanel">
			Upload your internet queries file as a .txt file with each search query separated by a new line. One line per query. Each query can be multiple words long.
		</div>

		<div id="instructArchiveFile" class="instructPanel rightPanel">
			Upload your submissions as an archive file where the top-level of the directory is where each individual submission is located as either a folder or an archive file.
		</div>

		<div id="instructPastFile" class="instructPanel leftPanel">
			Use this optional archive file to include submissions from previous years. They will be separated into their own group which will not be scored against themselves.
		</div>

		<div id="instructIgnoreFile" class="instructPanel rightPanel">
			Use this optional file if you have provided source files for the students to use. Upload a .txt file where each line is the name of a source file to exclude from the scoring.
		</div>

		<center>
			<h1>Make your submissions here!</h1>

			<div id="instructText" onclick="toggleInstruct()">
				Show instructions
			</div>

			<br>
			<div id="methodChoice">
				<h3>Choose your comparison method:</h3>

				<button id="withMOSSBut" class="custom-but needed" onclick="withMOSSClick()">
					DISPOSE MOSS
				</button>
				<button id="withWASTEBut" class="custom-but needed" onclick="withWASTEClick()">
					DISPOSE WASTE
				</button>
			</div>
		</center>

		<center>
			<div id="queriesChoice">
				<h3>Choose your submission type:</h3>

				<button id="withQueriesBut" class="custom-but needed" onclick="withQueriesClick()">
					With Internet Queries
				</button>
				<button id="withoutQueriesBut" class="custom-but needed" onclick="withoutQueriesClick()">
					Without Internet Queries
				</button>
			</div>
		</center>

		<center>
	
			<form id="subForm" action="../cgi-bin/upload.pl" method="post" enctype="multipart/form-data">
				<!-- <fieldset>
					<legend>Queries</legend>
					<input type="text" name="queries1" />
					<input type="text" name="queries2" />
					<input type="text" name="queries3" />
					<input type="text" name="queries4" />
					<input type="text" name="queries5" />
				</fieldset>
				<br> -->

				<h3 id="subHeader">Required files:</h3>

				<div id="requiredFiles">
					<div id="queriesInfo">
						<label id="queriesLabel" for="queriesFile" class="custom-but needed fileLabel">
							Upload <br>
							Queries File
						</label>
						<input id="queriesFile" type="file" name="queries" />
					</div>
					<div id="archivesInfo">
						<label id="subArchiveLabel" for="subArchive" class="custom-but needed fileLabel">
							Upload <br>
							Archive File
						</label>
						<input id="subArchive" type="file" name="submissions" />
					</div>
				</div>

				<h3 id="optionsHeader">Optional files:</h3>
				<div id="optionalFiles">
					<div id="pastInfo">
						<label id="pastLabel" for="pastFile" class="custom-but needed fileLabel">
							Upload <br>
							Past Archive File
						</label>
						<input id="pastFile" type="file" name="pastArchive" />
					</div>
					<div id="ignoreInfo">
						<label id="ignoreLabel" for="ignoreFile" class="custom-but needed fileLabel">
							Upload <br>
							Ignore List File
						</label>
						<input id="ignoreFile" type="file" name="ignoreList" />
					</div>
				</div>

				<input type="hidden" name="email" value="<?php echo $_SESSION['email'] ?>">
				<input id="methodInput" type="hidden" name="method" value="1">
				<input id="queriesInput" type="hidden" name="queriesBool" value="NULL">
				<input id="pastInput" type="hidden" name="pastBool" value="NULL">
				<input id="ignoreInput" type="hidden" name="ignoreBool" value="NULL">

				<br><br>

				<label id='submitLabel' for='submitButton' class=" custom-but needed">
					Submit Job
				</label>
				<input type="submit" name="Submit" id="submitButton" />

			</form>
		</center>

	</body>
</html>