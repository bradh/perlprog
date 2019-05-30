#!/usr/bin/perl -w

use Getopt::Std;
use File::Basename;
#use Time::Local;

getopts("hf:");

if ($opt_h) { 
	print "split_file.pl [-f] nom_fichier [-l] nmobre de ligne [-h] : supprime les fom techniques des fichiers résultat .fim \n";
}

if( ! $opt_h && $opt_f ) {
	my $Extension;
	my $Corps;
	my $path;
  	my $INPUT_FILE = $opt_f;
	($Corps,$path,$Extension) = fileparse($INPUT_FILE);
#	print "$Corps $path\n";
	$Corps =~ /(.+)\.(.+)/;
	$Corps = $1;
	$Extension = $2;
#        print "$Corps $Extension $path\n";
  	open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
	while(<Fin>){
		my $LINE = $_;
		if( $LINE =~ /^(\d\d):(\d\d):(\d\d)/){
		  my $Heure = $1;
		  my $Minute = $2;
		  my $OutputFile = "$Corps-$Heure-$Minute.$Extension";
		  open Fout, ">>$OutputFile" or die "Impossible ouvrir $OutputFile  \n";
		  print Fout "$LINE";
		  close Fout;
		}
	      }
      }
close Fin;
exit 0;



