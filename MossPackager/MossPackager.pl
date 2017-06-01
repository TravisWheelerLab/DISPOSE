#!/usr/bin/perl

# Usage: perl MossPackager.pl [Unzipper single dir output] [Unzipper multiple dir output]

use strict;
use warnings;

use Cwd;
use File::Copy;

my $k_size = 3;

my $largeSubmission = $ARGV[0];
my $submissions = $ARGV[1];

my $curGroup = 0;
my $curAmount = $k_size;
my $curSub = -1;

my $groupFile = "Groups.txt";
my $fh;

chdir("$largeSubmission");

my @rawFiles = `ls`;
@rawFiles = sort { (split("_",$a))[0] <=> (split("_",$b))[0] } @rawFiles;


foreach (@rawFiles) {
    s/\s*$//;
    my $file = "$_";

    unless ($file eq "Directories.txt" or $file eq "Names.txt") {
        (my $sub) = ($file =~ /^(.*?)_/ );

        print("$file $sub $curSub $curGroup $curAmount \n");

        # Continue placing the submission files with the rest of the sub's files
        if ($sub eq $curSub) {
            move("$file","$curGroup/$file");
        }
        else {

            # Put the new submission in the same group
            if ($curAmount < $k_size) {
                $curAmount++;
                $curSub = $sub;
                move("$file","$curGroup/$file");

                open($fh, '>>', $groupFile) or die "Could not open file '$groupFile' $!";
                print($fh " $curSub"); # Add sub to group line
                if ($curAmount eq $k_size) {
                    print($fh "\n");
                }
                close($fh);
            }
            # Make a new group
            else {
                $curSub = $sub;
                $curGroup++;
                $curAmount = 1;
                system('mkdir', $curGroup);
                move("$file","$curGroup/$file");

                open($fh, '>>', $groupFile) or die "Could not open file '$groupFile' $!";
                print($fh "$curGroup $curSub"); # Add group to file
                close($fh);
            }
        }
    }
}
open($fh, '>>', $groupFile) or die "Could not open file '$groupFile' $!";
print($fh "\n");
close($fh);

chdir("..");

system("> results.txt"); # Clears our current results.txt file

for (my $i=1; $i <= $curGroup; $i++) {
    print("Comparing Group $i with MOSS\n");
    system("perl moss.pl -d -m 1000000 $largeSubmission" . "/$i/* $submissions" . "/*/* | tail -1 >> results.txt"); # Appends moss url results for each group
}