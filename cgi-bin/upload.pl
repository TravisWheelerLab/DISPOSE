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


# Parse query params
my $query = new CGI;

my $queriesBool = $query->param("queriesBool");
my $queriesFile;
if ($queriesBool eq "TRUE") {
	$queriesFile = $query->param("queries");
}

my $pastBool = $query->param("pastBool");
my $pastFile;
if ($pastBool eq "TRUE") {
	$pastFile = $query->param("pastArchive");
}

my $ignoreBool = $query->param("ignoreBool");
my $ignoreFile;
if ($ignoreBool eq "TRUE") {
	$ignoreFile = $query->param("ignoreList");
}

my $subsFile = $query->param("submissions");
my $email = $query->param("email");


# Remove path from file names
if ( !$subsFile ) { print $query->header ( ); print "There was a problem uploading your archive (try a smaller file)."; exit; }

my ($name, $path, $ext) = fileparse ( $subsFile, '..*' ); 
$subsFile = $name . $ext;

if ($queriesBool eq "TRUE") {
	($name, $path, $ext) = fileparse ( $queriesFile, '..*' ); 
	$queriesFile = $name . $ext;
}

if ($pastBool eq "TRUE") {
	($name, $path, $ext) = fileparse ( $pastFile, '..*' ); 
	$pastFile = $name . $ext;
}

if ($ignoreBool eq "TRUE") {
	($name, $path, $ext) = fileparse ( $ignoreFile, '..*' ); 
	$ignoreFile = $name . $ext;
}


# Remove unsafe file characters
$subsFile =~ tr/ /_/;
$subsFile =~ s/[^$safe_filename_characters]//g;

if ($queriesBool eq "TRUE") {
	$queriesFile =~ tr/ /_/;
	$queriesFile =~ s/[^$safe_filename_characters]//g;
}
if ($pastBool eq "TRUE") {
	$pastFile =~ tr/ /_/;
	$pastFile =~ s/[^$safe_filename_characters]//g;
}
if ($ignoreBool eq "TRUE") {
	$ignoreFile =~ tr/ /_/;
	$ignoreFile =~ s/[^$safe_filename_characters]//g;
}
$email =~ tr/ /_/;
$email =~ s/[^$safe_filename_characters]//g;

# Check if the files contained all safe characters
if ( $subsFile =~ /^([$safe_filename_characters]+)$/ ) { $subsFile = $1; } else { die "Archive file contains invalid characters"; }
if ($queriesBool eq "TRUE") {
	if ( $queriesFile =~ /^([$safe_filename_characters]+)$/ ) { $queriesFile = $1; } else { die "Queries file contains invalid characters"; }
}
if ($pastBool eq "TRUE") {
	if ( $pastFile =~ /^([$safe_filename_characters]+)$/ ) { $pastFile = $1; } else { die "Past Archive file contains invalid characters"; }
}
if ($ignoreBool eq "TRUE") {
	if ( $ignoreFile =~ /^([$safe_filename_characters]+)$/ ) { $ignoreFile = $1; } else { die "Ignore List file contains invalid characters"; }
}
if ( $email =~ /^([$safe_filename_characters]+)$/ ) { $email = $1; } else { die "Invalid email"; } 
if ( Email::Valid->address( -address => $email, -mxcheck => 1 ) ) { $email = $email} else { die "Invalid email"; }


# Make working upload and output directories
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


# Upload files to directory
my $upload_fh;
if ($queriesBool eq "TRUE") {
	$upload_fh = $query->upload("queries");
}
my $upload_fh2 = $query->upload("submissions");
my $upload_fh3;
if ($ignoreBool eq "TRUE") {
	$upload_fh3 = $query->upload("ignoreList");
}
my $upload_fh4;
if ($pastBool eq "TRUE") {
	$upload_fh4 = $query->upload("pastArchive");
}


if ($queriesBool eq "TRUE") {
	open (UPLOADFILE, ">$upload_dir/$queriesFile") or die "$!";
	binmode UPLOADFILE;

	while ( <$upload_fh> ) { 
		print UPLOADFILE; 
	}
	close UPLOADFILE;
}
if ($pastBool eq "TRUE") {
	open (UPLOADFILE, ">$upload_dir/$pastFile") or die "$!";
	binmode UPLOADFILE;

	while ( <$upload_fh4> ) { 
		print UPLOADFILE; 
	}
	close UPLOADFILE;
}
if ($ignoreBool eq "TRUE") {
	open (UPLOADFILE, ">$upload_dir/$ignoreFile") or die "$!";
	binmode UPLOADFILE;

	while ( <$upload_fh3> ) { 
		print UPLOADFILE; 
	}
	close UPLOADFILE;
}

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

	if ($queriesBool eq "FALSE") {
		$queriesFile = "???";
	}
	if ($ignoreBool eq "FALSE") {
		$ignoreFile = "???";
	}
	if ($pastBool eq "FALSE") {
		$pastFile = "???";
	}

	chdir("./DISPOSE/TheTool");
	system("perl TheTool.pl $queriesFile $ignoreFile $pastFile $subsFile $email");

	chdir($cgibin);
	system("perl email.pl $email");
}

