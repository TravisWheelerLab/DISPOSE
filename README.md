# DISPOSE

## Introduction

DISPOSE (Detecting Instances of Software Plagiarism from Online-Sourced Plagiarism) is an open-sourced software implementation of plagiarism detection algorithms originally proposed by [MOSS](http://theory.stanford.edu/~aiken/publications/papers/sigmod03.pdf) and [WASTK](https://www.hindawi.com/journals/sp/2017/7809047/). Furthermore, DISPOSE extends these ideas by providing a separated group framework for differently sourced material. This includes distinguishing those retrieved using [Github API](https://developer.github.com/v3/) or past submissions from previous course offerings. DISPOSE provides easy accessibility through usage of a web portal that can be accessed [online](https://dispose.cs.umt.edu/) or ran on a local server using this repository.

## Getting Started

DISPOSE is written using the following languages:
- Perl (5.26.1)
- Java (1.9)
- PHP (7.2.10)

In addition, the following Perl modules must be installed:
- CGI
- CGI::Carp
- File::Basename
- Email::Valid
- Cwd
- File::Path
- JSON
- POSIX
- Template
- HTML::Entities
- IO::Socket
- File::Copy
- List::MoreUtils
- File::Copy::Recursive
- File::Copy
- Archive::Zip

To use the web portal and user access system, first you must [set up an apache2 webserver](https://www.maketecheasier.com/setup-local-web-server-all-platforms/) on the desired machine. For user management, DISPOSE connects PHP requests using [mysqli](https://www.php.net/manual/en/book.mysqli.php) so MySQL must also be functioning in connection to your apache2 server. [Here](https://dev.mysql.com/doc/mysql-getting-started/en/) is a quick start guide for getting MySQL up and running.

Now you should have a web server running with DISPOSE cloned into the web server's main folder ('www' by default).
```
   % cd ~/www
   % git clone https://github.com/TravisWheelerLab/DISPOSE.git
``` 

 Navigate to the /sql/ folder and run the sql_import.php script to create the necessary MySQL tables. Please note that you should change the host, user, and password in the script to the proper credentials to connect to your database. 

```
   % cd ./sql/
   % vi sql_import.php
    
     3  // connection variables
     4  $host = 'localhost';
     5  $user = 'root';
     6  $password = 'mypass123';

   % php ./sql_import.php
```

 Likewise, these credentials need to be edited in /html/login/db.php to match.
```
   % cd ./cgi-bin/DISPOSE/GithubGrabber/
   % vi db.php
    
     3  $host = 'localhost';
     4  $user = 'root';
     5  $pass = 'mypass123';
```

Next, you'll have to set up a personal Google API key here:
https://console.developers.google.com/apis/credentials

Insert your generated key into GithubGrabber3.pl.
```
   % cd ./html/login/
   % vi GithubGrabber3.pl
    
     12  # Generate an API key here:
     13  # https://console.developers.google.com/apis/credentials
     14  my $key = "";
```

You can re-compile the WASTED jar by running the following:
```
   % cd ./cgi-bin/DISPOSE/WASTE
   % javac -cp "./project/lib/*" -d ./project/bin/ ./project/src/Java/*.java
   % jar cmf Manifest.txt WASTE.jar -C ./project/bin/ .
```

From here you should be ready to use DISPOSE! Launch your server:
```
   % sudo service apache2 start   (or 'sudo service httpd start' - depends on system)
   % sudo service mysql start
   (may also need to start sendmail)
```

Navigate to the homepage (localhost) in browser, create an account for your database using the sign-up form, and make a submission. Feel free to read the 'Help' page to learn the features of the submission portal and results output.

If your server has been additionally configured to be able to send emails, then the server will email the user's address when the results are ready to be viewed.
