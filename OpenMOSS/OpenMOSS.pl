#!/usr/bin/perl

# Usage: perl OpenMOSS.pl [file_dir]


my $origin = $ARGV[0];
my %hashIndex;

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

# Create hash index
foreach my $sub_fp (@sub_fps) {
	chomp $sub_fp;
	open($fh, "<", "./printFiles/$sub_fp")
	    or die "Failed to open file: $sub_fp!\n";
	while($hashLine = <$fh>) { 
	    ($hashVal, $hashPos) = split(/ /,$hashLine);
	    push @{ $hashIndex{$hashVal} }, $hashPos;
	} 
}

for my $key ( sort {$a<=>$b} keys %hashIndex) {
	print("\n" . $key . " ");
    foreach (@ { $hashIndex{$key} }) {
	  print "$_ ";
	}
}