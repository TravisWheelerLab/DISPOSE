#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [submissions archive file] [user]

use warnings;
use strict;

my $queryFile = $ARGV[0];
my $submissions = $ARGV[1];
my $user = $ARGV[2];
my $userFolder = "../../../workFiles/$user";

# ??? is the no queries file param set in upload.pl. Allows for queries to be optional.
unless ($queryFile eq "???") {
	system("perl GithubGrabber3.pl $queryFile $userFolder");
	system("perl Unzipper.pl GithubResults 1 1 1 $userFolder");
}
system("perl Unzipper.pl $submissions 1 1 2 $userFolder");

(my $archiveDir, my $archiveExt) = ($submissions =~ /(.+)\.(.+)$/);

if ($queryFile eq "???") {
	system("perl OpenMOSS.pl 1 $archiveDir ??? $userFolder $user");
}
else {
	system("perl OpenMOSS.pl 1 $archiveDir GithubResults $userFolder $user");
}

print("\n\n-----------------------------------------------\n\nYour final results can be found at results.html!\n");