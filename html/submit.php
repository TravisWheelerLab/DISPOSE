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
		$(document).ready(function(){

			$("#submitButton").attr('disabled', true);
			$("#submitLabel").css('cursor', 'default');
			var querySubmitted = false;
			var archiveSubmitted = false;

			$('#subArchive').bind('change', function() {
				var fileName = $(this).val();
				fileName = fileName.match(/[^\\/]+$/)[0];

				$('#subArchiveLabel').html(fileName);
				$('#subArchiveLabel').attr('class', 'custom-but');
				$('#subArchiveLabel').addClass('accepted');

				archiveSubmitted = true;

				if (querySubmitted) {
					$('#submitLabel').attr('class', 'custom-but');
					$('#submitLabel').addClass('accepted');
					$("#submitLabel").css('cursor', 'pointer');
					$('#submitButton').attr('disabled', false);
				}
			});

			$('#queriesFile').bind('change', function() {
				var fileName = $(this).val();
				fileName = fileName.match(/[^\\/]+$/)[0];
				$('#queriesLabel').html(fileName);
				$('#queriesLabel').attr('class', 'custom-but');
				$('#queriesLabel').addClass('accepted');

				querySubmitted = true;

				if (archiveSubmitted) {
					$('#submitLabel').attr('class', 'custom-but');
					$('#submitLabel').addClass('accepted');
					$("#submitLabel").css('cursor', 'pointer');
					$('#submitButton').attr('disabled', false);
				}
			})
		});
		</script>
	</head>
	<body>
		<center>
			<h1>Welcome to DISPOSE!</h1>
			<h2>Make your submissions here!</h2>
		</center>

		<center>
			<form action="../cgi-bin/upload.pl" method="post" enctype="multipart/form-data">
				<!-- <fieldset>
					<legend>Queries</legend>
					<input type="text" name="queries1" />
					<input type="text" name="queries2" />
					<input type="text" name="queries3" />
					<input type="text" name="queries4" />
					<input type="text" name="queries5" />
				</fieldset>
				<br> -->

				<label id="queriesLabel" for="queriesFile" class="custom-but needed">
					Upload Queries File
				</label>
				<input id="queriesFile" type="file" name="queries" />
				

				<label id="subArchiveLabel" for="subArchive" class="custom-but needed">
					Upload Archive File
				</label>
				<input id="subArchive" type="file" name="submissions" />
				
				<input type="hidden" name = "email" value="<?php echo $_SESSION['email'] ?>">

				<br><br>

				<label id='submitLabel' for='submitButton' class=" custom-but needed">
					Submit Job
				</label>
				<input type="submit" name="Submit" id="submitButton" />
			</form>
		</center>
	</body>
</html>