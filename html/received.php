<?php
	session_start();
	require('./login/db.php');

	if ( $_SESSION['logged_in'] != 1 ) {
	  header("location: /login/index.php");    
	}
	else {
    	$email = $_SESSION['email'];
		$result = $mysqli->query("UPDATE users SET last_job = CURRENT_TIMESTAMP WHERE email='$email'") or die($mysqli->error());
	}
?>

<!DOCTYPE html>
<html>
	<head>
		<title>DISPOSE | Received</title>
	</head>
	<body>
		<center>
			<h1>Welcome to DISPOSE!</h1>
			<h2>Detector of Instances of Software Plagiarism from Online-Sourced Evidence</h2>
		<p>Your request has been entered. You will receive an email when your results are ready.
		</center>
	</body>
</html>