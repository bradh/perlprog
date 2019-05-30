#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hf:l:");

if ($opt_h) { 
	print "split_file.pl [-f] nom_fichier [-l] nmobre de ligne [-h] : supprime les fom techniques des fichiers résultat .fim \n";
}

if( ! $opt_h && $opt_f && $opt_l) {
	my $extension;
	my $corp;
  	my $INPUT_FILE = $opt_f;
	$INPUT_FILE =~ /(.+)\.(.*)/;
	$corp = $1;
	$extension = $2;
	my $LINE_NBER = $opt_l;
  	my $LINE;
	my $FILE_NBER=1;
	$OUTPUT_FILE = "$corp-$FILE_NBER.$extension";
	print "$OUTPUT_FILE\n";
  	open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
  	open Fout, ">$OUTPUT_FILE" or die "Impossible d'ouvrir $OUTPUT_FILE\n";
	my $count = $LINE_NBER; 
	while(<Fin>){
		$LINE = $_;
		if($count>0){
			print Fout "$LINE";
			$count = $count - 1;
		}
		else{
			print Fout "$LINE";
			close Fout;
			$count = $LINE_NBER;
			$FILE_NBER = $FILE_NBER + 1;
			$OUTPUT_FILE = "$corp-$FILE_NBER.$extension";
			print "$OUTPUT_FILE\n";
			open Fout, ">$OUTPUT_FILE" or die "Impossible d'ouvrir $OUTPUT_FILE\n";
		}	
 	}
	close Fin;
	close Fout;
}
exit 0;


