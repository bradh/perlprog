#!/usr/bin/perl -w
use strict;

my $file_number = 120;
my $file_size = 2000000;
my $file_ext = "rcd";
my $file_prefix = "SAMPT_recording_test_file";



open Fout, ">$file_prefix.$file_ext" or die " not possible create $file_prefix.$file_ext\n ";

foreach my $i (1.. $file_size){
	print Fout "A";
}

close Fout;

foreach my $i (1..$file_number){
	my $new_file_prefix = $file_prefix . '_'. $i;
	system ( "copy  /Y $file_prefix.$file_ext $new_file_prefix.$file_ext");
}

exit 0;

