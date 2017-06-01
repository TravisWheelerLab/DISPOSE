#! /usr/bin/perl

# Usage: perl GithubGrabber2.pl [query file]

use warnings;
use strict;

use File::Path;
use JSON::Parse ':all';
use POSIX;

my $client_id = "657adaccd421d805fa12";
my $client_secret = "f99e3744393dc21379bcecb8018634af0a32480b";

my $queryFile = $ARGV[0];
my @queries;

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

	my $queryString = "https://api.github.com/search/repositories?client_id=$client_id&client_secret=$client_secret&per_page=100&q=";

	foreach(@queryFields) {
		$queryString = "$queryString+$_";
	}

	my $rawJSONData = `curl -H 'Accept: application/vnd.github.v3.json' '$queryString'`;
	my $rawPerlData = parse_json($rawJSONData);

	# Gets the number of search result pages
	my $numPages = ceil($rawPerlData->{'total_count'}/100);

	# ------

	$numPages = 1; # Temp limiter

	for (my $i=1; $i <= $numPages; $i++) {
		print("\n<--------------------On page $i of $numPages--------------------> \n");
		
		my $rawJSONData = `curl -H 'Accept: application/vnd.github.v3.json' "$queryString&page=$i"`;
		my $rawPerlData = parse_json($rawJSONData);
		
		foreach my $repo (@{$rawPerlData->{'items'}}) {

			my $repoName = $repo->{'full_name'};
			print ("\n$repoName\n");

			if (defined $repositories{$repoName}) {
				print ("Already downloaded.\n");
			}
			else {
				$repositories{$repoName} = 1;

				mkpath($repoName);
				chdir($repoName);
				system("curl -LOk https://github.com/$repoName/archive/master.zip");
				chdir("..");
				chdir("..");
			}
		}
	}
}