#!/usr/bin/perl

# Usage: perl GithubGrabber.pl [query file]

use warnings;
use strict;

use File::Path;
use POSIX;

my $queryFile = $ARGV[0];
my @queries;
my $counter = 0;

open(my $fh, "<", "$queryFile")
    or die "Failed to open file: $!\n";
while(<$fh>) { 
    chomp; 
    push @queries, $_;
} 
close $fh;

my %repositories;

system('mkdir', "GithubResults");
chdir("GithubResults");

foreach my $query(@queries) {

	my @queryFields = split(' ', $query);

	my $queryString = "https://github.com/search?q=";

	foreach(@queryFields) {
		$queryString = "$queryString+$_";
	}

	# Gets the number of search result pages
	my $rawSource = `curl $queryString`;
	my $tempPageIndex = index($rawSource, "next_page") - 16;

	my $numPages = substr($rawSource, $tempPageIndex, 1);
	$tempPageIndex = $tempPageIndex - 1;
	my $potentialPageDigit = substr($rawSource, $tempPageIndex, 1);

	while ($potentialPageDigit =~ m{(\d)}) {
		$numPages = "$potentialPageDigit$numPages";
		$tempPageIndex = $tempPageIndex - 1;
		$potentialPageDigit = substr($rawSource, $tempPageIndex, 1);
	}
	# ------

	# $numPages = 5; # Temp limiter

	for (my $i=1; $i <= $numPages; $i++) {
		print("\n<--------------------On page $i of $numPages--------------------> \n");
		$rawSource = `curl "$queryString&p=$i"`;
		my $offset = 0;
		my $sourceFlag = "d-inline-block col-9 mb-1"; # locates where the repo's name can be found
		my $charOffset = 53; # offsets from flag to where the name starts
		my $nextRepoPos = index($rawSource, $sourceFlag, $offset) + $charOffset;
		
		# Building the repo sources' names
		while ($nextRepoPos != $charOffset-1) {
			my $repoName = "";
			my $nextRepoChar = substr($rawSource, $nextRepoPos, 1);
			
			my $tempRepoIndex = $nextRepoPos;
			while ($nextRepoChar ne "\"") {
				$repoName = "$repoName$nextRepoChar";
				$tempRepoIndex = $tempRepoIndex + 1;
				$nextRepoChar = substr($rawSource, $tempRepoIndex, 1);
			}
			print ("\n$repoName\n");

			if (defined $repositories{$repoName}) {
				print ("Already downloaded.\n");
			}
			else {
				$repositories{$repoName} = 1;

				mkpath($repoName);
				chdir($repoName);
				# system("curl -LOk https://github.com/$repoName/archive/master.zip");
				$counter++;

				chdir("..");
				chdir("..");
			}
			
			$offset = $nextRepoPos + 1;
			$nextRepoPos = index($rawSource, $sourceFlag, $offset) + $charOffset;
		}
		sleep(10);
	}
}

print($counter);