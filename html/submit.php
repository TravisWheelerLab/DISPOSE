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
				display: inline-block;
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
		</style>

		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>

		<script>


			var querySubmitted = false;
			var archiveSubmitted = false;

			$(document).ready(function(){

				$('#subForm').css('display', 'none');
				$('#subHeader').css('visibility', 'hidden');

				$("#submitButton").attr('disabled', true);
				$("#submitLabel").css('cursor', 'default');

				$('#subArchive').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];

					$('#subArchiveLabel').html(fileName);
					$('#subArchiveLabel').attr('class', 'custom-but accepted');

					archiveSubmitted = true;

					if (querySubmitted) {
						$('#submitLabel').attr('class', 'custom-but accepted');
						$("#submitLabel").css('cursor', 'pointer');
						$('#submitButton').attr('disabled', false);
					}
				});

				$('#queriesFile').bind('change', function() {
					var fileName = $(this).val();
					fileName = fileName.match(/[^\\/]+$/)[0];
					$('#queriesLabel').html(fileName);
					$('#queriesLabel').attr('class', 'custom-but accepted');

					querySubmitted = true;

					if (archiveSubmitted) {
						$('#submitLabel').attr('class', 'custom-but accepted');
						$("#submitLabel").css('cursor', 'pointer');
						$('#submitButton').attr('disabled', false);
					}
				})
			});

			function withQueriesClick() {

				querySubmitted = false;
				archiveSubmitted = false;

				$('#queriesFile').val('');
				$('#queriesLabel').html('Upload Queries File');
				$('#queriesLabel').attr('class', 'custom-but needed');
				$('#subArchive').val('');
				$('#subArchiveLabel').html('Upload Archive File');
				$('#subArchiveLabel').attr('class', 'custom-but needed');

				$('#submitButton').attr('disabled', true);
				$('#submitLabel').css('cursor', 'default');
				$('#submitLabel').attr('class', 'custom-but needed');

				$('#withQueriesBut').attr('class', 'custom-but accepted');
				$('#withoutQueriesBut').attr('class', 'custom-but needed');

				$('#subHeader').css('visibility', 'visible');
				$('#subForm').css('display', 'inline-block');
				$('#queriesInfo').css('display', 'inline-block');
				$('#queriesInput').val('TRUE');
			};

			function withoutQueriesClick() {

				querySubmitted = true;
				archiveSubmitted = false;

				$('#queriesFile').val('');

				$('#subArchive').val('');
				$('#subArchiveLabel').html('Upload Archive File');
				$('#subArchiveLabel').attr('class', 'custom-but needed');

				$('#submitButton').attr('disabled', true);
				$('#submitLabel').css('cursor', 'default');
				$('#submitLabel').attr('class', 'custom-but needed');

				$('#withoutQueriesBut').attr('class', 'custom-but accepted');
				$('#withQueriesBut').attr('class', 'custom-but needed');

				$('#subHeader').css('visibility', 'visible');
				$('#subForm').css('display', 'inline-block');
				$('#queriesInfo').css('display', 'none');
				$('#queriesInput').val('FALSE');
			};
		</script>
	</head>
	<body>
		<center>
			<h1>Make your submissions here!</h1>
			<h3>Choose your submission type:</h3>
		</center>

		<div id="queriesChoice">
			<center>
				<button id="withQueriesBut" class="custom-but needed" onclick="withQueriesClick()">
					With Internet Queries
				</button>
				<button id="withoutQueriesBut" class="custom-but needed" onclick="withoutQueriesClick()">
					Without Internet Queries
				</button>
			</center>
		</div>

		<br>

		<center>
			<h3 id="subHeader">Submit your files:</h3>
	
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

				<div id="queriesInfo">
					<label id="queriesLabel" for="queriesFile" class="custom-but needed">
						Upload Queries File
					</label>
					<input id="queriesFile" type="file" name="queries" />
				</div>
				

				<label id="subArchiveLabel" for="subArchive" class="custom-but needed">
					Upload Archive File
				</label>
				<input id="subArchive" type="file" name="submissions" />
				
				<input type="hidden" name="email" value="<?php echo $_SESSION['email'] ?>">
				<input id="queriesInput" type="hidden" name="queriesBool" value="NULL">

				<br><br>

				<label id='submitLabel' for='submitButton' class=" custom-but needed">
					Submit Job
				</label>
				<input type="submit" name="Submit" id="submitButton" />
			</form>
		</center>

	</body>
</html>