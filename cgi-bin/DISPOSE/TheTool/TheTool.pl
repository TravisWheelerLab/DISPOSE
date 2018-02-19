#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [ignore file] [past file] [submissions archive file] [user]

use warnings;
use strict;

my $queryFile = $ARGV[0];
my $ignoreFile = $ARGV[1];
my $pastFile = $ARGV[2]; 
my $submissions = $ARGV[3];
my $user = $ARGV[4];
my $userFolder = "../../../workFiles/$user";

# ??? is the no file param set in upload.pl. Allows for files to be optional.
unless ($queryFile eq "???") {
	system("perl GithubGrabber3.pl $queryFile $userFolder");
	system("perl Unzipper.pl GithubResults 1 1 1 $userFolder $ignoreFile");
}
unless ($pastFile eq "???") {
	system("perl Unzipper.pl $pastFile 1 1 3 $userFolder $ignoreFile");
}
system("perl Unzipper.pl $submissions 1 1 2 $userFolder $ignoreFile");

(my $archiveDir, my $archiveExt) = ($submissions =~ /(.+)\.(.+)$/);

my $pastDir = "???";
my $pastExt;

unless ($pastFile eq "???") {
	($pastDir, $pastExt) = ($pastFile =~ /(.+)\.(.+)$/);
}

if ($queryFile eq "???") {
	system("perl OpenMOSS.pl 1 $archiveDir ??? $pastDir $userFolder $user");
}
else {
	system("perl OpenMOSS.pl 1 $archiveDir GithubResults $pastDir $userFolder $user");
}

print("\n\n-----------------------------------------------\n\nYour final results can be found at results.html!\n");