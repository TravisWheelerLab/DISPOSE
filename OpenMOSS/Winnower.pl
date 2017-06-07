#!/usr/bin/perl

# Usage: perl Winnower.pl [file] [window size]

use warnings;
use strict;

my $file = $ARGV[0];

my $KSIZE = 5;
my $WSIZE = $ARGV[1];

(my $name) = ($file =~ /\/.+\/(.+)\..+/);
(my $fullName) = ($file =~ /\/.+\/(.+\..+)/);

my $printFile = "./printFiles/" . $name . "_print.txt"; 

# Replace whitespace, capitalization, tokenize variables
my $file_token = `perl TokenJava.pl $file`;

# Retrieve tokenized version of file
open(my $fh, "<", $file_token)
	or die "Failed to open file: '$file_token'!\n";
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

if (defined $tokenLine) {

	# Sets window size to the maximum line length
	if ($lineSize-$KSIZE < $WSIZE) {
		$WSIZE = $lineSize-$KSIZE;
	}

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
}
else {
	print("Empty tokenized file: $file_token\n");
}

open(my $fh2, ">", $printFile)
	or die "Failed to open file: '$printFile'!\n";

for my $key (sort {$a<=>$b} keys %fingerprint) {
           print $fh2 "$fingerprint{$key} $fullName $key\n";
}

close $fh2;

# my $size = keys %fingerprint;
# print("\n" . $lineSize . " ". $size . "\n");

# Hash function
sub hash {
	my $hash = 0;
	use integer;
	foreach(split //,shift) {
		$hash = 31*$hash+ord($_);
	}
	return $hash;
}