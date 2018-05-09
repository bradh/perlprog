#!/usr/bin/perl -w

# 
use strict;
use Getopt::Std;
use lib qw(c:/perlprog/lib);
use Conversion;

my @file_name = ("jre_101_1.log");

foreach my $file (@file_name) {
	open Fin, "<$file" or die "impossible open $file";
	open Fout, ">jre_101_local.log" or die "impossible open jre_.log";
	while (<Fin>){
		my $line = $_;
		$line =~ s/\d{4}\/\d{2}\/\d{2}-//;
		print Fout $line if($line =~ /J3.2/);
	}
	close Fin;
	close Fout;
}
exit 0;