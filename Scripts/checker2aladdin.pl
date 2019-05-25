#!/usr/bin/perl -w

use Getopt::Std;
use Time::Local;

getopts("hf:");

my $NOM_TEST;

if ($opt_h) { 
	print "checker2aladdin.pl [-h] [-f nom_fichier_xdh] \n";
	print " Adapte la sortie du checker pour etre lu par aladdin\n";
}


if( ! $opt_h && $opt_f) {
  my $FILE = $opt_f;
  my $FILE_OUT = "$FILE.out";
  open Fin, "<$FILE" or die "Impossible d'ouvrir $REP_DUREE/$DURATION_FILE\n";
  open Fout, ">$FILE_OUT" or die "Impossible de creer $FILE_OUT\n";
    while(<Fin>){
      chomp;
      $LINE = $_;
      print "$LINE\n";
      if ($LINE =~ /(Reference Message\s:)/){
	print Fout "-- $1\n";
	$LINE =~ s/\s*(Reference Message\s:\s*)//;
	$LINE =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s*(.*)$/;
	$TIME = $1;
	$MESSAGE = $2;
	$MESSAGE =~ s/\s//g;
	$MESSAGE =~ s/(.{8})/$1 /g;
	print Fout "$TIME $MESSAGE\n";
      }
	
      if ($LINE =~ /(Result Message\s:)/){
	print Fout "-- $1\n";
	$LINE =~ s/\s*(Result Message\s:\s*)//;
	$LINE =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s*(.*)$/;
	$TIME = $1;
	$MESSAGE = $2;
	$MESSAGE =~ s/\s//g;
	$MESSAGE =~ s/(.{8})/$1 /g;
	print Fout "$TIME $MESSAGE\n";
      }
      if ($LINE =~ ! /(Reference Message\s:)/ and ! $LINE =~ /(Result Message\s:)/){
	print Fout "-- $LINE\n";
      }
    }
  close Fin;
  close Fout;
  exit 0;
}
