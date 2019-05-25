#!/usr/bin/perl -w
# Analyse les fichiers log des répertoires de test d'une version
# pour chaque test écrit :
#   le nom du test
#   la version de loc1_main
#   la date 
#   la durée
# calcul le nombre
# de warning 
# d'erreur
# de fatal error
# de constraint error
# 
# liste les tests :
#    sans warning
#    sans erreur
#    sans fatal erreur
#    sans constraint erreur
# 

use Getopt::Std;

getopts("hc:v:");

my $BASE_DIR = "/data/users/loc1int/DLIP/test/test_tu";
my $TARGET_DIR;
my $CAT;
my $VERSION;
my @TEST_LIST;
my $TEST_NAME;
my $FILE_NAME = "loc1_main.log";
my @NOT_PASSED_TEST_LIST;
my @WITHOUT_WARNING_TEST_LIST;
my @WITH_WARNING_TEST_LIST;
my @WITH_ERROR_TEST_LIST;
my @WITH_FATAL_ERROR_TEST_LIST;
my @WITH_CONSTRAINT_ERROR_TEST_LIST;
my $RESULT_DIR = "results";
my $RESULT_FILE = "result_summarize.txt";

if ($opt_h) { 
	print "test_result_summarize.pl -c cat [-h] : liste des versions dlip \n";
	print "test_result_summarize.pl [-c cat] [-v version ]\n";
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

if( ! $opt_h && $opt_c && $opt_v ) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  $TARGET_DIR = "$BASE_DIR/category$CAT/$VERSION";

  if(! -d $TARGET_DIR) {
    print "$TARGET_DIR n'est pas un repertoire !\n ";
    exit -1;
  }

  # Ouverture du fichier resultat
  open Fout, ">$BASE_DIR/category$CAT/$RESULT_DIR/$RESULT_FILE" or die "not possible to open $BASE_DIR/category$CAT/$RESULT_DIR/$RESULT_FILE\n";

  
  # Liste des tests
  for $TEST_NAME (`ls $TARGET_DIR`) {
    chomp ($TEST_NAME);
    if ( ! -d "$TARGET_DIR/$TEST_NAME") {
      print"! $TARGET_DIR/$TEST_NAME n'est pas un repertoire\n";
    }
    else {
 
      # Analyse du fichier log
      system("error_extract.pl -c $CAT -v $VERSION -t $TEST_NAME");
      
      print Fout "*********************************************\n";
      print Fout "* Analyse Test $TEST_NAME \n";
      print Fout "*********************************************\n";
      if( ! -f "$TARGET_DIR/$TEST_NAME/$FILE_NAME") {
	print Fout "$TARGET_DIR/$TEST_NAME/$FILE_NAME has not been run\n";
	push  @NOT_PASSED_TEST_LIST, ("$TEST_NAME");	
      }
      else {

	my $File = "$TARGET_DIR/$TEST_NAME/$FILE_NAME"	;
	my $Version = VersionExtract ($File);
	my $BeginDate = BeginDateExtract ($File);
	my $EndDate = EndDateExtract ($File);
	my $mids_status = MIDS_Mgr_Extract($File);
	my $dts_status = DTS_Mgr_Extract($File);
	my $WARNING_CNT = StarCount(1, $File);
	my $ERROR_CNT = StarCount(2, $File);
	my $FATAL_ERROR_CNT = StarCount(3, $File);
	my $CONSTRAINT_ERROR_CNT = StarCount(4, $File);
	
	print Fout "loc1_main $Version\n";
	print Fout "Begin Date = $BeginDate\n";
	print Fout "End Date = $EndDate\n";
	print Fout "$mids_status\n";
	print Fout "$dts_status\n";
	print Fout "WARNING_CNT = $WARNING_CNT\n";
	print Fout "ERROR_CNT = $ERROR_CNT\n";
	print Fout "FATAL_ERROR_CNT = $FATAL_ERROR_CNT\n";
	print Fout "CONSTRAINT_ERROR_CNT = $CONSTRAINT_ERROR_CNT\n";
	if (!$CONSTRAINT_ERROR_CNT && !$FATAL_ERROR_CNT && ! $ERROR_CNT && !$WARNING_CNT) {
	  print Fout "$TEST_NAME OK\n";
	  push @WITHOUT_WARNING_TEST_LIST, ("$TEST_NAME");
	}
	if (!$CONSTRAINT_ERROR_CNT && !$FATAL_ERROR_CNT && ! $ERROR_CNT && $WARNING_CNT) {
	  push @WITH_WARNING_TEST_LIST, ("$TEST_NAME");
	}
	if (!$CONSTRAINT_ERROR_CNT && !$FATAL_ERROR_CNT &&  $ERROR_CNT) {
	  push @WITH_ERROR_TEST_LIST, ("$TEST_NAME");
	}
	if (!$CONSTRAINT_ERROR_CNT && $FATAL_ERROR_CNT) {
	  push @WITH_FATAL_ERROR_TEST_LIST, ("$TEST_NAME");
	}
	if ($CONSTRAINT_ERROR_CNT) {
	  push @WITH_CONSTRAINT_ERROR_TEST_LIST, ("$TEST_NAME");
	}
      }

      
    }
  }
  
      print Fout "\n####################################################\n";
      print Fout "# Synthese\n";
      print Fout "#####################################################\n";
      my $j=0;
      my $i = scalar @NOT_PASSED_TEST_LIST;
      print Fout "Test not run = \t$i\n";
      $j += $i;
      $i = scalar @WITHOUT_WARNING_TEST_LIST;
      print Fout "Test without warning = \t$i\n";
      $j += $i;
      $i = scalar @WITH_WARNING_TEST_LIST;
      print Fout "Test with warning = \t$i\n";
      $j += $i;
      $i = scalar @WITH_ERROR_TEST_LIST;
      print Fout "Test with error = \t$i\n";
      $j += $i;
      $i = scalar @WITH_FATAL_ERROR_TEST_LIST;
      print Fout "Test with fatal error = \t$i\n";
  $j += $i;
  $i = scalar @WITH_CONSTRAINT_ERROR_TEST_LIST;
  print Fout "Test with constraint error = \t$i\n";
  $j += $i;
  print Fout "Total test number = \t$j\n";
  print Fout "\n Test not run list :\n";
  for my $Test (@NOT_PASSED_TEST_LIST){
    print Fout "\t$Test\n";
  }
  print Fout "\n Test without warning list :\n";
  for my $Test (@WITHOUT_WARNING_TEST_LIST) {
    print Fout "\t$Test\n";
  }
  print Fout "\n Test with warning list :\n";
  for my $Test (@WITH_WARNING_TEST_LIST) {
    print Fout "\t$Test\n";
  }
  print Fout "\n Test with error list :\n";
  for my $Test (@WITH_ERROR_TEST_LIST) {
    print Fout "\t$Test\n";
  }
  print Fout "\n Test with fatal error list :\n";
  for my $Test (@WITH_FATAL_ERROR_TEST_LIST) {
    print Fout "\t$Test\n";
  }
  print Fout "\n Test with contraint error list :\n";
  for my $Test (@WITH_CONSTRAINT_ERROR_TEST_LIST) {
    print Fout "\t$Test\n";
  }
  close Fout;
  # Concatenation des fichiers error.txt dans error_global.txt
  print "recherche dans $TARGET_DIR et resultat dans $RESULT_DIR/global_error.txt\n";
  system("find $TARGET_DIR -name error.txt -exec cat {} > $BASE_DIR/category$CAT/$RESULT_DIR/global_error.txt \\;"); 
}
exit 0;

sub VersionExtract {
  my $File = shift;
  my $Version = "unkwon";
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    if(/Binary version : (.*)/) { $Version = $1;} 
  }
  close Fin;
  return $Version;
}
sub MIDS_Mgr_Extract {
  my $File = shift;
  my $Version = "MIDS not operational !";
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    #MIDS_Mgr (3) : OPERATIONAL
    if(/(MIDS_Mgr \(\d\) : OPERATIONAL)/) { $Version = $1;} 
  }
  close Fin;
  return $Version;
}
sub DTS_Mgr_Extract {
  my $File = shift;
  my $Version = "DTS not operational !";
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    # DTS_Mgr (1) : OPERATIONALDTS_Mgr (3) : OPERATIONAL
    if(/( DTS_Mgr \(\d\) : OPERATIONAL)/) { $Version = $1;} 
  }
  close Fin;
  return $Version;
}

sub BeginDateExtract {
  my $File = shift;
  my $Date = "unknwon";
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    if(/Launch date    :(.*)/) { $Date = $1;}
  }
  close Fin;
  return $Date;
}
sub EndDateExtract {
  my $File = shift;
  my $Date = "unkwon";
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    if(/Shutdown date  :(.*)/) { $Date = $1;}
  }
  close Fin;
  return $Date;
}
sub StarCount {
  my $StartCnt = shift;
  my $File = shift;
  # print "StartCnt = $StartCnt\n";
  my $Trouble = 0;
  open Fin, "<$File" or die "not possible to open $File\n";
  while(<Fin>) {
    if(/^\*{$StartCnt}\s/) {$Trouble += 1};
  }
  close Fin;
  return $Trouble;
}
      
