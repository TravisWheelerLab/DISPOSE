<?php
	session_start();
?>

<!DOCTYPE html>
<html>
	<head>
		<title>DISPOSE | Home</title>
	</head>
	<body>
		<center>
			<h1>Welcome to DISPOSE!</h1>
			<h2>Detector of Instances of Software Plagiarism from Online-Sourced Evidence</h2>
		</center>
		<?php
			if ( $_SESSION['logged_in'] == 1 ) {
				echo "Welcome back, <a href='/login/profile.php'>" . $_SESSION['first_name'] . "</a>!";   
			}
			else {
				echo  "To get started, please <a href='/login/index.php'>log in.</a>";
			}
		?>
	</body>
</html>