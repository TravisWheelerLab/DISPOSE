<?php
	session_start();
	require('./login/db.php');

	if ( $_SESSION['logged_in'] != 1 ) {
	  header("location: /login/index.php");    
	}
	else {

		if (isset($_SERVER['HTTPS'])) {
            $https = "https://";
        }
        else {
            $https = "http://";
        }

		if (isset($_SERVER['HTTP_REFERER'])) {
		  if ($_SERVER['HTTP_REFERER'] === $https.$_SERVER['SERVER_NAME'].'/submit.php') {
		  	$email = $_SESSION['email'];
			$result = $mysqli->query("UPDATE users SET last_job = CURRENT_TIMESTAMP WHERE email='$email'") or die($mysqli->error());
		  }
		  else {
		  	header("location: /submit.php");
		  }
		}
		else {
			header("location: /submit.php");
		}
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