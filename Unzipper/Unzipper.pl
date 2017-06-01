#!/usr/bin/perl

# Usage: perl Unzipper.pl [source archive file] [single_directory_flag]

use strict;
use warnings;
use Cwd;
use File::Copy;
use File::Find;
use File::Basename;
use File::Path qw(remove_tree);;

my $origin = $ARGV[0];
my $SINGLE_DIR = $ARGV[1];

my @targetTypes = ("rb", "scala", "py", "c", "h", "cpp", "java");
my @nameFields;

if (-d $origin) {
    $nameFields[0] = $origin;
}
else {
    handleArchive($origin);
}

chdir($nameFields[0]);
my @submissions = `ls`;

my $subIndex = 0; # Submission level
my $subIndex2 = 0; # File level


my $filename = 'Names.txt';
my $filename2 = 'Directories.txt';

foreach (@submissions) {
    system('mkdir', $subIndex);
    s/\s*$//; # Removes the newline character in the array elements
    move("$_", "$subIndex/$_");

    open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
    print($fh "$subIndex $_ \n"); # Add name to file
    close($fh);

    chdir($subIndex);
    
    my $foundMore = 1;
    my @moreArchives;
    
    # Looking for more archive files buried
    while($foundMore) {
        $foundMore = 0;
        @moreArchives = `find`;
        foreach(@moreArchives) {
            s/\s*$//;
            my $candidate = "$_";
            unless (-d $candidate) {
                my @testFields = split('((\.[^.\s]+)+)$', $candidate, 2);
                   if ($testFields[1] =~ m/(7z|zip|tar|gz|bz2)$/) {
                            handleArchive("$_");
                            system("rm -f \"$candidate\"");
                            $foundMore = 1;
                   }
            }
        }
    }
    
    my @rawFiles = `find`;

    # Getting target file type
    foreach (@rawFiles) {
        s/\s*$//;
        my $candidate = "$_";

        unless (-d $candidate) {

            # Separate file attributes
            (my $name, my $path, my $suffix) = fileparse($candidate,@targetTypes); # TODO: Make own regex to separate name. The suffix regex is bad.

            (my $ext) = ($candidate =~ /.+\.(.+)/ );
        
            foreach my $type (@targetTypes) {

                if ($suffix eq $type and $ext eq $type and -T $candidate) {
                    print($candidate . " " . " " . $name . " " . $suffix . " " . $type . "\n");

                    chdir("..");

                    open(my $fh2, '>>', $filename2) or die "Could not open file '$filename2' $!";
                    print($fh2 "$subIndex $subIndex2 $candidate \n");
                    close($fh2);

                    chdir($subIndex);

                    my $newName = $subIndex . "_" . $subIndex2 . "_" . $name . $suffix;

                    if ($SINGLE_DIR) {
                        chdir("..");
                        rename(getcwd . "/$subIndex/". substr($candidate,2), getcwd . "/$newName");
                        chdir($subIndex);
                    }
                    else {
                        rename($candidate, getcwd . "/$newName");
                    }
                    $subIndex2++;
               }
            }
       }
    }

    unless ($SINGLE_DIR) {
        # Removing everything that is not the target
        my @junk = `ls`;
        foreach(@junk) {
            s/\s*$//;
            if (-d "$_") {
                system("rm -rf \"$_\"");
            }
        }
    }

    chdir("..");

    if ($SINGLE_DIR) {
        remove_tree($subIndex);
    }

    $subIndex++;
    $subIndex2 = 0;
}

# System commands to extract different archive formats
sub handleArchive {

    my($archiveFile) = @_;

    @nameFields = split('((\.[^.\s]+)+)$', $archiveFile, 2);
    # print(@nameFields);

    system('mkdir', $nameFields[0]);

    if ($nameFields[1] =~ m/(zip)$/) {
        system('unzip', $archiveFile, '-d', $nameFields[0]);
    }
    elsif($nameFields[1] =~ m/(tar)$/) {
        system('tar -xvf', $archiveFile, $nameFields[0]);
    }
    elsif($nameFields[1] =~ m/(gz)$/) {
        system('tar -xzvf', $archiveFile, $nameFields[0]);
    }
    elsif($nameFields[1] =~ m/(bz2)$/) {
        system('tar -xjvf', $archiveFile, $nameFields[0]);
    } 
    elsif($nameFields[1] =~ m/(7z)$/) {
        print($archiveFile);
        system('7z', 'x', $archiveFile);
    }
    else {
        print("\nUnsupported archive format. \n
        Supported: 7z, zip, tar, tar.gz, tar.bz2 \n
        Received: $nameFields[1]\n");
    }
}