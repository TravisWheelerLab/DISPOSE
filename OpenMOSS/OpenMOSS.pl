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
	system("perl Winnower.pl './$origin/$sub' 10");
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
# my $testFile = "wut.txt";
# open(my $fh, ">", $testFile)
# 	or die "Failed to open file: '$testFile'!\n";
# my @test = sort { ($a =~ /.+ (.+) .+/)[0] <=> ($b =~ /.+ (.+) .+/)[0] } @{ $matchIndex{"63_240_IntersectionOfTwoArrays.java"}{"63_241_IntersectionOfTwoArrays2.java"} };
# foreach (@test) {
#   print $fh "$_";
# }
# print $fh ("\n");

# my @test2 = sort { ($a =~ /.+ .+ (.+)/)[0] <=> ($b =~ /.+ .+ (.+)/)[0] } @{ $matchIndex{"63_240_IntersectionOfTwoArrays.java"}{"63_241_IntersectionOfTwoArrays2.java"} };
# foreach (@test2) {
#   print $fh "$_";
# }
# print $fh ("\n");

close $fh;

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

print("\n\nSUSPECTS\n\n");

my @suspects_sort = sort { ($b =~ /.+ (.+)/)[0] <=> ($a =~ /.+ (.+)/)[0] } @suspects;

my $SUSLIMIT = 250;

for (my $i = 0; $i < $SUSLIMIT; $i = $i+1) {
  print "$suspects_sort[$i]\n";
}
print ("\n");