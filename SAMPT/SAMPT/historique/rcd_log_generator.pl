#!/usr/bin/perl -w

# Affaire : JFACCC SAMPT
# Tâche : création de fichier .rcd .log
# Auteur : S. Mouchot
# Mis à jour : le 04/05/2014
# Description :
# translate le temps d'un fichier TD

use Getopt::Std;


getopts("h");

my $rcd_dir ="/home/jfacc_op/Ops/JREP/trace";
my $file_name = "dump_file_";
my $file_number = 20000;
my $file_size1 = 10000000; # en octet

# chdir $rcd_dir;

while ($file_number > 0) {
	$file_size = $file_size1;
	print "crearte $file_name$file_number.rcd .log \n";
	open Fout1, ">$file_name$file_number.rcd" or die "Impossible d'ouvrir $file_name$file_number.rcd";
	open Fout2, ">$file_name$file_number.log" or die "Impossible d'ouvrir $file_name$file_number.rcd";
	
	while($file_size/10 > 0) {
		print Fout1 "AAAAAAAAAA\n";
		print Fout2 "BBBBBBBBBB\n";
		$file_size = $file_size -1;
	}
	close Fout1;
	close Fout2;
	$file_number = $file_number -1 ;
	sleep 10
}
exit 0;