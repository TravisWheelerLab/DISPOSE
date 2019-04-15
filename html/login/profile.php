<?php
session_start();

if ( $_SESSION['logged_in'] != 1 ) {
  $_SESSION['error'] = "You must log in before viewing your profile page!";
  header("location: index.php");    
}
else {
    $first_name = $_SESSION['first_name'];
    $last_name = $_SESSION['last_name'];
    $email = $_SESSION['email'];
    $active = $_SESSION['active'];
}
?>
<!DOCTYPE html>
<html >
<head>
  <meta charset="UTF-8">
  <title>DISPOSE | Profile</title>
  <?php include 'css/css.html'; ?>
</head>

<body>
  <a href="../../" class="linkout">&#8592; Home</a> 

  <div class="form">

          <h1>Profile</h1>
          
          <p>
          <?php 
          if ( isset($_SESSION['message']) )
          {
              echo $_SESSION['message'];
              unset( $_SESSION['message'] );
          }
          
          ?>
          </p>
          
          <?php
            if ( !$active ){
                echo
                '<div class="info">
                Account is unverified, please confirm your email!
                </div>';
            }
          ?>

          <p>
          <?php
            if ( isset($_SESSION['error']) )
            {
                echo '<div class="info">'.
                $_SESSION['error'].
                '</div>';
                
                unset( $_SESSION['error'] );
            }
          ?>
          </p>
          
          <h2><?php echo $first_name.' '.$last_name; ?></h2>
          <p><?= $email ?></p>

          <div class="butSpan">
            <a class="special" href="../submit.php"><button class="btn half-button" name="submitJob"/>Submit Job</button></a>
            <a class="special" href="../results.php"><button class="btn half-button test" name="results"/>Results</button></a>
          </div>

          <br><br>

          <a class="special" href="logout.php"><button class="button button-block" name="logout"/>Log Out</button></a>

    </div>
    
<script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js'></script>
<script src="js/index.js"></script>

</body>
</html>
