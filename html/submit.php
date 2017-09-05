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
	</head>
	<body>
		<center>
			<h1>Welcome to DISPOSE!</h1>
			<h2>Make your submissions here!</h2>
		</center>
		<form action="../cgi-bin/upload.pl" method="post" enctype="multipart/form-data">
			<p>Queries file: <input type="file" name="queries" /></p>
			<p>Submissions archive: <input type="file" name="submissions" /></p>
			<input type="hidden" name = "email" value="<?php echo $_SESSION['email'] ?>">
			<p><input type="submit" name="Submit" value="Submit Form" /></p>
		</form>
	</body>
</html>