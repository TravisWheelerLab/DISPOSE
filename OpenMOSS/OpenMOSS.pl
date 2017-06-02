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
my $charIndex = 0;
my $minVal;
my $minPos;
my $hashVal;
my @hashWindow;
my %fingerprint;

# Initial window
for (my $i=1; $i < $WSIZE; $i = $i+1) {
	$kgram = substr($tokenLine, $charIndex, $KSIZE);
	# print("\n" . $kgram . " " . hash($kgram) . "\n");

	$hashVal = hash($kgram);
	push @hashWindow, $hashVal;
	$minVal = $hashVal;

	$charIndex = $charIndex+1;
}

while ($charIndex <= $lineSize-$KSIZE) {
	# Windowing
	$kgram = substr($tokenLine, $charIndex, $KSIZE);
	# print("\n" . $kgram . " " . hash($kgram) . "\n");

	$hashVal = hash($kgram);
	push @hashWindow, $hashVal;
	$minVal = $hashVal;
	$minPos = $charIndex;

	# foreach (@hashWindow) {
	#   print "$_ ";
	# }
	# print ("\n");

	# Winnowing
	for (my $i = 0; $i < $WSIZE; $i = $i+1) {
		if ($hashWindow[$WSIZE - $i - 1] < $minVal) {
			$minVal = $hashWindow[$WSIZE - $i - 1];
			$minPos = $charIndex - $i;
		}
	}

	unless (exists $fingerprint{$minPos}) {
		$fingerprint{$minPos} = $minVal;
		# print ($minVal . " " . $minPos . "\n");
	}

	$charIndex = $charIndex + 1;
	shift @hashWindow;
}

for my $key ( sort {$a<=>$b} keys %fingerprint) {
           print "\n($key)->($fingerprint{$key})";
}

print("\n");

# Hash function
sub hash {
	my $hash = 0;
	use integer;
	foreach(split //,shift) {
		$hash = 31*$hash+ord($_);
	}
	return $hash;
}