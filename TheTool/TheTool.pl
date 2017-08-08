#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [submissions archive file]

use warnings;
use strict;

my $queryFile = $ARGV[0];
my $submissions = $ARGV[1];

system("perl GithubGrabber2.pl $queryFile");
system("perl Unzipper.pl GithubResults 1 1 1");
system("perl Unzipper.pl $submissions 1 1 2");

my @nameFields = split('((\.[^.\s]+)+)$', $submissions, 2);

system("perl OpenMOSS.pl 1 $nameFields[0] GithubResults");

print("\n\n-----------------------------------------------\n\nYour final results can be found at results.html!\n");