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
	system("perl Winnower.pl './$origin/$sub' 5");
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

	while($hashLine = <$fh>) { 
	    ($hashVal, $hashFile, $hashPos) = split(/ /,$hashLine);

	    foreach my $potMatch (@ { $hashIndex{$hashVal} }) {
			(my $potFile, my $potPos) = split(/ /, $potMatch);
			unless ($hashFile eq $potFile) {
				push @{ $matchIndex{$hashFile}{$potFile} }, $potPos;
			}
		}
	} 
}

my $threshold = 100000;
my @suspects;

for my $key ( sort {$a<=>$b} keys %matchIndex) {
	for my $key2 ( sort {$a<=>$b} keys $matchIndex{$key}) {
		print("\n" . $key . " " . $key2 .  " ");
	    my $matchNum = scalar @{$matchIndex{$key}{$key2}};
	    print("$matchNum\n");
	    if ($matchNum >= $threshold) {
	    	push @suspects, $key . " " . $key2 . " " . $matchNum;
	    }
	}
}

print("\n\nSUSPECTS\n\n");

foreach (@suspects) {
  print "$_\n";
}
print ("\n");