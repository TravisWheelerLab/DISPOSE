#!/usr/bin/perl

# Usage: perl Highlighter.pl [file1] [file2]

use warnings;
use strict;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

(my $name1) = ($file1 =~ /\/.+\/(.+\..+)/);
(my $name2) = ($file2 =~ /\/.+\/(.+\..+)/);

mkdir "outFiles" unless -d "outFiles";

my $outFile = "./outFiles/" . $name1 . "_" . $name2 . ".html";

open(my $fh, ">", $outFile)
	or die "Failed to open file: '$outFile'!\n";

print($fh 
"<html>
	<head>
		<title>DISPOSE Results</title>
		<link rel='stylesheet' type='text/css' href='style.css'>
	</head>
	<body>
	<h1><center>Matches for $name1 and $name2</center></h1>
	
	</body>
</html>");

close($fh);