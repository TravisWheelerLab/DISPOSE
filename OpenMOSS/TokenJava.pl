#!/usr/bin/perl

# Usage: perl TokenJava.pl [java file]

my $file = $ARGV[0];

(my $name) = ($file =~ /\/.+\/(.+)\.java$/);

my $tokenFile = "./tokenFiles/" . $name . "_token" . ".java";

open(my $fh, "<", $file)
	or die "Failed to open file: '$file'!\n";

open(my $fh2, ">", $tokenFile)
	or die "Failed to open file: '$tokenFile'!\n";

while(<$fh>)
{
    $_ =~ s/\s+//g; # Remove whitespace
    $_ = lc $_; # All lowercase
    print $fh2 $_;
}

close $fh;
close $fh2;

print $tokenFile;