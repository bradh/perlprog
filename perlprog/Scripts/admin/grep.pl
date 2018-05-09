#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hf:");
(my @toFind) = ( "DEM_EMI_JFT",
		 "Saturation State",
		 "Status_File_Word_X"
	       );
my $OutputFile = "tmp_file.txt";
if ($opt_h) { 
	print "grep.pl -f <filename> : recherche des chaine de caractère dans le fichier \n";
	print " le résultat se trouve dans le fichier $OutputFile \n";
	exit 0;
}

if( ! $opt_h && $opt_f ) {
  open Fin , "<$opt_f" or die "impossible d'ouvlir $opt_f !\n";
  open Fout , ">$OutputFile" or die "impossible d'ouvrir  $OutputFile \n"; 
  while (<Fin>) {
	       my $Line = $_;
	       foreach $String (@toFind){
		 if ($Line =~ /$String/) {
		   print Fout $Line;
		   print $Line;
		   last;
		 }
	       }
	      }
  close Fout;
  close Fin;
}
exit 0;


