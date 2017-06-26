#!/usr/bin/perl

# Usage: perl TokenScraper.pl [token file] [token pos hash]

package TokenScraper;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(tokScrape);

sub tokScrape {
	my ($tokFile,$tokPos) = @_;

	(my $name) = ($tokFile =~ /\/.+\/(.+)\..+/);
	my $tokFile2 = "./TokenFiles2/Java8/" . $name . "2.txt";


	open(my $fh, "<", $tokFile)
			or die "Failed to open file: '$tokFile'!\n";

	open(my $fh2, ">", $tokFile2)
			or die "Failed to open file: '$tokFile2'!\n";

	my $curPos = 0;
	my $nextPart;

	while(<$fh>)
	{
		my @tokParams = ($_ =~ m/(.+) (.+) (.+) (.+)\n/);
		$tokPos->{$curPos} = $tokParams[2];
		# if ($tokParams[3] eq "IntegerLiteral") {
		# 	$nextPart  = "I";
		# }
		# else {
		$nextPart = $tokParams[0];
		# }
		$curPos += length($nextPart);
		print $fh2 ("$nextPart");
	}

	close $fh;
	close $fh2;
}


