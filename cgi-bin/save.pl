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

copy("../results/" . $email . "/offline/results.html", "../results/" . $email . "/offline/" . $folderName . "/results/" . $email . "/results.html") or die ("$!\n");


# Create shortcut to results main page
my $shortcut = '../results/'. $email . '/offline/'. $folderName . '/results.html';
open(my $fh, '>', $shortcut) or die "Could not open file: '$shortcut' $!";

my $page_html = <<END;
<!DOCTYPE HTML>
<html lang="en-US">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="refresh" content="0; url=./results/$email/results.html">
        <script type="text/javascript">
            window.location.href = "./results/$email/results.html";
        </script>
        <title>Page Redirection</title>
    </head>
    <body>
        If you are not redirected automatically, follow this: <a href='./results/$email/results.html'>link to results</a>.
    </body>
</html>
END
print $fh $page_html;
close $fh;


# Compress the offline results in a zip archive
my $zip = Archive::Zip->new();

$zip->addTree('../results/' . $email . "/offline/" . $folderName, $folderName );

$zip->writeToFileNamed('../results/' . $email . "/offline/" . $folderName . '.zip');

print($folderName . ".zip");
