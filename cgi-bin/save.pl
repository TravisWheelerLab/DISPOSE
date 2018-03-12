#!/usr/bin/perl -w


# Usage: perl save.pl [user email]

use strict; 
use warnings;

use File::Copy::Recursive qw(dircopy);
use File::Copy;
use Archive::Zip;

my $email = $ARGV[0];

my ($day, $month, $year) = (localtime)[3,4,5];

my $folderName = "dispose_results_" . ($month+1) . '_' . $day . '_' . ($year+1900);

mkdir "../results/" . $email . "/offline/" . $folderName . "/results";
mkdir "../results/" . $email . "/offline/" . $folderName . "/workFiles/" . $email;
mkdir "../results/" . $email . "/offline/" . $folderName . "/results/" . $email . "/outFiles";
mkdir "../results/" . $email . "/offline/" . $folderName . "/results/css";
mkdir "../results/" . $email . "/offline/" . $folderName . "/results/img";
mkdir "../results/" . $email . "/offline/" . $folderName . "/results/js";

dircopy("../results/" . $email . "/outFiles", "../results/" . $email . "/offline/" . $folderName . "/results/" . $email . "/outFiles") or die ("$!\n");
dircopy("../workFiles/" . $email, '../results/' . $email . "/offline/" . $folderName . '/workFiles/' . $email) or die ("$!\n");

dircopy("../html/css", '../results/' . $email . "/offline/" . $folderName . '/results/css') or die ("$!\n");
dircopy("../html/img", '../results/' . $email . "/offline/" . $folderName . '/results/img') or die ("$!\n");
dircopy("../html/js", '../results/' . $email . "/offline/" . $folderName . '/results/js') or die ("$!\n");

copy("../results/" . $email . "/offline/results.php", "../results/" . $email . "/offline/" . $folderName . "/results/" . $email . "/results.php") or die ("$!\n");


my $zip = Archive::Zip->new();

$zip->addTree('../results/' . $email . "/offline/" . $folderName, $folderName );

$zip->writeToFileNamed('../results/' . $email . "/offline/" . $folderName . '.zip');

print($folderName . ".zip");
