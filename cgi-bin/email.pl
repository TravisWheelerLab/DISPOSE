#!/usr/bin/perl
use strict;
use warnings;

# Usage: perl email.pl [user email]

my $email = $ARGV[0];

system(" echo " . "Your results are waiting for you at: https://dispose.cs.umt.edu/$email/results.html" . " | mail -s 'Your DISPOSE Results are waiting!' " . "$email")