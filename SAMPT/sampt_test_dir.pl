#!/usr/bin/perl -w
# Lance la non reg sampt
#  se base sur la liste des tests dans le fichier /free2/samptivq/tests/NON_C2/reference_ATP/fichiers_communs/sampt_non_reg_test_list.txt

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hc:v:t:r:n:eg");


my $VERSION = "SAMPT_MCO";
$VERSION = $opt_v if($opt_v);

my $NOM_TEST;

my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if($opt_h){
  $opt_h = 0;
  print "$$\n";
  print " $0 -c <config test> -v <DLIP version>   \n";
  print "Lance la mise a jour des repertoires de test\n"; 
  exit 0;
}

if($opt_c) {
	
  
# Definir le repertoire de test ATR  en fonction du type de test
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}
	$REP_TEST_ATR = "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_TEST_ATR = "$REP_TEST_CONFIG2/$VERSION" if ($CONFIG_TEST == 2);
	$REP_TEST_ATR = "$REP_TEST_CONFIG3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_TEST_ATR = "$REP_TEST_CONFIG4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_TEST_ATR = "$REP_TEST_CONFIG5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_TEST_ATR = "$REP_TEST_CONFIG6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATR\n";

# Boucle pour lire l'ensemle des tests
	opendir Fin, "$REP_TEST_ATR" or die "impossible ouvrir $REP_TEST_ATR !";
	my (@DIR) = readdir Fin;
	foreach my $TEST_NAME (@DIR) {
		if ( -d "$REP_TEST_ATR/$TEST_NAME" && $TEST_NAME !~ /^\./  && $TEST_NAME !~ /_PEU/ ){
			print "processing $TEST_NAME\n";
		}
	}
 
}

exit 0;






