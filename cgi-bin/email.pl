#!/usr/bin/perl
use strict;
use warnings;

# Usage: perl email.pl [user email]

my $email = $ARGV[0];


use Email::MIME;
my $message = Email::MIME->create(
  header_str => [
    From    => 'dispose.server@gmail.com',
    To      => $email,
    Subject => 'Your DISPOSE Results are waiting!',
  ],
  attributes => {
    encoding => 'quoted-printable',
    charset  => 'ISO-8859-1',
  },
  body_str => "Your results are waiting for you at: https://dispose.cs.umt.edu/$email/results.html \n",
);

use Email::Sender::Simple qw(sendmail);
sendmail($message);