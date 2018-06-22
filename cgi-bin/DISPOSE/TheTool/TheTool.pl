#!/usr/bin/perl

# Usage: perl TheTool.pl [queries file] [ignore file] [past file] [submissions archive file] [user] [method]

use warnings;
use strict;

use Cwd qw(getcwd);
use Template;

my $queryFile = $ARGV[0];
my $ignoreFile = $ARGV[1];
my $pastFile = $ARGV[2]; 
my $submissions = $ARGV[3];
my $user = $ARGV[4];
my $method = $ARGV[5];
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
if ($method eq "1") {
	if ($queryFile eq "???") {
		system("perl OpenMOSS.pl 1 $archiveDir ??? $pastDir $userFolder $user");
	}
	else {
		system("perl OpenMOSS.pl 1 $archiveDir GithubResults $pastDir $userFolder $user");
	}
}

elsif ($method eq "2") {
	mkdir "$userFolder\/matchFiles2" unless -d "$userFolder\/matchFiles2";
	system("java -jar WASTE.jar $archiveDir $userFolder");

	my @langs = `find $userFolder\/$archiveDir -mindepth 1 -maxdepth 1 -type d | awk -F"/" '{print \$NF}'`;
	chomp @langs;
	my $curLang = "Java";

	my @matchFiles = `ls $userFolder\/matchFiles2`;

	my $matchIndex = 0;
	my @suspects_hashes;

	my $origin = $archiveDir;
	my $originsGroup = 2;
	my $sourcesGroup = 999;
	my $sourcesDir;

	my $mainDir = getcwd;

	chdir($userFolder);

	my $workDir = getcwd;

	unless ($queryFile eq "???") {
		$sourcesDir = "GithubResults";
		$sourcesGroup = 1;
	}

	my $pastGroup = 998;
	unless ($pastDir eq "???") {
		$pastGroup = 3;
	}

	my $tempFolder = "../../cgi-bin/DISPOSE/TheTool/templates/";

	my $fileTemp = $tempFolder . "suspectsTemp.php";
	my $mainOut = "../../results/$user/results.php";


	# Prepare to recreate file names
	my %dirLookup;
	my %nameLookup;

	my $dirNumFile = "./$origin/Directories.txt";
	my $nameNumFile = "./$origin/Names.txt";

	open(my $fh3, $dirNumFile)
		or die "Failed to open file: '$dirNumFile'!\n";
	open(my $fh4, $nameNumFile)
		or die "Failed to open file: '$nameNumFile'!\n";

	while (<$fh4>) {
		my ($subNum, $subName) = ($_ =~ /(.*?) (.+)/);
		$subName =~ s/^\s+|\s+$//g;

		$nameLookup{$subNum} = $subName;
	}
	close $fh4;

	while (<$fh3>) {
		my ($subNum, $fileNum, $filePath) = ($_ =~ /(.*?) (.*?) \.\/(.+)/);
		$filePath =~ s/^\s+|\s+$//g;
		$dirLookup{$subNum}{$fileNum} = "./$origin/" . $nameLookup{$subNum} . "/$filePath";
	}
	close $fh3;

	my %dirLookup2;
	my %nameLookup2;

	# Sources
	if (-f "./$sourcesDir/Directories.txt") {

		my $dirNumFile = "./$sourcesDir/Directories.txt";
		my $nameNumFile = "./$sourcesDir/Names.txt";

		open(my $fh3, $dirNumFile)
			or die "Failed to open file: '$dirNumFile'!\n";
		open(my $fh4, $nameNumFile)
			or die "Failed to open file: '$nameNumFile'!\n";

		while (<$fh4>) {
			my ($subNum, $subName) = ($_ =~ /(.*?) (.+)/);
			$subName =~ s/^\s+|\s+$//g;

			$nameLookup2{$subNum} = $subName;
		}
		close $fh4;

		while (<$fh3>) {
			my ($subNum, $fileNum, $filePath) = ($_ =~ /(.*?) (.*?) \.\/(.+)/);
			$filePath =~ s/^\s+|\s+$//g;
			$dirLookup2{$subNum}{$fileNum} = "./$sourcesDir/" . $nameLookup2{$subNum} . "/$filePath";
		}
		close $fh3;
	}

	my %dirLookup3;
	my %nameLookup3;

	# Past Sources
	if (-f"./$pastDir/Directories.txt") {

		my $dirNumFile = "./$pastDir/Directories.txt";
		my $nameNumFile = "./$pastDir/Names.txt";

		open(my $fh5, $dirNumFile)
			or die "Failed to open file: '$dirNumFile'!\n";
		open(my $fh6, $nameNumFile)
			or die "Failed to open file: '$nameNumFile'!\n";

		while (<$fh6>) {
			my ($subNum, $subName) = ($_ =~ /(.*?) (.+)/);
			$subName =~ s/^\s+|\s+$//g;

			$nameLookup3{$subNum} = $subName;
		}
		close $fh4;

		while (<$fh5>) {
			my ($subNum, $fileNum, $filePath) = ($_ =~ /(.*?) (.*?) \.\/(.+)/);
			$filePath =~ s/^\s+|\s+$//g;
			$dirLookup3{$subNum}{$fileNum} = "./$pastDir/" . $nameLookup3{$subNum} . "/$filePath";

			print($dirLookup3{$subNum}{$fileNum} . "\n");
		}
		close $fh5;
	}


	foreach my $matchFile (@matchFiles) {
		chdir($mainDir);

		$matchFile = $userFolder . "/matchFiles2/" . $matchFile;
		chomp($matchFile);
		system("perl Highlighter2.pl $matchFile $matchIndex nohbodyz\@gmail.com Java");


		open(my $fh, "<", $matchFile)
			or die "Failed to open file: '$matchFile'!\n";

		my ($name1, $temp1, $name2, $temp2, $score) = (<$fh> =~ /'(.+)' '(.+)' '(.+)' '(.+)' '(.+)'/);
		$score =~ s/^\s+|\s+$//g;

		# Recreate file names
		my ($groupNum1, $subNum, $dirNum, $origName) = ($name1 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		
		my $fullName1;
		my $fullName2;
		my $dirName1;
		my $dirName2;

		if ($groupNum1 eq $sourcesGroup) {
			$fullName1 = $dirLookup2{$subNum}{$dirNum};
			$dirName1 = "./$sourcesDir/$curLang/$name1";
		}
		elsif ($groupNum1 eq $originsGroup) {
			$fullName1 = $dirLookup{$subNum}{$dirNum};
			$dirName1 = "./$origin/$curLang/$name1";
		}
		else {
			$fullName1 = $dirLookup3{$subNum}{$dirNum};
			$dirName1 = "./$pastDir/$curLang/$name1";
		}

		my ($groupNum2, $subNum2, $dirNum2, $origName2) = ($name2 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		if ($groupNum2 eq $sourcesGroup) {
			$fullName2 = $dirLookup2{$subNum2}{$dirNum2};
			$dirName2 = "./$sourcesDir/$curLang/$name2";
		}
		elsif ($groupNum2 eq $originsGroup) {
			$fullName2 = $dirLookup{$subNum2}{$dirNum2};
			$dirName2 = "./$origin/$curLang/$name2";
		}
		else {
			$fullName2 = $dirLookup3{$subNum2}{$dirNum2}; #idk
			$dirName2 = "./$pastDir/$curLang/$name2";
		}

		my $authName1;
		my $authName2;

		# Captures the second folder in the full path name
		($authName1) = ($fullName1 =~ /\.\/.*?\/(.*?)\//);
		($authName2) = ($fullName2 =~ /\.\/.*?\/(.*?)\//);

		# Shortens arbitrary string to 20 chars
		$authName1 =~ s/.{20}\K.*//s;
		$authName2 =~ s/.{20}\K.*//s;

		push (@suspects_hashes, {file1 => $name1, file2 => $name2, srcType1 => $groupNum1, srcType2 => $groupNum2, 
			fullName1 => $fullName1, fullName2 => $fullName2, matchNum => $score, matchIndex => $matchIndex, lang => $curLang,
			authName1 => $authName1, authName2 => $authName2, dirName1 => $dirName1, dirName2 => $dirName2});

		
		$matchIndex++;
	}

	chdir($workDir);
	

	my $vars = {
      matches => \@suspects_hashes,
      langs => \@langs,
      tempFolder => $tempFolder,
      user => $user
	};

	my $template = Template->new(RELATIVE => 1);
	$template->process($fileTemp, $vars, $mainOut)
	    || die "Template process failed: ", $template->error(), "\n";

	my $fileTemp2 = $tempFolder . "suspectsTemp.html";
	my $mainOut2 = "../../results/$user/offline/results.html";

	mkdir "../../results/$user/offline" unless -d "../../results/$user/offline";

	my $template2 = Template->new(RELATIVE => 1);
	$template2->process($fileTemp2, $vars, $mainOut2)
		|| die "Template process failed: ", $template2->error(), "\n";


	print ("\n");
}

print("\n\n-----------------------------------------------\n\nYour final results can be found at results.html!\n");