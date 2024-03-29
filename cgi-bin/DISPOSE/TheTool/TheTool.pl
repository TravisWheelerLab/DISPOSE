#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [ignore file] [past file] [submissions archive file] [user] [method] [decay] [ITF_flag]

use warnings;
use strict;

my $queryFile = $ARGV[0];
my $ignoreFile = $ARGV[1];
my $pastFile = $ARGV[2]; 
my $submissions = $ARGV[3];
my $user = $ARGV[4];
my $method = $ARGV[5];
my $decayFactor = $ARGV[6];
my $useITF = $ARGV[7];

my $userFolder = "../../../workFiles/$user";

# ??? is the no file param set in upload.pl. Allows for files to be optional.
unless ($queryFile eq "???") {
	chdir("../GithubGrabber");
	system("perl GithubGrabber3.pl $queryFile $userFolder");
	chdir("../Unzipper");
	system("perl Unzipper.pl GithubResults 1 1 1 $userFolder $ignoreFile");
}
unless ($pastFile eq "???") {
	chdir("../Unzipper");
	system("perl Unzipper.pl $pastFile 1 1 3 $userFolder $ignoreFile");
}

chdir("../Unzipper");
system("perl Unzipper.pl $submissions 1 1 2 $userFolder $ignoreFile");

(my $archiveDir, my $archiveExt) = ($submissions =~ /(.+)\.(.+)$/);

my $pastDir = "???";
my $pastExt;

unless ($pastFile eq "???") {
	($pastDir, $pastExt) = ($pastFile =~ /(.+)\.(.+)$/);
}
if ($method eq "1") {
	if ($queryFile eq "???") {
		chdir("../OpenMOSS");
		system("perl OpenMOSS.pl 1 $archiveDir ??? $pastDir $userFolder $user");
	}
	else {
		chdir("../OpenMOSS");
		system("perl OpenMOSS.pl 1 $archiveDir GithubResults $pastDir $userFolder $user");
	}
}

elsif ($method eq "2") {
	if ($queryFile eq "???") {
		chdir("../WASTE");
		system("perl WASTEWrapper.pl $archiveDir ??? $pastDir $userFolder $user $decayFactor $useITF");
	}
	else {
		chdir("../WASTE");
		system("perl WASTEWrapper.pl $archiveDir GithubResults $pastDir $userFolder $user $decayFactor $useITF");
	}
}

print("\n\n-----------------------------------------------\n\nYour final results can be found at results.html!\n");