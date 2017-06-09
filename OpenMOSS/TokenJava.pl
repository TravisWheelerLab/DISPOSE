#!/usr/bin/perl

# Usage: perl TokenJava.pl [java file]

use Regexp::Common qw /comment/;
use Text::ParseWords;

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
    my @no_space = shellwords($_); # Removes spaces except in strings
    $_ = join "", @no_space;
    $_ = lc $_; # All lowercase
    $tokenizedStr = $tokenizedStr . $_;
}

$tokenizedStr =~ s/$RE{comment}{Java}//g; # Remove multiline comments

print $fh2 $tokenizedStr;

close $fh;
close $fh2;

print $tokenFile;