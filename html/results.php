<?php
	error_reporting(E_ERROR | E_PARSE);

	session_start();
	require('./login/db.php');

	if ( $_SESSION['logged_in'] != 1 ) {
	  $_SESSION['error'] = "You must log in to view your results!";
	  header("location: /login/index.php");    
	}
	else {

	    $first_name = $_SESSION['first_name'];
	    $last_name = $_SESSION['last_name'];
	    $email = $_SESSION['email'];
	    $active = $_SESSION['active'];

		if (file_exists('../results/'.$email.'/results.php') == false) {
			$_SESSION['error'] = "No submission results waiting!";
		  	header("location: /login/profile.php");
		}
	}

	$lang = $_GET['lang'];
	$type = $_GET['type'];
	$id = $_GET['id'];

    if (isset($id)) {
    	if (isset($type)) {
    		include('../results/'.$email.'/outFiles/'.$lang.'/match'.$id."_".$type.".html");
    	}
    	else {
    		include('../results/'.$email.'/outFiles/'.$lang.'/match'.$id."_match.html");
    	}
    }
    else {
    	include('../results/'.$email.'/results.php');
    }
?>