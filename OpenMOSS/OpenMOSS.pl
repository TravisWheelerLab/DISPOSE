#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]

use List::MoreUtils qw(uniq);
use Cwd qw(getcwd);
use Winnower;

my $origin = $ARGV[0];
my $matchLim = 10;
my %hashIndex;
my %matchIndex;
my %countIndex;

my $workDir = getcwd;

chdir($origin);
my @submissions = `ls`;
chdir($workDir);

mkdir "tokenFiles" unless -d "tokenFiles";
mkdir "printFiles" unless -d "printFiles";
mkdir "matchFiles" unless -d "matchFiles";


# Create a fingerprint for each file
foreach my $sub (@submissions) {
	winnow("./$origin/$sub", 50, \%countIndex);
}

chdir("printFiles");
my @sub_fps = `ls`;
chdir("..");

my $fh;
my $hashLine;
my $hashVal;
my $hashPos;
my $hashFile;

# Create hash index
foreach my $sub_fp (@sub_fps) {
	chomp $sub_fp;
	open($fh, "<", "./printFiles/$sub_fp")
	    or die "Failed to open file: $sub_fp!\n";
	while($hashLine = <$fh>) { 
	    ($hashVal, $hashFile, $hashPos) = split(/ /,$hashLine);
	    push @{ $hashIndex{$hashVal} }, $hashFile . " " . $hashPos;
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
	    ($hashVal, $hashFile, $hashPos) = split(/ /,$hashLine);
	    chomp $hashPos;

	    unless (exists $checkedHash{$hashVal}) {

			unless ($countIndex{$hashVal} > $matchLim) {
				foreach my $potMatch (@ { $hashIndex{$hashVal} }) {
					(my $potFile, my $potPos) = split(/ /, $potMatch);

					unless ($hashFile eq $potFile) {
						push @{ $matchIndex{$hashFile}{$potFile} }, "$hashVal $hashPos $potPos";
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

	createMatchFile($name1, $name2);

	system(`perl Highlighter.pl ./$origin/$name1 ./$origin/$name2`);

}
print ("\n");


sub createMatchFile {
	my $name1 = $_[0];
	my $name2 = $_[1];

	my $matchFile = "./matchFiles/" . $name1 . "_" . $name2 . "_match.txt";
	
	open(my $fh2, ">", $matchFile)
		or die "Failed to open file: '$matchFile'!\n";

	my @order1 = sort { ($a =~ /.+ (.+) .+/)[0] <=> ($b =~ /.+ (.+) .+/)[0] } @{ $matchIndex{$name1}{$name2} };
	foreach (@order1) {
	  print $fh2 "$_";
	}
	print $fh2 ("\n");

	my @order2 = sort { ($a =~ /.+ .+ (.+)/)[0] <=> ($b =~ /.+ .+ (.+)/)[0] } @{ $matchIndex{$name1}{$name2} };
	foreach (@order2) {
	  print $fh2 "$_";
	}

	close $fh2;
}