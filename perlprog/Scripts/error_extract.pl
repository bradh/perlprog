#!/usr/bin/perl -w
# Analyse le fichiers log d'un test
# créer un fichier error.txt avec
#  les warning, les errors, les fatal error, les constraint error
#  
# 

use Getopt::Std;

getopts("hc:v:t:");

my $BASE_DIR = "/data/users/loc1int/DLIP/test/test_tu";
my $TARGET_DIR;
my $CAT;
my $VERSION;
my @TEST_LIST;
my $TEST_NAME;
my $TARGET_NAME;
my $FILE_NAME = "loc1_main.log";
my $RESULT_FILE = "error.txt";

if ($opt_h) { 
	print "error_extract.pl -c cat [-h] : liste des versions dlip \n";
	print "error_extract.pl [-c cat] [-v version ][-t nom_du_test]\n";
	print " \n";
}
if ($opt_h && $opt_c && ! $opt_v) {
  $CAT = $opt_c;
  print "categorie = $CAT \n";
  my $LISTE = `ls $BASE_DIR/category$CAT`;
  print "Liste des versions DLIP en test catégorie $CAT :\n";
  print "$LISTE";
  print " \n";
}

if ($opt_h && $opt_c &&  $opt_v && ! $opt_t) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  print "categorie = $CAT \n";
  my $LISTE = `ls $BASE_DIR/category$CAT/$VERSION`;
  print "Liste des tests DLIP en test catégorie $CAT version $VERSION :\n";
  print "$LISTE";
  print " \n";
}

if( ! $opt_h && $opt_c && $opt_v && $opt_t ) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  $TEST_NAME = $opt_t;

  $TARGET_DIR = "$BASE_DIR/category$CAT/$VERSION/$TEST_NAME";

  if(! -d $TARGET_DIR) {
    print "$TARGET_DIR n'est pas un repertoire !\n ";
    exit -1;
  }
  else {   
    open Fout, ">$TARGET_DIR/$RESULT_FILE" or die "not possible to open $TEST_NAME/$RESULT_FILE\n";
    print Fout "##################################################\n";
    print Fout "# Analyse Test $TEST_NAME \n";
    print Fout "###################################################\n";
    if( ! -f "$TARGET_DIR/$FILE_NAME") {
      print Fout "Test $TEST_NAME has not been run\n";	
    }
    else {
      open Fin, "<$TARGET_DIR/$FILE_NAME" or die "not possible to open $TARGET_DIR/$FILE_NAME\n";
      my $error_line = 0 ;
      while(<Fin>){
	if (/^\*/) {
	  print Fout $_;
	  $error_line = 1;
	}
	# if line does not begin by char '+' or '*' and $error_line = 1
	if(  (!/^\*/) && (!/^\+/) &&  $error_line) {
	  print Fout $_;
	}
	# if line begin by char '+'
	if(/^\+/ && $error_line){
	  $error_line = 0;
	}
      }
      close Fin;     
    }
    close Fout;
  }
  exit 0;
}


      
