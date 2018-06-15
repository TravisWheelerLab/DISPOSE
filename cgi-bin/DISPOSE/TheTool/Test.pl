#!/usr/bin/perl

#system("java -jar WASTE.jar");

chdir("matchFiles");
@matchFiles = `ls`;
chdir("..");

my $matchIndex = 0;


print("\n");

foreach my $matchFile (@matchFiles) {
	$matchFile = "./matchFiles2/" . $matchFile;
	chomp($matchFile);
	system("perl Highlighter2.pl $matchFile $matchIndex nohbodyz\@gmail.com Java");
	$matchIndex++;
}