#!/usr/bin/perl

# Usage: perl Highlighter.pl [match file] [origin] [lang] [match index] [MINRUN] [full name 1] [full name 2] [user folder] [user]

use warnings;
use strict;
use Template;
use HTML::Entities qw(encode_entities);

my $matchIndex = $ARGV[3];
my $file = $ARGV[0];
my $origin = $ARGV[1];
my $curLang = $ARGV[2];
my $MINRUN = $ARGV[4];
my $userFolder = $ARGV[5];
my $user = $ARGV[6];

chdir($userFolder);

my $tempFolder = "../../cgi-bin/DISPOSE/TheTool/templates/";


open(my $fh, "<", $file)
	or die "Failed to open file: '$file'!\n";
my ($name1, $name2, $fullName1, $fullName2) = (<$fh> =~ /'(.+)' '(.+)' '(.+)' '(.+)'/);
$fullName2 =~ s/^\s+|\s+$//g;

mkdir "../../results/$user/outFiles" unless -d "../../results/$user/outFiles";
my $outFile = "outFiles/$curLang/match" . "$matchIndex" . "_match.html";
my $outFile2 = "outFiles/$curLang/match" . "$matchIndex" . "_text.html";

my $fileTemp = $tempFolder . "matchTemp.html";
my $fullTextTemp = $tempFolder . "fullTextTemp.html";

my %lineHash1;
my %lineHash2;

my $file1 = "$name1";
my $file2 = "$name2";

my $file1Text;
my $file2Text;

open(my $fh1, $file1)
	or die "Failed to open file: '$file1'!\n";
open(my $fh2, $file2)
	or die "Failed to open file: '$file2'!\n";

my $lineCount = 1;
my $htmlString;

while (<$fh1>) {
	$htmlString = encode_entities($_);
	$lineHash1{$lineCount} = $htmlString;
	$file1Text = $file1Text . $htmlString;
	$lineCount++;
}
close $fh1;

$lineCount = 1;
while (<$fh2>) {
	$htmlString = encode_entities($_);
	$lineHash2{$lineCount} = $htmlString;
	$file2Text = $file2Text . $htmlString;
	$lineCount++;
}
close $fh2;

my $curRun = 0;


my @matches;

while (<$fh>) {
	chomp $_;

	$curRun = 1;

	my @matchParams = split(/ /, $_);
	my @posParams1 = split(/:/, $matchParams[1]);
	my @posParams2 = split(/:/, $matchParams[3]);

	my $linePos1 = $posParams1[1];
	my $linePos2 = $posParams2[1];;
	my $kgramPos1 = $posParams1[0];
	my $kgramPos2 = $posParams2[0];

	my $lineEnd1 = $linePos1;
	my $lineEnd2 = $linePos2;
	my $kgramEnd1 = $kgramPos1;
	my $kgramEnd2 = $kgramPos2;

	my $nextLine = <$fh>;

	until ($nextLine eq "\n") {
		chomp $nextLine;

		@matchParams = split(/ /, $nextLine);
		@posParams1 = split(/:/, $matchParams[1]);
		@posParams2 = split(/:/, $matchParams[3]);

		$lineEnd1 = $posParams1[1];
		$lineEnd2 = $posParams2[1];;
		$kgramEnd1 = $posParams1[0];
		$kgramEnd2 = $posParams2[0];

		$curRun++;
		$nextLine = <$fh>;
	}

	if ($curRun >= $MINRUN) {
		# print("\n\n\n\nFILE 1: $file1\n-----------------------------\n");
		my $linesText1 = "$kgramPos1:$linePos1 " . "$kgramEnd1:$lineEnd1 $curRun";
		# print("$kgramPos1:$linePos1 " . "$kgramEnd1:$lineEnd1 $curRun\n\n");

		my $text1;
		my $text2;

		for (my $i = $linePos1; $i <= $lineEnd1; $i = $i+1) {
			# print($lineHash1{$i});
			$text1 = $text1 . $lineHash1{$i};
		}

		# print("\nFILE 2: $file2\n-----------------------------\n");
		my $linesText2 = "$kgramPos2:$linePos2 " . "$kgramEnd2:$lineEnd2 $curRun";
		# print("$kgramPos2:$linePos2 " . "$kgramEnd2:$lineEnd2 $curRun\n\n");

		for (my $j = $linePos2; $j <= $lineEnd2; $j = $j+1) {
			# print($lineHash2{$j});
			$text2 = $text2 . $lineHash2{$j};
		}

		push @matches, {text1 => $text1, text2 => $text2, 
			linestext1 => $linesText1, linestext2 => $linesText2,
			size => $curRun};
	}
	
}
close $fh;

my $fullTextLink = "results.php?lang=$curLang&id=$matchIndex&type=text";

my $vars = {
      matches => \@matches,
      fullTextLink => $fullTextLink,
      file1 => {name => $file1, fullName => "$fullName1"},
      file2 => {name => $file2, fullName => "$fullName2"},
      tempFolder => $tempFolder
};

my $vars2 = {
		file1 => {name => $file1, fullName => "$fullName1", text => $file1Text},
	    file2 => {name => $file2, fullName => "$fullName2", text => $file2Text},
	    tempFolder => $tempFolder
};

my $template = Template->new(RELATIVE => 1);
my $template2 = Template->new(RELATIVE => 1);
    
$template->process($fileTemp, $vars, "../../results/$user/" . $outFile)
    || die "Template process failed: ", $template->error(), "\n";

$template2->process($fullTextTemp, $vars2, "../../results/$user/" . $outFile2)
    || die "Template process failed: ", $template2->error(), "\n";