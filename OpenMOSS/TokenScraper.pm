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

	while(<$fh>)
	{
		my @tokParams = ($_ =~ m/(.+) (.+) (.+) (.+)$/);
		$tokPos->{$tokParams[1]} = $tokParams[2];
		print $fh2 ("$tokParams[0]");
	}

	close $fh;
	close $fh2;
}


