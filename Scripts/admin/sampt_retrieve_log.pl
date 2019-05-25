#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 04/01/2008
# Description :

use Getopt::Std;

use Getopt::Std;

getopts("hr:c:v:t:");

my $VERSION_DLIP = "SAMPT_V5";

my $DLIP_HOTE1 = "rackP0";
my $DLIP_HOTE2 = "rackP1";

my $REP_TEST = "/free2/samptivq/tests";
my $REP_RUN = "/rd1/RUN";

my $RCP_CMD;
my $RCP_CMD1 = "rcp root\@$DLIP_HOTE1:$REP_RUN/*.log";
my $RCP_CMD2 = "rcp root\@$DLIP_HOTE2:$REP_RUN/*.log";

my @NOM_PROCESS ;


my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";


if ($opt_h) { 
  print "sampt_retrieve_log.pl -r <n° rack> -c <config nbr> -v <version> -t <nom_du_test> : \n";
  print "\t recopie les fichiers log du rack Lynx vers le répertoirte de test";
  exit(0);
}

# Si toutes les options sont definies

if( ! $opt_h && $opt_r && $opt_c && $opt_t) {

# Definir le rack
	$RCP_CMD = $RCP_CMD1;
	$RCP_CMD = $RCP_CMD2 if ($opt_r == 2);

# Definir la version du DLIP (par defaut $VERSION_DLIP)
	my $VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v" if($opt_v);

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

	if( -d "$REP_CONFIG/$TestName/ATR"){
		system("$RCP_CMD $REP_CONFIG/$TestName/ATR ");
	}
	else {
		print "$REP_CONFIG/$TestName/ATR n'est pas un repertoire...\n";
		exit -1;
	}
exit 0;
}

