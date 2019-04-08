#! /usr/bin/perl

# Usage: perl FinalResulter.pl [results file]

use warnings;
use strict;

my $resultsFile = $ARGV[0];
my @results;

my $outputFile = "FinalResults.html";

# Clear contents
open(my $fh2, ">", $outputFile)
	or die "Failed to open file: '$outputFile'!\n";

open($fh2, ">>", $outputFile)
	or die "Failed to open file: '$outputFile'!\n";

print($fh2 
	"<html>
	<head>
		<title>DISPOSE Results</title>
		<link rel='stylesheet' type='text/css' href='style.css'>
	</head>
	<body>
	<br>
	<h1>Your DISPOSE Results</h1>
	<div class='result'>
		<h2>Example</h2>
		<div class='resultMatch'><b>Matching:</b> FileBatch ID (group members) FileBatch2 ID (group members)</div>
		<div class='resultNames'><b>Names:</b> [members of group 1] [members of group 2]</div>
		<div class='resultStats'><b>Results:</b> [MOSS context link] [% lines matched group 1] [% lines matched group 2] [# lines matched]</div>
	</div>
	<h2>Potential Hits</h2>
	");
close($fh2);


local $/ = ""; # Sets fh to read by paragraph

open(my $fh, "<", "$resultsFile")
    or die "Failed to open file: '$resultsFile'!\n";
while(<$fh>) { 
	chomp;
	$_ =~ m/^.+?: (.+?)\n.+?\[(.+?)\].+\[(.+?)\]\n.+?: (.+?)$/;

	(my $matchLink, my $otherStats) = split(' ', $4, 2);

	open($fh2, ">>", $outputFile)
		or die "Failed to open file: '$outputFile'!\n";
	print($fh2 
	"<div class='result'>
		<div class='resultMatch'><b>Matching:</b> $1</div>
		<div class='resultNames'><b>Names:</b> [$2] [$3]</div>
		<div class='resultStats'><b>Results:</b> <a href='$matchLink'>Context</a> $otherStats</div>
	</div>
	<br>");
} 
close $fh;

open($fh2, ">>", $outputFile)
	or die "Failed to open file: '$outputFile'!\n";
print($fh2 "</body>\n</html>");
close($fh2);