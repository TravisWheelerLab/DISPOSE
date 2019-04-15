#!/usr/bin/perl

# Usage: perl Highlighter2.pl [match file] [index] [user] [lang] [fullName1] [fullName2]

use warnings;
use strict;
use Template;
use HTML::Entities qw(encode_entities);

use Cwd qw(getcwd);

my $matchIndex = $ARGV[1];
my $file = $ARGV[0];
my $curLang = $ARGV[3];
my $user = $ARGV[2];
my $MINSCORE = 0;
my $userFolder =  "../../../workFiles/$user";

my $tempFolder = "../../cgi-bin/DISPOSE/Highlighter/templates/";

my $matchFile = $userFolder . "/matchFiles2/" . $file;
my $scoreFile = $userFolder . "/scoreFiles/" . $file;

open(my $fh, "<", $matchFile)
	or die "Failed to open file: '$matchFile'!\n";
my ($name1, $fullName1, $name2, $fullName2, $score) = (<$fh> =~ /'(.+)' '(.+)' '(.+)' '(.+)' '(.+)'/);
$score =~ s/^\s+|\s+$//g;

my $treeFile1;
my $treeFile2; 

($treeFile1) = ($name1 =~ /(.+)\..+/ );
($treeFile2) = ($name2 =~ /(.+)\..+/ );
$treeFile1 = $userFolder . "/trees/" . $treeFile1 . '.txt';
$treeFile2 = $userFolder . "/trees/" . $treeFile2 . '.txt';

mkdir "../../results/$user/outFiles" unless -d "../../results/$user/outFiles";
my $outFile = "outFiles/$curLang/match" . "$matchIndex" . "_match.html";
my $outFile2 = "outFiles/$curLang/match" . "$matchIndex" . "_text.html";
my $outFile3 = "outFiles/$curLang/match" . "$matchIndex" . "_data.html";

my $fileTemp = $tempFolder . "matchTemp.html";
my $fullTextTemp = $tempFolder . "fullTextTemp.html";
my $dataTemp = $tempFolder . "dataTemp.html";

my %lineHash1;
my %lineHash2;

my $file1 = "$fullName1";
my $file2 = "$fullName2";

my $file1Text = "";
my $file2Text = "";

open(my $fh1, $file1)
	or die "Failed to open file: '$file1'!\n";
open(my $fh2, $file2)
	or die "Failed to open file: '$file2'!\n";


my $lineCount1 = 1;
my $htmlString;

while (<$fh1>) {
	$htmlString = encode_entities($_);
	$lineHash1{$lineCount1} = $htmlString;
	$file1Text = $file1Text . $htmlString;
	$lineCount1++;
}
close $fh1;

my $lineCount2 = 1;
while (<$fh2>) {
	$htmlString = encode_entities($_);
	$lineHash2{$lineCount2} = $htmlString;
	$file2Text = $file2Text . $htmlString;
	$lineCount2++;
}
close $fh2;

my @matches;

while (<$fh>) {

	my $posInfo1 = $_; chomp $posInfo1;
	my $posInfo2 = <$fh>; chomp $posInfo2;

	#print($posInfo1 . "\n");
	#print($posInfo2 . "\n");

	my @matchParams1 = split(/ /, $posInfo1);
	my @posParams1_1 = split(/:/, $matchParams1[0]);
	my @posParams1_2 = split(/:/, $matchParams1[1]);
	my $n1 = $matchParams1[2];

	my @matchParams2 = split(/ /, $posInfo2);
	my @posParams2_1 = split(/:/, $matchParams2[0]);
	my @posParams2_2 = split(/:/, $matchParams2[1]);
	my $n2 = $matchParams2[2];

	my $treePos1 = $posParams1_1[0];
	my $treeEnd1 = $posParams1_2[0];
	my $linePos1 = $posParams1_1[1];
	my $lineEnd1 = $posParams1_2[1];

	my $treePos2 = $posParams2_1[0];
	my $treeEnd2 = $posParams2_2[0];
	my $linePos2 = $posParams2_1[1];
	my $lineEnd2 = $posParams2_2[1];

	#print ("$treePos1:$linePos1 $treeEnd1:$lineEnd1 $treePos2:$linePos2 $treeEnd2:$lineEnd2\n");

	if ($treeEnd1 < $treePos1) {
		($treePos1, $treeEnd1) = ($treeEnd1, $treePos1);
		($linePos1, $lineEnd1) = ($lineEnd1, $linePos1);
	}

	if ($treeEnd2 < $treePos2) {
		($treePos2, $treeEnd2) = ($treeEnd2, $treePos2);
		($linePos2, $lineEnd2) = ($lineEnd2, $lineEnd1);
	}

	#print ("$treePos1:$linePos1 $treeEnd1:$lineEnd1 $treePos2:$linePos2 $treeEnd2:$lineEnd2\n\n");


	my $score = <$fh>; chomp $score;

	if ($score > $MINSCORE) {
		my $linesText1 = "$n1 $treePos1:$linePos1 " . "$treeEnd1:$lineEnd1 $score";

		my $text1 = "";
		my $text2 = "";

		for (my $i = $linePos1; $i <= $lineEnd1; $i = $i+1) {
			if (defined $lineHash1{$i}) {
				$text1 = $text1 . $lineHash1{$i};
			}
			else {
				$text1 = $text1 . "\n";
			}
		}

		my $linesText2 = "$n2 $treePos2:$linePos2 " . "$treeEnd2:$lineEnd2 $score";

		for (my $j = $linePos2; $j <= $lineEnd2; $j = $j+1) {
			if (defined $lineHash2{$j}) {
				$text2 = $text2 . $lineHash2{$j};
			}
			else {
				$text2 = $text2 . "\n";
			}
		}

		push @matches, {text1 => $text1, text2 => $text2, 
			linestext1 => $linesText1, linestext2 => $linesText2,
			size => $score, n1 => $n1, n2 => $n2, lang => $curLang,
			matchIndex => $matchIndex};
	}

	my $empty = <$fh>;
	
}
close $fh;

my $tree1;
my $tree2;
my $scores;

open(my $fh3, $treeFile1)
	or die "Failed to open file: '$treeFile1'!\n";
open(my $fh4, $treeFile2)
	or die "Failed to open file: '$treeFile2'!\n";
open(my $fh5, $scoreFile)
	or die "Failed to open file: '$scoreFile'!\n";

$tree1 = <$fh3>;
$tree2 = <$fh4>;
$scores = <$fh5>;

my $fullTextLink = "?lang=$curLang&id=$matchIndex&type=text";

$fullName1 = $ARGV[4];
$fullName2 = $ARGV[5];

# Match vars
my $vars = {
      matches => \@matches,
      fullTextLink => $fullTextLink,
      file1 => {name => $name1, fullName => "$fullName1"},
      file2 => {name => $name2, fullName => "$fullName2"},
      tempFolder => $tempFolder
};

# Full text vars
my $vars2 = {
		file1 => {name => $name1, fullName => "$fullName1", text => $file1Text},
	    file2 => {name => $name2, fullName => "$fullName2", text => $file2Text},
	    tempFolder => $tempFolder
};

# Data vars
my $vars3 = {
		file1 => {name => $name1, fullName => "$fullName1", text => $file1Text},
	    file2 => {name => $name2, fullName => "$fullName2", text => $file2Text},
	    tree1 => $tree1,
	    tree2 => $tree2,
	    scores => $scores,
	    tempFolder => $tempFolder
};

chdir($userFolder);

my $template = Template->new(RELATIVE => 1);
my $template2 = Template->new(RELATIVE => 1);
my $template3 = Template->new(RELATIVE => 1);
    
$template->process($fileTemp, $vars, "../../results/$user/" . $outFile)
    || die "Template process failed: ", $template->error(), "\n";

$template2->process($fullTextTemp, $vars2, "../../results/$user/" . $outFile2)
    || die "Template process failed: ", $template2->error(), "\n";

$template3->process($dataTemp, $vars3, "../../results/$user/" . $outFile3)
    || die "Template process failed: ", $template3->error(), "\n";
