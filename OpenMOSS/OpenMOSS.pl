#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]


my $origin = $ARGV[0];

chdir($origin);

my @submissions = `ls`;

chdir("..");

mkdir "tokenFiles" unless -d "tokenFiles";
mkdir "printFiles" unless -d "printFiles";

foreach my $sub (@submissions) {
	system("perl Winnower.pl './$origin/$sub' 4");
}