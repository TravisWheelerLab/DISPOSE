#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]

use List::MoreUtils qw(uniq);
use Cwd qw(getcwd);
use Winnower;
use TokenScraper;
use Template;

my $origin = $ARGV[0];
my $matchLim = 10;
my $KSIZE = 5;
my $MINRUN = 3;

my $workDir = getcwd;

mkdir "TokenFiles" unless -d "TokenFiles";
mkdir "TokenFiles2" unless -d "TokenFiles2";
mkdir "printFiles" unless -d "printFiles";
mkdir "matchFiles" unless -d "matchFiles";

opendir my $dh, $origin;
my @langs = grep {-d "$origin/$_" && ! /^\.{1,2}$/} readdir($dh);

my $fileTemp = "templates/suspectsTemp.html";
my $mainOut = "results.html";

my @suspects_hashes;

foreach my $curLang (@langs) {
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

	# Use ANTLR to determine tokens
	system("java -jar ./tokenizers/$curLang/DISPOSE_tokenizer.jar ./$origin/$curLang");

	my %tokPos;

	# Count number of hash occurences to remove "uninterested"
	preCount(\%countIndex, \@submissions, \%tokPos, $origin, $curLang);

	# Create a fingerprint for each file
	foreach my $sub (@submissions) {
		undef %tokPos;
		chomp $sub;
		(my $name) = ($sub =~ /(.+)\..+/);
		chomp $name;
		# print($sub . " " . $name . "\n");
		my $tokenFile = "./TokenFiles/$curLang/" . $name . "_token.txt";
		tokScrape("$tokenFile", \%tokPos, $curLang);
		winnow("./$origin/$curLang/$sub", 50, $KSIZE, $matchLim, \%countIndex, \%tokPos, $curLang);
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
		for my $key2 (keys $matchIndex{$key}) {
			@{$matchIndex{$key}{$key2}} = uniq @{$matchIndex{$key}{$key2}};
		    my $matchNum = scalar @{$matchIndex{$key}{$key2}};
		    # print("\n" . $key . " " . $key2 .  " $matchNum\n");
		    if ($matchNum >= $threshold) {
		    	push @suspects, "\'$key\'" . " " . "\'$key2\'" . " " . $matchNum;
		    }
		}
	}


	foreach my $suspect (@suspects) {
		(my $name1, my $name2, $matchNum) = ($suspect =~ /'(.+)' '(.+)' (.+)/);
		my $matchFile = createMatchFile($name1, $name2, $origin, $curLang, \%matchIndex, \%scoreHash, $MINRUN);
	}

	for my $key (keys %scoreHash) {
		for my $key2 (keys $scoreHash{$key}) {
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

	for (my $i = 0; $i < $SUSLIMIT; $i += 1) {

		print("$suspects_sort[$i]\n");

		(my $name1, my $name2, my $score) = ($suspects_sort[$i] =~ /(.+) (.+) (.+)/);
		(my $shortName1) = ($name1 =~ /(.+)\..+/);
		(my $shortName2) = ($name2 =~ /(.+)\..+/);

		my $matchFile = "./matchFiles/$curLang/" . $shortName1 . "_" . $shortName2 . "_match.txt";
		push (@suspects_hashes, {file1 => $name1, file2 => $name2, matchNum => $score, matchIndex => $i, lang => $curLang});

		system("perl Highlighter.pl \'$matchFile\' $origin $curLang $i $MINRUN");
	}
}

# Create a specific match file
# my $matchFile = createMatchFile("6_22_PS3Q1.java", "6_23_PS3Q2.java");
# system("perl Highlighter.pl $matchFile");

my $vars = {
      matches => \@suspects_hashes,
      langs => \@langs
};

my $template = Template->new();
$template->process($fileTemp, $vars, $mainOut)
    || die "Template process failed: ", $template->error(), "\n";

print ("\n");


sub createMatchFile {

	my $name1 = $_[0];
	my $name2 = $_[1];
	my $origin = $_[2];
	my $curLang = $_[3];
	my $miRef = $_[4];
	my $scoreRef = $_[5];
	my $MINRUN = $_[6];

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

	print $mfh "\'$name1\' \'$name2\' \n";

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
	my $i;

	CHAIN: foreach $hashMatch (@{ $matchIndex{$name1}{$name2} }) {
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
		print mfh ("\n");

		foreach my $j (0 .. (scalar @chainArray)) {
			print $mfh ($chainArray[$j] . "\n");
		}
	}

	close $mfh;

	return $matchFile;
}

sub preCount {
	my ($countHash, $subArrayRef, $tokPosRef, $origin, $curLang) = @_;
	my @submissions = @$subArrayRef;
	my %tokPos = $tokPosRef;

	foreach my $sub (@submissions) {
		undef %tokPos;
		chomp $sub;
		(my $name) = ($sub =~ /(.+)\..+/);
		chomp $name;

		my $tokenFile = "./TokenFiles/$curLang/" . $name . "_token.txt";
		tokScrape("$tokenFile", \%tokPos, $curLang);

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
	foreach $key (keys %$countHash) {
		print $fh2 ("$key $countHash->{$key} \n");
	}
}