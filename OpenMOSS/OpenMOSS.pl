#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [window size]

use warnings;
use strict;

my $file1 = "2_0_combinecomponents.java";
my $file2 = "2_1_dfs.java";

my $KSIZE = 5;
my $WSIZE = $ARGV[0];

# Replace whitespace, capitalization, tokenize variables
my $file1_token = `perl TokenJava.pl $file1`; 
my $file2_token = `perl TokenJava.pl $file2`;

# Retrieve tokenized version of file
open(my $fh, "<", $file1_token)
	or die "Failed to open file: '$file1_token'!\n";
my $tokenLine = <$fh>;
my $lineSize = length($tokenLine);
close $fh;

my $kgram;
my $charIndex;
my $winIndex;
my $minVal;
my $minPos;
my @hashWindow;
my @fingerprint;
my @globPos;

# Winnowing
$charIndex = 0; # Position in file
$winIndex = 0; # Position in window

while ($charIndex < $lineSize-$KSIZE) {
	# Windowing
	$kgram = substr($tokenLine, $charIndex, $KSIZE);
	print("\n" . $kgram . " " . hash($kgram) . "\n");

	my $hashVal = hash($kgram);
	$hashWindow[$winIndex] = $hashVal;
	$winIndex = $winIndex + 1;
	$minVal = $hashVal;

	# Winnowing
	if ($winIndex == $WSIZE) {

		print ("\n");
		foreach (@hashWindow) {
		  print "$_ ";
		}
		print ("\n");

		for (my $i = $WSIZE-1; $i > 0; $i = $i-1) {
			if ($hashWindow[$i] < $minVal) {
				$minVal = $hashWindow[$i];
				$minPos = $charIndex - $i;
			}
		}
		unless ($charIndex ~~ @globPos) {
			push @fingerprint, $minVal;
			push @globPos, $charIndex;
		}
		$winIndex = 0;
	}
	$charIndex = $charIndex + 1;
}

print ("\n");
foreach (@fingerprint) {
  print "$_ ";
}
print ("\n");

print ("\n");
foreach (@globPos) {
  print "$_ ";
}
print ("\n");


# Hash function
sub hash {
	my $hash = 0;
	use integer;
	foreach(split //,shift) {
		$hash = 31*$hash+ord($_);
	}
	return $hash;
}