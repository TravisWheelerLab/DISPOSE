#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]

my $origin = $ARGV[0];
my %hashIndex;
my %matchIndex;

chdir($origin);
my @submissions = `ls`;
chdir("..");

mkdir "tokenFiles" unless -d "tokenFiles";
mkdir "printFiles" unless -d "printFiles";

# Create a fingerprint for each file
foreach my $sub (@submissions) {
	system("perl Winnower.pl './$origin/$sub' 50");
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

# Create lists of matching fingerprints by doc
foreach my $sub_fp (@sub_fps) {

	chomp $sub_fp;
	open($fh, "<", "./printFiles/$sub_fp")
	    or die "Failed to open file: $sub_fp!\n";

	my %checkedHash;

	while($hashLine = <$fh>) { 
	    ($hashVal, $hashFile, $hashPos) = split(/ /,$hashLine);
	    chomp $hashPos;

	    unless (exists $checkedHash{$hashVal}) {

		    foreach my $potMatch (@ { $hashIndex{$hashVal} }) {
				(my $potFile, my $potPos) = split(/ /, $potMatch);
				unless ($hashFile eq $potFile) {
					push @{ $matchIndex{$hashFile}{$potFile} }, "$hashVal $hashPos $potPos";
				}
			}

			$checkedHash{$hashVal} = 1;
		}
	} 
}

# Show specific match index
# my @test = sort { $a <=> $b } @{ $matchIndex{"48_17_Question1.java"}{"21_46_Board.java"} };
# foreach (@test) {
#   print "$_";
# }
# print ("\n");


my $threshold = 100;
my @suspects;

for my $key (keys %matchIndex) {
	for my $key2 (keys $matchIndex{$key}) {
	    my $matchNum = scalar @{$matchIndex{$key}{$key2}};
	    # print("\n" . $key . " " . $key2 .  " $matchNum\n");
	    if ($matchNum >= $threshold) {
	    	push @suspects, $key . " " . $key2 . " " . $matchNum;
	    }
	}
}

# print("\n\nSUSPECTS\n\n");

# my @suspects_sort = sort { ($a =~ /.+\ (.+)/)[0] <=> ($b =~ /.+\ (.+)/)[0] } @suspects;

# foreach (@suspects_sort) {
#   print "$_\n";
# }
# print ("\n");