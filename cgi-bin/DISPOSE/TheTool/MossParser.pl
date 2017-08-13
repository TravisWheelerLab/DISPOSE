#!/usr/bin/perl

# Usage: perl MossParser.pl [MOSS results txt file] [Web Results dir] [submissions dir] [sub_results_flag]

use strict;
use warnings;


my $resultsFile = $ARGV[0];
my $webEntries = $ARGV[1];
my $subEntries = $ARGV[2];
my $subFlag = $ARGV[3];

my $finalFile = "FinalResults.txt";
system("> $finalFile"); # Clears our current results.txt file

my %matchURLs;
my %webNames;
my %webGroups;
my %subNames;

my @resultsURLs;


open(my $fh, "<", "$resultsFile")
    or die "Failed to open file: $!\n";
while(<$fh>) { 
    chomp; 
    push @resultsURLs, $_ . "/"; # Need the added '/' to properly point to the MOSS page
} 
close $fh;

open($fh, "<", "$webEntries" . "/Names.txt")
    or die "Failed to open file: $!\n";
while(<$fh>) { 
    $_ =~ m/^(.+?) (.+?) \n/;
    $webNames{$1} = $2;
} 
close $fh;

open($fh, "<", "$webEntries" . "/Groups.txt")
    or die "Failed to open file: $!\n";
while(<$fh>) { 
    $_ =~ m/^(.+?) (.+?)\n/;
    $webGroups{$1} = $2;
} 
close $fh;

open($fh, "<", "$subEntries" . "/Names.txt")
    or die "Failed to open file: $!\n";
while(<$fh>) { 
    $_ =~ m/^(.+?) (.+?) \n/;
    $subNames{$1} = $2;
} 
close $fh;

foreach my $resultsURL(@resultsURLs) {
	print("\n" . "$resultsURL" . "\n");
	my $mainPageSource = `curl $resultsURL`;

	while ($mainPageSource =~ m/<TR><TD>.+?HREF="(.+?)">(.+?)\/(.+?)\/ \((.+?)\).+?html">(.+?)\/(.+?)\/ \((.+?)\).+?right>(.+?)\n/sg) {
		if (defined $matchURLs{"$2 $3 $5 $6"}) {
			# print ("Already matched.\n");
		}
		else {
			print ("$2 $3 $5 $6 $1 $4 $7 $8\n");
			$matchURLs{"$2 $3 $5 $6"} = "$1 $4 $7 $8";
		}
	}

}

foreach my $matchID (sort { (split(" ",$matchURLs{$b}))[-1] <=> (split(" ",$matchURLs{$a}))[-1] } keys %matchURLs) {
    
	my @matchParams = split(" ",$matchID);
	my $name1 = "";
	my $name2 = "";
	my $mainGroup1 = $matchParams[0] . " " . $matchParams[1];
	my $mainGroup2 = $matchParams[2] . " " . $matchParams[3];
	my $subMembers1 = "";
	my $subMembers2 = "";

	# Transform groups into names
    if ($matchParams[0] eq $webEntries) {
    	my @memberIDs = split(" ", $webGroups{$matchParams[1]});
    	$subMembers1 = " (" . $webGroups{$matchParams[1]} . ")";

    	foreach my $memberID (@memberIDs) {
    		$name1 = $name1 . " " . "\"$webNames{$memberID}\"";
    		$name1 =~ s/^\s*(.*?)\s*$/$1/; # Removes leading space
    	}
    }
    # Transforms individuals into names
    else {
		$name1 = $subNames{$matchParams[1]};
    }
 
    if ($matchParams[2] eq $webEntries) {
    	my @memberIDs = split(" ", $webGroups{$matchParams[3]});
    	$subMembers2 = " (" . $webGroups{$matchParams[3]} . ")";

    	foreach my $memberID (@memberIDs) {
    		$name2 = $name2 . " " . $webNames{$memberID};
    		$name2 =~ s/^\s*(.*?)\s*$/$1/;
    	}
    }
    else {
		$name2 = $subNames{$matchParams[3]};
    }

    unless ($subFlag and "$matchParams[0] $matchParams[2]" eq "$subEntries $subEntries") {
		open($fh, '>>', $finalFile) or die "Could not open file '$finalFile' $!";
	    print ($fh "Matching: $mainGroup1$subMembers1 $mainGroup2$subMembers2" .
	    	  "\nNames: [$name1] [$name2]" .
	    	  "\nResults: $matchURLs{$matchID}" .
	    	  "\n\n\n");
		close($fh);
	}
}