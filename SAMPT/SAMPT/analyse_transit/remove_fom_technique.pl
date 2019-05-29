#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hsf:");

if ($opt_h) { 
	print "remove_fom_technique [-f] nom_fichier [-h] : supprime les fom techniques des fichiers résultat .fim -s pour sauver le fichier original \n";
}

if( ! $opt_h && $opt_f ) {
  	my $INPUT_FILE = $opt_f;
  	my $OUTPUTFILE = "TEMP.fom";
  	my $LINE;
  	open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
  	open Fout, ">$OUTPUTFILE" or die "Impossible d'ouvrir $OUTPUTFILE\n";
	while(<Fin>){
 		# Recherche 	04000001 pour les FOM01
		#		06000001 pour les FIM01	
  		$LINE = $_;	
 		if( $LINE =~ /^.{22}04000001/|| $LINE =~ /^.{22}06000001/){
			print Fout "$LINE";
		}
	}
	close Fin;
	close Fout;
	system("mv $INPUT_FILE $INPUT_FILE.save") if($opt_s);
	system("mv $OUTPUTFILE $INPUT_FILE");
}
exit 0;


