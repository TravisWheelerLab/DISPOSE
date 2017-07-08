#!/usr/bin/perl

# Usage: perl Winnower.pl [file] [window size] [count_hash] [token_pos hash]

package Winnower;

use warnings;
use strict;

use base 'Exporter';

our @EXPORT = qw(winnow binSearch);

sub winnow {
	my ($file, $WSIZE, $countHash, $posHash, $curLang) = @_;

	my $KSIZE = 5;
	my %seenHash;

	my @locArray = keys %$posHash;
	@locArray = sort { $a <=> $b } @locArray;

	(my $name) = ($file =~ /\/.+\/(.+)\..+/);
	(my $fullName) = ($file =~ /\/.+\/(.+\..+)/);

	my $printFile = "./printFiles/$curLang/" . $name . "_print.txt"; 

	# Grab version that's one line
	my $file_token = "./TokenFiles2/$curLang/" . $name . "_token2.txt";

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

			# if ($minVal == 42389382) {
			# 	print("Found one: $fullName\n");
			# }

			unless (exists $seenHash{$hashVal}) {	
				$countHash->{$hashVal} += 1;
				$seenHash{$hashVal} = 1;
			}

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

			# if ($minVal == 42389382) {
			# 	print("Found one: $fullName\n");
			# }

			unless (exists $seenHash{$hashVal}) {	
				$countHash->{$hashVal}++;
				$seenHash{$hashVal} = 1;
			}

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
		my $trueLoc = binSearch(\@locArray, $key);
		$trueLoc = $locArray[$trueLoc];
		# print ("$fingerprint{$key} $fullName $key $posHash->{$trueLoc}\n");
	    print $fh2 "$fingerprint{$key} \'$fullName\' $key $posHash->{$trueLoc}\n";
	}

	close $fh2;

	# my $size = keys %fingerprint;
	# print("\n" . $lineSize . " ". $size . "\n");
}
# Hash function
sub hash {
	my $hash = 0;
	use integer;
	foreach(split //,shift) {
		$hash = 31*$hash+ord($_);
	}
	return $hash;
}

# Binary search function
sub binSearch {
	
	my $found = 0;
	my $loc;

	my ($arrayRef, $searchVal) = @_;
	my @array =  @{ $arrayRef };

	my $highPos = scalar @array;
	my $lowPos = 0;
	my $midPos;

	while (!$found && $lowPos <= $highPos) {
	  $midPos = int(($lowPos + $highPos) / 2);
	  if ($searchVal == $array[$midPos]) {
	    $found = 1;
	    $loc = $midPos;
	  }

	  elsif ($searchVal < $array[$midPos]) {
	    $highPos = $midPos - 1;
	  }

	  else {
	    $lowPos = $midPos + 1;
	  }
	}

	if ($found) {
	  return $loc;
	}
	else {
	  return $lowPos; 
	}
}

1;