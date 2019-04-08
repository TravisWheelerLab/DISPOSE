#! /usr/bin/perl

# Usage: perl GithubGrabber3.pl [query file] [user folder]

use warnings;
use strict;

use File::Path;
use JSON qw( decode_json );
use POSIX;

# Generate an API key here:
# https://console.developers.google.com/apis/credentials
my $key = "";

my $userFolder = $ARGV[1];

chdir("$userFolder");

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

	my $queryString = "https://www.googleapis.com/customsearch/v1?cx=005150125878125961181%3Aq543592oqsc&fields=items%2Fpagemap%2Fmetatags%2Fog%3Aurl%2CsearchInformation%2FtotalResults&siteSearch=github.com&key=$key&q=";

	foreach(@queryFields) {
		$queryString = "$queryString+$_";
	}

	my $resultIndex = 1;

	my $curPage = $queryString . "&start=" . $resultIndex;

	# my $rawJSONData = `curl '$queryString'`;
	# my $rawPerlData = decode_json($rawJSONData);

	# # Gets the number of search result pages
	# my $numPages = ceil($rawPerlData->{'searchInformation'}->{'totalResults'}/10);

	# ------

	my $numPages = 1; # Temp limiter

	for (my $i=1; $i <= $numPages; $i++) {
		print("\n<--------------------On page $i of $numPages--------------------> \n");
		$curPage = "$queryString&start=" . (($i-1)*10 + 1);
		print("$curPage\n");
		my $rawJSONData = `curl --referer dispose.cs.umt.edu "$curPage"`;
		my $rawPerlData = decode_json($rawJSONData);
		
		foreach my $result (@{$rawPerlData->{'items'}}) {

			# my $pageTest = $result->{'pagemap'};
			# my @metatagsTest = @{$pageTest->{'metatags'}};
			# my $urlTest = $metatagsTest[0];

			my $repoLink = @{$result->{'pagemap'}->{'metatags'}}[0]->{"og:url"};
			my $repoName = substr($repoLink, 19); # Start where "http://github.com/" ends
			print ("\n$repoName\n");

			if (defined $repositories{$repoName}) {
				print ("Already downloaded.\n");
			}
			else {
				$repositories{$repoLink} = 1;

				mkpath($repoName);
				chdir($repoName);
				system("curl -LOk https://github.com/$repoName/archive/master.zip");
				chdir("..");
				chdir("..");
			}
		}
	}
}