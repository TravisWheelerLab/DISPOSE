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

Now you should have a web server running with DISPOSE cloned into the web server's main folder ('www' by default). Navigate to the /sql/ folder and run the sql_import.php script to create the necessary MySQL tables. Please note that you should change the host, user, and password in the script to the proper credentials to connect to your database. Likewise, these credentials need to be edited in /html/login/db.php to match.

From here you should be ready to use DISPOSE! Launch your server, navigate to the homepage, create an account for your database, and make a submission. If your server has been additionally configured to be able to send emails, then the server will email the user's address when the results are ready to be viewed.