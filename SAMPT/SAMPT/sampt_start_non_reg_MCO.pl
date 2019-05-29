#!/usr/bin/perl -w
# Lance la non reg sampt
#  se base sur la liste des tests dans le fichier /free2/samptivq/tests/NON_C2/reference_ATP/fichiers_communs/sampt_non_reg_test_list.txt

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hliuc:v:t:");


my $VERSION = "SAMPT_MCO";

my $TEST_NAME_INPUT = "";
$TEST_NAME_INPUT = $opt_t if( defined $opt_t);

my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

my @TEST_LIST;
my (@C2_UMAT_TEST_LIST) = (
#"T_C2_FT63584-Reset_Own_TN", KO
#"Space_Track",
#"T_C2_CGA_COM",
#n"T_C2_CGA_ENG",
"T_C2_CORRELATION_STALENESS",
"T_C2_FT95050",
"T_C2_FT_95097_THD170_BLOCK10_ANNULUS_FILTER",
"T_C2_IT_MSG",
#"T_C2_MNG_UMAT_003",
#"T_C2_NONC2AA_INTEROP",
#"T_C2_OSIM_CHECK_001",
#"T_C2_OSIM_CHECK_002",
#"T_C2_OSIM_CHECK_003",
"T_C2_PACKING_LIMIT",
"T_C2_PIM_RX",
#"T_C2_PIM_RX_MARTHA_SAMPT",
#"T_C2_PIM_TX",
#"T_C2_PIM_TX_CC",
#"T_C2_PIM_TX_CUT",
#"T_C2_PIM_TX_MARTHA_SAMPT",
"T_C2_PPLI_AP_CHANGE",
"T_C2_SURV_CNF_001",
"T_C2_SURV_CNF_002",
#"T_C2_SURV_CNF_002_MARTHA_SAMPT",
#"T_C2_SURV_COR_LINK",
#"T_C2_TIME_TAGGING_UMAT",
#"T_C2_TRANSIT_TIME",
"T_FT_95064_FILTRAGE_HOSTILE",
"T_FT_95064_FILTRAGE_HOSTILE_MARTHA_SAMPT",
"T_FT_95066_FILTRAGE_PPLI",
"T_FT_95066_FILTRAGE_PPLI_MARTHA_SAMPT",
"T_FT_95067_THD170_BLOCK30_INOUT",
"T_FT_95067_THD170_BLOCK30_INOUT_MARTHA_SAMPT",
"T_FT_95076_J3_2_WITH_C2_AND_C3",
"T_FT_95076_NON_REG_J2_5_MARTHA_SAMPT",
"T_FT_95076_NON_REG_J3_7_MARTHA_SAMPT",
"T_FT_95076_OWN_TN_MARTHA_SAMPT",
"T_FT_95086_J9_0_RX_KO",
"T_FT_95101_C2_SEND_CANTPRO_EVEN_NOT_IN_MIP_RX",
"T_FT_95130_IPP_LP_R2_RELATED_TO_SPACE_TRACK_R2",
"T_FT_95155_J10_2_EFFECTIVE_TX",
#"T_LAUCHER_CHECK",
#"T_NONC2AA_C2_INTEROP",
);


if($opt_h){
  $opt_h = 0;
  print "$$\n";
  print " $0 -c <config test> -v <DLIP version>   \n";
  print "Lance la non reg des repertoires de test\n"; 
  print "-l liste les tests\n";
  print "-u met a jour les fichiers de conf des TD\n";
  print "-t <nom du test> traite 1 seul test\n";
  print "-i interactif s arrete à chaque test\n";
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
	if ($CONFIG_TEST == 1){
		$REP_TEST_ATR= "$REP_TEST_CONFIG1/$VERSION" ;
		@TEST_LIST = (@C2_UMAT_TEST_LIST); 
	}
	if ($CONFIG_TEST == 2){
		$REP_TEST_ATR = "$REP_TEST_CONFIG2/$VERSION" ;
	}
	if ($CONFIG_TEST == 3){
		$REP_TEST_ATR = "$REP_TEST_CONFIG3/$VERSION" ;
	}
	if ($CONFIG_TEST == 4){
		$REP_TEST_ATR = "$REP_TEST_CONFIG4/$VERSION";
	}
	if ($CONFIG_TEST == 5){
		$REP_TEST_ATR = "$REP_TEST_CONFIG5/$VERSION";
	}
	if ($CONFIG_TEST == 6){
		$REP_TEST_ATR = "$REP_TEST_CONFIG6/$VERSION" ;
	}
	print "$REP_TEST_ATR\n";

	chdir ("$REP_TEST_ATR");
	
	if($opt_l){
		#my $list = `sampt_update_config_MCO.pl -c $opt_c -l`;
		print "@TEST_LIST";
		#exit 0;
		
	}
	# Boucle pour lire l'ensemle des tests
	opendir Dir, "$REP_TEST_ATR" or die "impossible ouvrir $REP_TEST_ATR !";
	my (@DIR) = readdir Dir;
	
	
	foreach my $TEST_NAME (@TEST_LIST) {
		print "$TEST_NAME  $TEST_NAME_INPUT \n";
		my $test_name = lc $TEST_NAME;
		if ( $TEST_NAME eq "$TEST_NAME_INPUT"  || $TEST_NAME_INPUT eq "") {
			if ( ! (defined $opt_l) && -d "$REP_TEST_ATR/$TEST_NAME" && $TEST_NAME !~ /^\./  && $TEST_NAME !~ /_PEU/ ){
				my $current_dir;
				print "processing $TEST_NAME ...\n";
				if ( $opt_i) {
					print " Do you want to run $TEST_NAME ? (y/n) \n";
					my $ans = <>;
					next if( $ans !~ /^y/);
				}
				system("sampt_start_test_MCO.pl -r 1 -c  $opt_c -t $TEST_NAME -i -l");
			}
		}
	}
	close Dir;
}

exit 0;






