#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hcusv:t:");

my $VERSION_DLIP = "SAMPT_V4";

my @NOM_PROCESS ;
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests/C2";
my $REP_REF_ATP = "$REP_TEST/reference_ATP_V4";
my $REP_FIC_COMM = "$REP_REF_ATP/fichiers_communs";
my $REP_TEST_REF_COMM = "$REP_REF_ATP/COMMUNS";
my $REP_TEST_REF_UMAT = "$REP_REF_ATP/UMAT";
my $REP_TEST_REF_SIMPLE = "$REP_REF_ATP/SIMPLE";
my $NOM_FIC_INIT_UMAT = "C2_INIT_UMAT.xhd";
my $NOM_FIC_INIT_SIMPLE = "C2_INIT_SIMPLE.xhd";
my $REP_TEST_RUN_UMAT = "$REP_TEST/UMAT/SAMPT_V4" ;
my $REP_TEST_RUN_SIMPLE = "$REP_TEST/SIMPLE/SAMPT_V4";

if ($opt_h) { 
  print "sampt_gen_scenario_c2_V4.pl [-h] [-s][-u][c]: nettoie les repertoire de resultat (tous les repertoires) UMAT, SIMPLE sous le rep ATR !  \n";
}
# Cas ou l'on remet à jour tous les tests
if( ! $opt_h && ! $opt_t) {

  # Traitement des tests UMAT
  if($opt_u){
    print "\n****** Traitement des tests UMAT \n";
    chdir("$REP_TEST_RUN_UMAT");
    foreach $TEST (`ls`){
      chomp $TEST;
      print "\n***** Traitement $REP_TEST_RUN_UMAT/$TEST\n";
      foreach my $REP_RESULT (`ls $REP_TEST_RUN_UMAT/$TEST/ATR/`){
	chomp $REP_RESULT;
	#print "$REP_TEST_RUN_UMAT/$TEST/ATR/$REP_RESULT\n";	
	if ( -d "$REP_TEST_RUN_UMAT/$TEST/ATR/$REP_RESULT" ){
	  print "rm -fr $TEST/ATR/$REP_RESULT\n";
	  system("rm -fr $TEST/ATR/$REP_RESULT");
	}
	else {
	  # print "$TEST/ATR/$REP_RESULT n'est pas un répertoire ...\n";
	}
      }
    }
  }
  # Traitement des tests UMAT
  if($opt_s){
    print "\n****** Traitement des tests UMAT \n";
    chdir("$REP_TEST_RUN_SIMPLE");
    foreach $TEST (`ls`){
      chomp $TEST;
      print "\n***** Traitement $REP_TEST_RUN_SIMPLE/$TEST\n";
      foreach my $REP_RESULT (`ls $REP_TEST_RUN_SIMPLE/$TEST/ATR/`){
	chomp $REP_RESULT;
	#print "$REP_TEST_RUN_SIMPLE/$TEST/ATR/$REP_RESULT\n";	
	if ( -d "$REP_TEST_RUN_SIMPLE/$TEST/ATR/$REP_RESULT" ){
	  print "rm -fr $TEST/ATR/$REP_RESULT\n";
	  system("rm -fr $TEST/ATR/$REP_RESULT");
	}
	else {
	  # print "$TEST/ATR/$REP_RESULT n'est pas un répertoire ...\n";
	}
      }
    }
  }
}
exit 0;
      



