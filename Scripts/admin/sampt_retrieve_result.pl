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
my $REP_TARGET = "/h7_usr/sil2_usr/samptivq/tests";

my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";


my $REP_TEST_TARGET1 = "$REP_TARGET/C2/UMAT";
my $REP_TEST_TARGET2 = "$REP_TARGET/C2/UMAT";
my $REP_TEST_TARGET3 = "$REP_TARGET/C2/SIMPLE";
my $REP_TEST_TARGET4 = "$REP_TARGET/NON_C2/UMAT";
my $REP_TEST_TARGET5 = "$REP_TARGET/NON_C2/UMAT";
my $REP_TEST_TARGET6 = "$REP_TARGET/NON_C2/SIMPLE";

if ($opt_h) { 
  print "sampt_retrieve_result.pl -c <config nbr> -v <version> -t <nom_du_test> : \n";
  print "\t recopie le répertoire de test du disque dur vers le disque réseau";
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

	$REP_TARGET = "$REP_TEST_TARGET1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_TARGET = "$REP_TEST_TARGET2/$VERSION" if ($CONFIG_TEST == 2);
	$REP_TARGET = "$REP_TEST_TARGET3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_TARGET = "$REP_TEST_TARGET4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_TARGET = "$REP_TEST_TARGET5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_TARGET = "$REP_TEST_TARGET6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_TARGET\n";
	opendir DIR, "$REP_TARGET" or die "Impossible ouvrir $REP_TARGET\n";
	close DIR;

	my $TestName = $opt_t;
	my $TestNameLc = lc  $TestName;

 	if ( ! -d "$REP_TARGET/$TestName"){
		print "creation $REP_TARGET/$TestName...\n";
		system( "mkdir $REP_TARGET/$TestName");
	}
	if( -d "$REP_CONFIG/$TestName"){
		system("cp -r $REP_CONFIG/$TestName/* $REP_TARGET/$TestName");
	}
	else {
		print "$REP_CONFIG/$TestName n'est pas un epertoire...\n";
		exit -1;
	}
exit 0;
}

