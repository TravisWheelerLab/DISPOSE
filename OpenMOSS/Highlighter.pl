#!/usr/bin/perl

# Usage: perl Highlighter.pl [match file]

use warnings;
use strict;

my $file = $ARGV[0];

open(my $fh, "<", $file)
	or die "Failed to open file: '$file'!\n";

my ($name1, $name2) = split(/ /, <$fh>);

mkdir "outFiles" unless -d "outFiles";

my $outFile = "./outFiles/" . $name1 . "_" . $name2 . ".html";

open(my $fh2, ">", $outFile)
	or die "Failed to open file: '$outFile'!\n";

print($fh2 
"<html>
	<head>
		<title>DISPOSE Results</title>
		<link rel='stylesheet' type='text/css' href='style.css'>
	</head>
	<body>
	<h1><center>Matches for $name1 and $name2</center></h1>
	
	</body>
</html>");

close($fh2);