#!/usr/bin/perl

# Usage: perl TokenJava.pl [java file]

use Regexp::Common qw /comment/;

my $file = $ARGV[0];

(my $name) = ($file =~ /\/.+\/(.+)\.java$/);

my $tokenFile = "./tokenFiles/" . $name . "_token" . ".java";

my $tokenizedStr;

open(my $fh, "<", $file)
	or die "Failed to open file: '$file'!\n";

open(my $fh2, ">", $tokenFile)
	or die "Failed to open file: '$tokenFile'!\n";

while(<$fh>)
{
	$_ =~ s/$RE{comment}{Java}//g; # Remove in-line comments
    $_ =~ s/\s+//g; # Remove whitespace
    $_ = lc $_; # All lowercase
    $tokenizedStr = $tokenizedStr . $_;
}

$tokenizedStr =~ s/$RE{comment}{Java}//g; # Remove multiline comments

print $fh2 $tokenizedStr;

close $fh;
close $fh2;

print $tokenFile;