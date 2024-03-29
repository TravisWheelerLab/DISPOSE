#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [internal_flag] [file_dir detect] [file_dir sources] [file_dir past] [user folder] [user]

use warnings;
use strict;

use List::MoreUtils qw(uniq);
use Cwd qw(getcwd);
use lib '.';
use Winnower;
use TokenScraper;
use Template;

my $INT_FLAG = $ARGV[0];
my $userFolder = $ARGV[4];
my $user = $ARGV[5];

my $origin = $ARGV[1];
my $originsGroup = 2;
my $sourcesGroup = 999;
my $sourcesDir = "";

unless ($ARGV[2] eq "???") {
	$sourcesDir = $ARGV[2];
	$sourcesGroup = 1;
}

my $pastGroup = 998;
my $pastDir = "";
unless ($ARGV[3] eq "???") {
	$pastDir = $ARGV[3];
	$pastGroup = 3;
}

my $matchLim = 10;
my $KSIZE = 5;
my $MINRUN = 3;

my $mainDir = getcwd;
chdir($userFolder);
my $workDir = getcwd;

mkdir "TokenFiles" unless -d "TokenFiles";
mkdir "TokenFiles2" unless -d "TokenFiles2";
mkdir "printFiles" unless -d "printFiles";
mkdir "matchFiles" unless -d "matchFiles";

opendir(my $dh, $origin);
my @langs = grep {-d "$origin/$_" && ! /^\.{1,2}$/} readdir($dh);

my $tempFolder = "../../cgi-bin/DISPOSE/Highlighter/templates/";

my $fileTemp = $tempFolder . "suspectsTemp.php";
my $mainOut = "../../results/$user/results.php";

my @suspects_hashes;

foreach my $curLang (@langs) {

	chdir($workDir);

	my %hashIndex;
	my %matchIndex;
	my %countIndex;

	my %scoreHash;

	# undef %hashIndex;
	# undef %matchIndex;
	# undef %countIndex;

	mkdir "TokenFiles/$curLang" unless -d "TokenFiles/$curLang";
	mkdir "TokenFiles2/$curLang" unless -d "TokenFiles2/$curLang";
	mkdir "printFiles/$curLang" unless -d "printFiles/$curLang";
	mkdir "matchFiles/$curLang" unless -d "matchFiles/$curLang";

	chdir("$origin/$curLang");
	my @submissions = `ls`;
	chdir($workDir);

	my @sources;
	my @pastSources;

	if (-d "$sourcesDir/$curLang") {
		chdir("$sourcesDir/$curLang");
		@sources = `ls`;
		chdir($workDir);
	}

	if (-d "$pastDir/$curLang") {
		chdir("$pastDir/$curLang");
		@pastSources = `ls`;
		chdir($workDir);
	}

	# Use ANTLR to determine tokens
	system("java -jar ../../cgi-bin/DISPOSE/OpenMOSS/tokenizers/$curLang/DISPOSE_tokenizer.jar ./$origin/$curLang");
	if (-d "$sourcesDir/$curLang") {
		system("java -jar ../../cgi-bin/DISPOSE/OpenMOSS/tokenizers/$curLang/DISPOSE_tokenizer.jar ./$sourcesDir/$curLang");
	}
	if (-d "$pastDir/$curLang") {
		system("java -jar ../../cgi-bin/DISPOSE/OpenMOSS/tokenizers/$curLang/DISPOSE_tokenizer.jar ./$pastDir/$curLang");
	}

	my %tokPos;

	# Count number of hash occurences to remove "uninterested"
	preCount(\%countIndex, \@submissions, \%tokPos, $origin, $curLang);
	if (-d "$sourcesDir/$curLang") {
		preCount(\%countIndex, \@sources, \%tokPos, $sourcesDir, $curLang);
	}
	if (-d "$pastDir/$curLang") {
		preCount(\%countIndex, \@pastSources, \%tokPos, $pastDir, $curLang);
	}

	# Create a fingerprint for each file
	foreach my $sub (@submissions) {
		chomp $sub;

		winnow("./$origin/$curLang/$sub", 50, $KSIZE, $matchLim, \%countIndex, \%tokPos, $curLang);
	}
	if (-d "$sourcesDir/$curLang") {
		foreach my $source (@sources) {
			chomp $source;

			winnow("./$sourcesDir/$curLang/$source", 50, $KSIZE, $matchLim, \%countIndex, \%tokPos, $curLang);
		}
	}
	if (-d "$pastDir/$curLang") {
		foreach my $source (@pastSources) {
			chomp $source;

			winnow("./$pastDir/$curLang/$source", 50, $KSIZE, $matchLim, \%countIndex, \%tokPos, $curLang);
		}
	}


	chdir("printFiles/$curLang");
	my @sub_fps = `ls`;
	chdir($workDir);

	my $fh;
	my $hashLine;
	my $hashVal;
	my $hashPos;
	my $hashLinePos;
	my $hashFile;

	# Create hash index
	foreach my $sub_fp (@sub_fps) {
		chomp $sub_fp;
		open($fh, "<", "./printFiles/$curLang/$sub_fp")
		    or die "Failed to open file: $sub_fp!\n";
		while($hashLine = <$fh>) { 
		    ($hashVal, $hashFile, $hashPos, $hashLinePos) = ($hashLine =~ /(.+) '(.+)' (.+) (.+)/);
		    push @{ $hashIndex{$hashVal} }, "\'$hashFile\'" . " " . $hashPos . " " . $hashLinePos;
		}
	}

	# Show hash index
	# for my $key ( sort {$a<=>$b} keys %hashIndex) {
	# 	print("\n" . $key . "\n");
	#     foreach (@ { $hashIndex{$key} }) {
	# 	  print("$_\n");
	# 	}
	# }

	# Create lists of matching fingerprints by doc
	foreach my $sub_fp (@sub_fps) {

		chomp $sub_fp;
		open($fh, "<", "./printFiles/$curLang/$sub_fp")
		    or die "Failed to open file: $sub_fp!\n";

		while($hashLine = <$fh>) { 
		    ($hashVal, $hashFile, $hashPos, $hashLinePos) = ($hashLine =~ /(.+) '(.+)' (.+) (.+)/);
		    chomp $hashLinePos;

			foreach my $potMatch (@ { $hashIndex{$hashVal} }) {
				my ($potFile, $potPos, $potHashLinePos) = ($potMatch =~ /'(.+)' (.+) (.+)/);
				chomp $potHashLinePos;

				unless ($hashFile eq $potFile) {
					if ($hashFile le $potFile) {
						push @{ $matchIndex{$hashFile}{$potFile} }, "$hashVal $hashPos $potPos $hashLinePos $potHashLinePos \n";
				
					} 
					else {
						push @{ $matchIndex{$potFile}{$hashFile} }, "$hashVal $potPos $hashPos $potHashLinePos $hashLinePos \n";
					}
				}
			}
		}
	}

	close $fh;

	my $threshold = 5;
	my @suspects;
	my @suspectScores;

	for my $key (keys %matchIndex) {
		for my $key2 (keys %{$matchIndex{$key}}) {
			@{$matchIndex{$key}{$key2}} = uniq @{$matchIndex{$key}{$key2}};
		    my $matchNum = scalar @{$matchIndex{$key}{$key2}};
		    # print("\n" . $key . " " . $key2 .  " $matchNum\n");
		    my ($group1, $subNum) = ($key =~ /(.*?)_(.*?)_.+/);
		    my ($group2, $subNum2) = ($key2 =~ /(.*?)_(.*?)_.+/);

		    if ($matchNum >= $threshold && ($group1 == $originsGroup || $group2 == $originsGroup)) {
		    	if ($INT_FLAG) {
		    		unless ($subNum eq $subNum2) {
		    			push @suspects, "\'$key\'" . " " . "\'$key2\'" . " " . $matchNum;
		    		}
		    	}
		    	else {
		    		push @suspects, "\'$key\'" . " " . "\'$key2\'" . " " . $matchNum;
		    	}
		    	
		    }
		}
	}



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


	foreach my $suspect (@suspects) {
		my ($name1, $name2, $matchNum) = ($suspect =~ /'(.+)' '(.+)' (.+)/);

		# Recreate file names
		my ($groupNum, $subNum, $dirNum, $origName) = ($name1 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		
		my $fullName1;
		my $fullName2;
		my $dirName1;
		my $dirName2;

		if ($groupNum eq $sourcesGroup) {
			$fullName1 = $dirLookup2{$subNum}{$dirNum};
			$dirName1 = "./$sourcesDir/$curLang/$name1";
		}
		elsif ($groupNum eq $originsGroup) {
			$fullName1 = $dirLookup{$subNum}{$dirNum};
			$dirName1 = "./$origin/$curLang/$name1";
		}
		else {
			$fullName1 = $dirLookup3{$subNum}{$dirNum};
			$dirName1 = "./$pastDir/$curLang/$name1";
		}

		($groupNum, $subNum, $dirNum, $origName) = ($name2 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		if ($groupNum eq $sourcesGroup) {
			$fullName2 = $dirLookup2{$subNum}{$dirNum};
			$dirName2 = "./$sourcesDir/$curLang/$name2";
		}
		elsif ($groupNum eq $originsGroup) {
			$fullName2 = $dirLookup{$subNum}{$dirNum};
			$dirName2 = "./$origin/$curLang/$name2";
		}
		else {
			$fullName2 = $dirLookup3{$subNum}{$dirNum}; #idk
			$dirName2 = "./$pastDir/$curLang/$name2";
		}

		my $matchFile = createMatchFile($name1, $name2, $origin, $curLang, \%matchIndex, \%scoreHash, $MINRUN, $fullName1, $fullName2, $dirName1, $dirName2);
	}

	for my $key (keys %scoreHash) {
		for my $key2 (keys %{$scoreHash{$key}}) {
		    # print("\n" . $key . " " . $key2 .  " $matchNum\n");
		    push @suspectScores, "$key" . " " . "$key2" . " " . $scoreHash{$key}{$key2};
		    # print ("$key" . " " . "$key2" . " " . $scoreHash{$key}{$key2} . "\n");
		}
	}

	my @suspects_sort = sort { ($b =~ /.+ .+ (.+)/)[0] <=> ($a =~ /.+ .+ (.+)/)[0] } @suspectScores;

	my $SUSLIMIT = 250;
	if (scalar @suspects_sort < $SUSLIMIT) {
		$SUSLIMIT = scalar @suspects_sort;
	}

	print("\n\nSUSPECTS\n\n");


	chdir($mainDir);

	for (my $i = 0; $i < $SUSLIMIT; $i += 1) {

		print("$suspects_sort[$i]\n");

		(my $name1, my $name2, my $score) = ($suspects_sort[$i] =~ /(.+) (.+) (.+)/);
		(my $shortName1) = ($name1 =~ /(.+)\..+/);
		(my $shortName2) = ($name2 =~ /(.+)\..+/);

		(my $srcType1) = ($shortName1 =~ /([^_]+)_.+/);
		(my $srcType2) = ($shortName2 =~ /([^_]+)_.+/);

		# Recreate file names
		my ($groupNum, $subNum, $dirNum, $origName) = ($name1 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		
		my $fullName1;
		my $fullName2;

		if ($groupNum eq $sourcesGroup) {
			$fullName1 = $dirLookup2{$subNum}{$dirNum};
		}
		elsif ($groupNum eq $originsGroup) {
			$fullName1 = $dirLookup{$subNum}{$dirNum};
		}
		else {
			$fullName1 = $dirLookup3{$subNum}{$dirNum};
		}

		($groupNum, $subNum, $dirNum, $origName) = ($name2 =~ /(.*?)_(.*?)_(.*?)_(.+)/);
		if ($groupNum eq $sourcesGroup) {
			$fullName2 = $dirLookup2{$subNum}{$dirNum};
		}
		elsif ($groupNum eq $originsGroup) {
			$fullName2 = $dirLookup{$subNum}{$dirNum};
		}
		else {
			$fullName2 = $dirLookup3{$subNum}{$dirNum};
		}


		my $authName1;
		my $authName2;

		# Captures the second folder in the full path name
		($authName1) = ($fullName1 =~ /\.\/.*?\/(.*?)\//);
		($authName2) = ($fullName2 =~ /\.\/.*?\/(.*?)\//);

		# Shortens arbitrary string to 20 chars
		$authName1 =~ s/.{20}\K.*//s;
		$authName2 =~ s/.{20}\K.*//s;

		my $dirName1;
		my $dirName2;

		# Captures the first folder in the full path name
		($dirName1) = ($fullName1 =~ /\.\/(.*?)\/.*?\//);
		($dirName2) = ($fullName2 =~ /\.\/(.*?)\/.*?\//);

		my $matchFile = "./matchFiles/$curLang/" . $shortName1 . "_" . $shortName2 . "_match.txt";
		push (@suspects_hashes, {file1 => $name1, file2 => $name2, srcType1 => $srcType1, srcType2 => $srcType2, 
			fullName1 => $fullName1, fullName2 => $fullName2, matchNum => $score, matchIndex => $i, lang => $curLang,
			authName1 => $authName1, authName2 => $authName2, dirName1 => $dirName1, dirName2 => $dirName2,
			matchScore => $score});


		system("perl ../Highlighter/Highlighter.pl \'$matchFile\' $origin $curLang $i $MINRUN $userFolder $user");
	}
}

# Create a specific match file
# my $matchFile = createMatchFile("0_1_file1.java", "0_2_file2.java");
# system("perl Highlighter.pl $matchFile");

my $vars = {
      matches => \@suspects_hashes,
      langs => \@langs,
      tempFolder => $tempFolder,
      user => $user,
      method => 1
};

chdir($workDir);

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


sub createMatchFile {

	my $name1 = $_[0];
	my $name2 = $_[1];
	my $origin = $_[2];
	my $curLang = $_[3];
	my $miRef = $_[4];
	my $scoreRef = $_[5];
	my $MINRUN = $_[6];
	my $fullName1 = $_[7];
	my $fullName2 = $_[8];
	my $dirName1 = $_[9];
	my $dirName2 = $_[10];

	my %matchIndex = %$miRef;

	(my $shortName1) = ($name1 =~ /(.+)\..+/);
	(my $shortName2) = ($name2 =~ /(.+)\..+/);

	my $fp1 = "./printFiles/$curLang/$shortName1" . "_print.txt";
	my $fp2 = "./printFiles/$curLang/$shortName2" . "_print.txt";

	my $matchFile = "./matchFiles/$curLang/" . $shortName1 . "_" . $shortName2 . "_match.txt";

	open(my $mfh, ">", $matchFile)
		or die "Failed to open file: '$matchFile'!\n";
	open(my $mfh1, "<", $fp1)
		or die "Failed to open file: '$fp1'!\n";
	open(my $mfh2, "<", $fp2)
		or die "Failed to open file: '$fp2'!\n";

	print $mfh "\'$dirName1\' \'$dirName2\' \'$fullName1\' \'$fullName2\'\n";

	my %fpHash1;
	my %lineHash1;
	my %posHash1;
	my @fpArray1;
	my %fpHash2;
	my %lineHash2;
	my %posHash2;
	my @fpArray2;

	my $indexCount = 0;

	while (<$mfh1>) {
		(my $hashVal, my $hashPos, my $hashLine) = ($_ =~ /(.+) .+ (.+) (.+)/);
		chomp $hashLine;
		push @fpArray1, $hashVal;
		$fpHash1{$hashPos} = $indexCount;
		$lineHash1{$hashPos} = $hashLine;
		$posHash1{$indexCount} = $hashPos;
		$indexCount += 1;
	}
	close $mfh1;

	$indexCount = 0;

	while (<$mfh2>) {
		(my $hashVal, my $hashPos, my $hashLine) = ($_ =~ /(.+) .+ (.+) (.+)/);
		chomp $hashLine;
		push @fpArray2, $hashVal;
		$fpHash2{$hashPos} = $indexCount;
		$lineHash2{$hashPos} = $hashLine;
		$posHash2{$indexCount} = $hashPos;
		$indexCount += 1;
	}

	close $mfh2;

	my %checkedNext;
	my %matchChains;
	my $i = 0;

	CHAIN: foreach my $hashMatch (@{ $matchIndex{$name1}{$name2} }) {
		(my $hashPos1, my $hashPos2) = ($hashMatch =~ /.+ (.+) (.+) .+ .+/);
		my $arrayIndex1 = $fpHash1{$hashPos1};
		my $arrayIndex2 = $fpHash2{$hashPos2};

		my $curRun = 0;
		
		while ($fpArray1[$arrayIndex1] eq $fpArray2[$arrayIndex2] && $arrayIndex1 < scalar(@fpArray1)-1 && $arrayIndex2 < scalar(@fpArray2)-1 ) {

			# print($arrayIndex1 . " " . $hashPos1 . ":$lineHash1{$hashPos1}" . " " . $arrayIndex2 . " " . $hashPos2 . ":$lineHash2{$hashPos2}" . "\n");

			if (exists $checkedNext{$arrayIndex1}{$arrayIndex2}) {
				next CHAIN;
			}
			$hashPos1 = $posHash1{$arrayIndex1};
			$hashPos2 = $posHash2{$arrayIndex2};

			push (@{$matchChains{$i}}, ($arrayIndex1 . " " . $hashPos1 . ":$lineHash1{$hashPos1}" . " " . $arrayIndex2 . " " . $hashPos2 . ":$lineHash2{$hashPos2}"));

			$curRun += 1;

			$checkedNext{$arrayIndex1}{$arrayIndex2} = 1;
			
			if ($curRun >= $MINRUN) {
				$scoreRef->{$name1}{$name2} += 1;
			}

			$arrayIndex1 += 1;
			$arrayIndex2 += 1;
		}

		$i += 1;
	}

	foreach my $matchChain (sort { scalar(@{$matchChains{$b}}) <=> scalar(@{$matchChains{$a}}) } keys %matchChains) {
		my @chainArray = @{$matchChains{$matchChain}};
		print $mfh ("\n");

		foreach my $j (0 .. (scalar @chainArray - 1)) {
			print $mfh ($chainArray[$j] . "\n");
		}

		print $mfh ("\n");
	}

	close $mfh;

	return $matchFile;
}

sub preCount {
	my ($countHash, $subArrayRef, $tokPosRef, $origin, $curLang) = @_;
	my @submissions = @$subArrayRef;

	foreach my $sub (@submissions) {
		chomp $sub;
		(my $name) = ($sub =~ /(.+)\..+/);
		chomp $name;

		my $tokenFile = "./TokenFiles/$curLang/" . $name . "_token.txt";
		tokScrape("$tokenFile", $tokPosRef, $curLang, $sub);

		my $tokFile2 = "./TokenFiles2/$curLang/" . $name . "_token2.txt";
		open(my $fh, "<", $tokFile2)
			or die "Failed to open file: '$tokFile2'!\n";

		my $tokenLine = <$fh>;
		my $lineSize = length($tokenLine);
		close $fh;

		my %seenHash;

		for (my $i=0; $i <= $lineSize-$KSIZE; $i = $i+1) {
			my $kgram = substr($tokenLine, $i, $KSIZE);
			unless (exists $seenHash{$kgram}) {	
				$countHash->{$kgram} += 1;
				$seenHash{$kgram} = 1;
			}
		}
	}

	open(my $fh2, ">", "wut.txt")
			or die "Failed to open file: 'wut.txt'!\n";
	foreach my $key (keys %$countHash) {
		print $fh2 ("$key $countHash->{$key} \n");
	}
}