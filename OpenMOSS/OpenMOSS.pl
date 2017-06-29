#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]

use List::MoreUtils qw(uniq);
use Cwd qw(getcwd);
use Winnower;
use TokenScraper;

my $origin = $ARGV[0];
my $matchLim = 1000000;
my %hashIndex;
my %matchIndex;
my %countIndex;

my $workDir = getcwd;

chdir($origin);
my @submissions = `ls`;
chdir($workDir);

mkdir "TokenFiles" unless -d "TokenFiles";
mkdir "TokenFiles2" unless -d "TokenFiles2";
mkdir "printFiles" unless -d "printFiles";
mkdir "matchFiles" unless -d "matchFiles";

mkdir "TokenFiles/Java8" unless -d "TokenFiles/Java8";
mkdir "TokenFiles2/Java8" unless -d "TokenFiles2/Java8";

# Use ANTLR to determine tokens
system("java -jar ./tokenizers/Java8/DISPOSE_tokenizer.jar ./$origin");


my %tokPos;

# Create a fingerprint for each file
foreach my $sub (@submissions) {
	undef %tokPos;
	chomp $sub;
	(my $name) = ($sub =~ /(.+)\..+/);
	chomp $name;
	# print($sub . " " . $name . "\n");
	my $tokenFile = "./TokenFiles/Java8/" . $name . "_token.txt";
	tokScrape("$tokenFile", \%tokPos);
	winnow("./$origin/$sub", 50, \%countIndex, \%tokPos);
}

chdir("printFiles");
my @sub_fps = `ls`;
chdir("..");

my $fh;
my $hashLine;
my $hashVal;
my $hashPos;
my $hashLinePos;
my $hashFile;

# Create hash index
foreach my $sub_fp (@sub_fps) {
	chomp $sub_fp;
	open($fh, "<", "./printFiles/$sub_fp")
	    or die "Failed to open file: $sub_fp!\n";
	while($hashLine = <$fh>) { 
	    ($hashVal, $hashFile, $hashPos, $hashLinePos) = split(/ /,$hashLine);
	    push @{ $hashIndex{$hashVal} }, $hashFile . " " . $hashPos . " " . $hashLinePos;
	}
}

# Show hash index
# for my $key ( sort {$a<=>$b} keys %hashIndex) {
# 	print("\n" . $key . "\n");
#     foreach (@ { $hashIndex{$key} }) {
# 	  print("$_");
# 	}
# }


open(my $fh3, ">", "wut.txt")
		or die "Failed to open file: 'wut.txt'!\n";

for my $key ( sort {$a<=>$b} keys %countIndex) {
	print $fh3 ($key . " " . $countIndex{$key} . "\n");
}

close $fh3;

# Create lists of matching fingerprints by doc
foreach my $sub_fp (@sub_fps) {

	chomp $sub_fp;
	open($fh, "<", "./printFiles/$sub_fp")
	    or die "Failed to open file: $sub_fp!\n";

	my %checkedHash = ();

	while($hashLine = <$fh>) { 
	    ($hashVal, $hashFile, $hashPos, $hashLinePos) = split(/ /,$hashLine);
	    chomp $hashLinePos;

	    unless (exists $checkedHash{$hashVal}) {

			unless ($countIndex{$hashVal} > $matchLim) {
				foreach my $potMatch (@ { $hashIndex{$hashVal} }) {
					my ($potFile, $potPos, $potHashLinePos) = split(/ /, $potMatch);
					chomp $potHashLinePos;

					unless ($hashFile eq $potFile) {
						push @{ $matchIndex{$hashFile}{$potFile} }, "$hashVal $hashPos $potPos $hashLinePos $potHashLinePos\n";
					}
				}
			}

			$checkedHash{$hashVal} = 1;
		}
	}
}

# Show specific match index
# createMatchFile("146_1_BFS.java", "146_5_DFS.java");

close $fh;

my $threshold = 10;
my @suspects;

for my $key (keys %matchIndex) {
	for my $key2 (keys $matchIndex{$key}) {
	    my $matchNum = scalar @{$matchIndex{$key}{$key2}};
	    my $matchNum2 = scalar @{$matchIndex{$key2}{$key}};
	    # print("\n" . $key . " " . $key2 .  " $matchNum\n");
	    if ($matchNum >= $threshold && $matchNum >= $matchNum2) {
	    	push @suspects, $key . " " . $key2 . " " . $matchNum;
	    }
	}
}

print("\n\nSUSPECTS\n\n");

my @suspects_sort = sort { ($b =~ /.+ (.+)/)[0] <=> ($a =~ /.+ (.+)/)[0] } @suspects;

my $SUSLIMIT = 250;
if (scalar @suspects_sort < $SUSLIMIT) {
	$SUSLIMIT = scalar @suspects_sort;
}

for (my $i = 0; $i < $SUSLIMIT; $i = $i+1) {

	print "$suspects_sort[$i]\n";

	(my $name1, my $name2, $matchNum) = split(/ /,$suspects_sort[$i]);

	my $matchFile = createMatchFile($name1, $name2);

}
print ("\n");


sub createMatchFile {
	my $name1 = $_[0];
	my $name2 = $_[1];

	my $matchFile = "./matchFiles/" . $name1 . "_" . $name2 . "_match.txt";
	
	open(my $fh2, ">", $matchFile)
		or die "Failed to open file: '$matchFile'!\n";

	print $fh2 "$name1 $name2 \n";

	my @order1 = sort { ($a =~ /.+ (.+) .+ .+ .+/)[0] <=> ($b =~ /.+ (.+) .+ .+ .+/)[0] } @{ $matchIndex{$name1}{$name2} };
	my @order2 = sort { ($a =~ /.+ .+ (.+) .+ .+/)[0] <=> ($b =~ /.+ .+ (.+) .+ .+/)[0] } @{ $matchIndex{$name1}{$name2} };

	my @posIndex;
	my @posIndex2;
	my %lineIndex;
	my %lineIndex2;

	foreach my $k (0 .. (scalar @order1)-1) {
		push (@posIndex, ($order1[$k] =~ /.+ (.+) .+ .+ .+/)[0]);
		$lineIndex{$k} = ($order1[$k] =~ /.+ .+ .+ (.+) .+/)[0];
	}

	foreach my $k (0 .. (scalar @order2)-1) {
		push (@posIndex2, ($order2[$k] =~ /.+ .+ (.+) .+ .+/)[0]);
		$lineIndex2{$k} = ($order2[$k] =~ /.+ .+ .+ .+ (.+)/)[0];
		chomp $lineIndex2{$k};
	}

	my %matchChains;

	foreach my $i (0 .. (scalar @posIndex)-1) {
		my $matching = 1;

		# print($i . "\n");

		my $indexNext = $i;
		my $chainOld = $posIndex[$i];
		my $chainOld2 = ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/)[0];
		my $indexNext2 = binSearch(\@posIndex2, $chainOld2);

		push (@{$matchChains{$i}}, ($indexNext . " " . $chainOld . ":$lineIndex{$indexNext}" . " " . $indexNext2 . " " . $chainOld2 . ":$lineIndex2{$indexNext2}"));
		# print("MATCH: " . ($indexNext . " " . $chainNext . " " . $indexNext2 . " " . $chainNext2) . "\n");

		# print($order1[$indexNext] . ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/) . "\n");
		# print("TEST: " . $chainOld2 . " " . ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/) . " " . $chainOld . " " . ($order2[$indexNext2] =~ /.+ (.+) .+ .+ .+/) . "\n\n");

		while ($matching && $indexNext < (scalar @posIndex) - 1 && $indexNext2 < (scalar @posIndex2) - 1) {

			$indexNext += 1;
			my $chainNext = $posIndex[$indexNext];
			while ($chainOld == $chainNext) {
				$indexNext += 1;
				$chainNext = $posIndex[$indexNext];
			}
			$chainOld = $chainNext;
			my $indexOld = $indexNext;

			$indexNext2 += 1;
			my $chainNext2 = $posIndex2[$indexNext2];
			while ($chainOld2 == $chainNext2) {
				$indexNext2 += 1;
				$chainNext2 = $posIndex2[$indexNext2];
			}
			$chainOld2 = $chainNext2;
			my $indexOld2 = $indexNext2;

			# print("TEST: " . $chainNext2 . " " . ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/) . " " . $chainNext . " " . ($order2[$indexNext2] =~ /.+ (.+) .+ .+ .+/) . "\n");

			if ($chainOld2 == ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/)[0] && $chainOld == ($order2[$indexNext2] =~ /.+ (.+) .+ .+ .+/)[0]) {
				push (@{$matchChains{$i}}, ($indexNext . " " . $chainNext . ":$lineIndex{$indexNext}" . " " . $indexNext2 . " " . $chainNext2 . ":$lineIndex2{$indexNext2}"));
				# print("MATCH: " . ($indexNext . " " . $chainNext . " " . $indexNext2 . " " . $chainNext2) . "\n");
			}
			else  {
				$matching = 0;

				while (!$matching && ($chainNext == $chainOld) && $indexNext < (scalar @posIndex) - 1) {
					$indexNext += 1;
					$chainNext = $posIndex[$indexNext];

					$indexNext2 = $indexOld2;
					$chainNext2 = $chainOld2;

					while (!$matching && ($chainNext2 == $chainOld2) && $indexNext2 < (scalar @posIndex2) - 1) {
						

						$indexNext2 += 1;
						$chainNext2 = $posIndex2[$indexNext2];

						# print("TEST: " . $chainNext2 . " " . ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/) . " " . $chainNext . " " . ($order2[$indexNext2] =~ /.+ (.+) .+ .+ .+/) . "\n");

						if ($chainNext == ($order2[$indexNext2] =~ /.+ (.+) .+ .+ .+/)[0] && $chainNext2 == ($order1[$indexNext] =~ /.+ .+ (.+) .+ .+/)[0]) {
							$matching = 1;
							push (@{$matchChains{$i}}, ($indexNext . " " . $chainNext . ":$lineIndex{$indexNext}" . " " . $indexNext2 . " " . $chainNext2 . ":$lineIndex2{$indexNext2}"));
							# print("MATCH: " . ($indexNext . " " . $chainNext . " " . $indexNext2 . " " . $chainNext2) . "\n");
						}
					}
				}
			}
		}
	}

	foreach my $matchChain (sort {$a <=> $b} keys %matchChains) {
		my @chainArray = @{$matchChains{$matchChain}};
		foreach my $j (0 .. (scalar @chainArray)) {
			print $fh2 ($chainArray[$j] . "\n");
		}
	}

	close $fh2;

	return $matchFile;
}