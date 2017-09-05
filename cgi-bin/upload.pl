#!/usr/bin/perl -w

use strict; 
use warnings;

use CGI; 
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use Email::Valid;
use Cwd;


$CGI::POST_MAX = 1024 * 5000 * 500; # 500 MB limit
my $safe_filename_characters = "a-zA-Z0-9_.-@";

my $query = new CGI;
my $queriesFile = $query->param("queries");
my $subsFile = $query->param("submissions");
my $email = $query->param("email");

if ( !$subsFile ) { print $query->header ( ); print "There was a problem uploading your archive (try a smaller file)."; exit; }

my ($name, $path, $ext) = fileparse ( $subsFile, '..*' ); 
$subsFile = $name . $ext;

($name, $path, $ext) = fileparse ( $queriesFile, '..*' ); 
$queriesFile = $name . $ext;

$subsFile =~ tr/ /_/;
$subsFile =~ s/[^$safe_filename_characters]//g;
$queriesFile =~ tr/ /_/;
$queriesFile =~ s/[^$safe_filename_characters]//g;
$email =~ tr/ /_/;
$email =~ s/[^$safe_filename_characters]//g;

if ( $subsFile =~ /^([$safe_filename_characters]+)$/ ) { $subsFile = $1; } else { die "Archive file contains invalid characters"; }
if ( $queriesFile =~ /^([$safe_filename_characters]+)$/ ) { $queriesFile = $1; } else { die "Queries file contains invalid characters"; }
if ( $email =~ /^([$safe_filename_characters]+)$/ ) { $email = $1; } else { die "Invalid email"; } 
if ( Email::Valid->address( -address => $email, -mxcheck => 1 ) ) { $email = $email} else { die "Invalid email"; }

my $upload_dir = "../workFiles/" . $email;
my $output_dir = "../results/" . $email;

if (-d $upload_dir) {
	system("rm -rf $upload_dir");
}
if (-d $output_dir) {
	system("rm -rf $output_dir");
}

mkdir $upload_dir unless -d $upload_dir;
mkdir $output_dir unless -d $output_dir;

my $upload_fh = $query->upload("queries");
my $upload_fh2 = $query->upload("submissions");

open (UPLOADFILE, ">$upload_dir/$queriesFile") or die "$!";
	binmode UPLOADFILE;

	while ( <$upload_fh> ) { 
		print UPLOADFILE; 
	}
close UPLOADFILE;

open (UPLOADFILE, ">$upload_dir/$subsFile") or die "$!";
	binmode UPLOADFILE;

	while ( <$upload_fh2> ) { 
		print UPLOADFILE; 
	}
close UPLOADFILE;

if (fork()){
   print("Location: ../received.php\n\n"); 
   exit 0;
} else {
	close(STDOUT); close(STDIN); close(STDERR);

	my $cgibin = getcwd();

	chdir("./DISPOSE/TheTool");
	system("perl TheTool.pl $queriesFile $subsFile $email");

	chdir($cgibin);
	system("perl email.pl $email");
}

