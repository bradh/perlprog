#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 04/01/2008
# Description :

use Getopt::Std;

use Getopt::Std;

getopts("hc:v:t:");

my $VERSION_DLIP = "SAMPT_V5";

my @NOM_PROCESS ;
my $REP_TEST = "/free2/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";


if ($opt_h) { 
  print "sampt_process_process.pl -c <config nbr> -v <version> -t <nom_du_test> : \n";
  print "\t formatte les fichiers .xdh et .fim\n";
  print "\t supprime les messages techniques des .fim et des .xdh\n";
  print "\t commente le fom12  technique dans le .fom \n"; 
  print "\t lance compas\n";
  exit(0);
}

# Si toutes les options sont definies

if( ! $opt_h && $opt_c && $opt_v) {
# Definir la version du DLIP (par defaut $VERSION_DLIP)
	my $VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v";


# Definir le repertoire de test ATR et ATP
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}

	$REP_CONFIG = "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_CONFIG = "$REP_TEST_CONFIG2/$VERSION" if ($CONFIG_TEST == 2);
	$REP_CONFIG = "$REP_TEST_CONFIG3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_CONFIG = "$REP_TEST_CONFIG4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_CONFIG = "$REP_TEST_CONFIG5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_CONFIG = "$REP_TEST_CONFIG6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_CONFIG\n";

	my $TestName = $opt_t;
	my $TestNameLc = lc  $TestName;
	
	my $REP_TEST = "$REP_CONFIG/$TestName/ATR";

	chdir("$REP_TEST");
	print"$REP_TEST\n";

	# Cas des tests de type UMAT
	if($CONFIG_TEST == 1 || $CONFIG_TEST == 2 || $CONFIG_TEST == 4 || $CONFIG_TEST == 5){

		if( -f "$TestNameLc.fim"){
			print " format2boctet $TestNameLc.fim\n";
			system("format2boctet.pl -f $TestNameLc.fim");
			system("remove_fom_technique.pl -f $TestNameLc.fim");
		}
		else {
			print "Impossible de trouver $TestNameLc.fim !\n";
		}
		if( -f "$TestNameLc.xdh"){
			print " format2boctet $TestNameLc.xdh\n";
			system("format2boctet.pl -f   $TestNameLc.xdh");
			system("remove_xdh_technique.pl -f $TestNameLc.xdh");
		}
		else {
			print "Impossible de trouver $TestNameLc.xdh !\n";
		}

	}
	print "# Lancement de compas ...\n";
	system("compas > compas.log");
	system ("more *.report >> compas.log");
	system ("cat compas.log");

exit 0;
}

