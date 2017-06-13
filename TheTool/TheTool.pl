#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [submissions archive file]

use warnings;
use strict;

my $queryFile = $ARGV[0];
my $submissions = $ARGV[1];

system("perl GithubGrabber2.pl $queryFile");
system("perl Unzipper.pl GithubResults 1 0");
system("perl Unzipper.pl $submissions 0 0");
system("perl MossPackager.pl GithubResults submissions");
system("perl MossParser.pl results.txt GithubResults submissions 1");
system("perl FinalResulter.pl FinalResults.txt");

print("\n\n-----------------------------------------------\n\nYour final results can be found at FinalResults.html!\n");