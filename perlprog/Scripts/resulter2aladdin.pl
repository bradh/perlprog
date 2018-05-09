#!/usr/bin/perl -w

use Getopt::Std;
use Time::Local;

my $REP_BASE = "/data/users/loc1int/DLIP/test/test_tu";
my $REP_CHECKER = "checker_results";
my $REP_CIBLE;
my $CAT = 1;
my $VERSION;
my $NOM_TEST;
my $TIME = 600;
my $DELTATPS=5; # declage en seconde pour la synchronisation des executables
my $RECAP_RESULTS = 0; # si = 1 compil les resultats dans le repertoires result si = 0 lance le test 
my $FILE;
my $FILE_OUT;
my $LINE;

sub convert{
  $FILE = shift;
  $FILE_OUT = shift;
  open Fin, "<$FILE" or die "Impossible d'ouvrir $FILE\n";
  open Fout, ">$FILE_OUT" or die "Impossible de creer $FILE_OUT\n";
    while(<Fin>){
      chomp;
      $LINE = $_;
      print "$LINE\n";
      if ($LINE =~ s/^>\s*//){
	print Fout "-- Reference :\n";
	print Fout "$LINE\n";
      }
	
      if ($LINE =~ s/^<\s*//){
	print Fout "-- Result :\n";
	print Fout "$LINE\n";
      }
      if ($LINE =~ ! /^>/ and ! $LINE =~ /^</){
	print Fout "-- $LINE\n";
      }
    }
  close Fin;
  close Fout;
}

getopts("hf:c:t:");

if ($opt_h) { 
	print "resulter2aladdin [-h] : liste des versions dlip \n";
	print "resulter2aladdin [-f nom_fichier_xdh.res] : liste des versions dlip \n";
	print "resulter2aladdin [-c] [-t] : liste des versions dlip \n";
	print "adapte la sortie resulter en fichier lisible par aladdin \n";
}


if( ! $opt_h && $opt_f && (! $opt_c || ! $opt_t)) {
  $FILE = $opt_f;
  $FILE_OUT = "$FILE.out";
  convert($FILE, $FILE_OUT);
}
if( ! $opt_h && $opt_c && $opt_t) {
  $CAT = $opt_c;
  $NOM_TEST = $opt_t;
  foreach $FILE (`ls $REP_BASE/category$CAT/$REP_CHECKER/$NOM_TEST/*res`) {
    chomp($FILE);
    print "$FILE\n";
    $FILE_OUT = "$FILE.out";
    convert($FILE, $FILE_OUT);
  }
}
exit 0;


