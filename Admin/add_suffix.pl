#!/usr/bin/perl
# Disk Monitor
# USAGE: dmon <mount> <percent>
# e.g.: dmon /usr 80

use File::Copy;

my $current_directory = "D:\\Users\\t0028369\\Documents\\Affaires\\SAMPT\\Essai\ Mantova\\essai_004";

opendir(DIR, $current_directory);
my @files = readdir(DIR);

chdir($current_directory);

foreach my $file (@files){
	print "$file\n";
	if( $file =~ /cil16_csi/){
		system("rename $file,  $file.pcap");
	}
}

exit 0;
