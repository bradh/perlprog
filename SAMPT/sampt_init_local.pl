#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hc:t:r:");
# my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
my $VERSION = "SAMPT_MCO";
my $REP_ENV = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_CONFIG1 = "C2/UMAT";
my $REP_CONFIG2 = "C2/UMAT";
my $REP_CONFIG3 = "C2/SIMPLE";
my $REP_CONFIG4 = "NON_C2/UMAT";
my $REP_CONFIG5 = "NON_C2/UMAT";
my $REP_CONFIG6 = "NON_C2/SIMPLE";

my $REP_CONFIG_C2 = "/hd1/CONFIG/C2"; # r�pertoire de config
my $REP_CONFIG_NC2 = "/hd1/CONFIG/NC2"; # r�pertoire de config

my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";
my $DLIP_HOTE3 = "200.1.18.6";
my $DLIP_NAME1 = "rackP0";
my $DLIP_NAME2 = "rackP1";
my $DLIP_NAME3 = "rackP3";

# my $DLIP_NAME3 = "rackDEV";
my $DLIP_NAME;
my $RSH_CMD;
my $RSH_CMD1 = "rsh $DLIP_HOTE1 -l root";
my $RSH_CMD2 = "rsh $DLIP_HOTE2 -l root";
my $RSH_CMD3 = "rsh $DLIP_HOTE3 -l root";
my $RCP_CMD1 = "rcp root\@$DLIP_NAME1:/rd1/RUN/";
my $RCP_CMD2 = "rcp root\@$DLIP_NAME2:/rd1/RUN/";
my $RCP_CMD3 = "rcp root\@$DLIP_NAME3:/rd1/RUN/";
# my $RCP_CMD3 = "rcp root\@$DLIP_NAME3:/rd1/RUN/";
my $RACK_NB;
my $DLIP_TYPE;
my $LINK_MODE;

# Tire un lien sur les executables et copie les fichiers de conf
sub link_exe() {
  for $FILE ("C2_PG.cfg", "MP.Param", "SNCP.xml", "SUIP.cfg", "init_GF", "recorder.conf", "sampt_main.cfg", "sampt_main.trc", "slp.mp") {
    print "transfering $FILE...\n";
	if( -e  "$REP_ENV/$FILE") {	
		print "suppression $FILE sur $DLIP_NAME...\n";
		system ("rsh -l root $DLIP_NAME rm -f /rd1/RUN/$FILE");
		print "Copie de $REP_ENV/$FILE vers root\@$DLIP_NAME:/rd1/RUN\n";
		system ("rcp $REP_ENV/$FILE root\@$DLIP_NAME:/rd1/RUN");
	}
  }     
  return 0;
}


if ($opt_h && ! $opt_r && ! $opt_c) { 
	print "sampt_init.pl [-h] [-r n�rack][-c n� de config] [-t config_test]: init du repertoire de run  \n";
	print " config_test : T_Standard (par defaut) ou T_Traversee\n";
	print "exemple 1 : sampt_init.pl -r 1(p0) -c 1 -t: init du repertoire de run en config nonC2 SIMPLE \n";
	print "exemple 2 : sampt_init.pl -r 2(p1) -c 2 : init du repertoire de run en config C2 UMAT  \n";
	print "exemple 3 : sampt_init.pl -r 2(p1) -c 2 -h: liste  \n";
	print "c=1 r�pertoire : $REP_ENV/$REP_CONFIG1\n";
	print "c=2 r�pertoire : $REP_ENV/$REP_CONFIG2\n";
	print "c=3 r�pertoire : $REP_ENV/$REP_CONFIG3\n";
	print "c=4 r�pertoire : $REP_ENV/$REP_CONFIG4\n";
	print "c=5 r�pertoire : $REP_ENV/$REP_CONFIG5\n";
	print "c=6 r�pertoire : $REP_ENV/$REP_CONFIG6\n";
	print "c=7 r�pertoire : $REP_ENV/$REP_CONFIG4\n";
	print "c=8 r�pertoire : $REP_ENV/$REP_CONFIG5\n";
	print "c=9 r�pertoire : $REP_ENV/$REP_CONFIG6\n";
	exit 0;
}
# Si toutes les options sont definies (sauf t optionnelle
if( $opt_c && $opt_r ) {
	my $TEST = "T_STANDARD";
	if($opt_t){
		$TEST = "$opt_t";
	}	
# D�finir le rack
	$RACK_NB = $opt_r;
	$RSH_CMD= $RSH_CMD1;
	$RSH_CMD= $RSH_CMD2 if($opt_r == 2);
	$RSH_CMD= $RSH_CMD3 if($opt_r == 3);
	$DLIP_NAME = $DLIP_NAME1;
	$DLIP_NAME = $DLIP_NAME2 if($opt_r == 2);
	$DLIP_NAME = $DLIP_NAME3 if($opt_r == 3);

# D�finir le r�peroire des config de test ivq
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
		exit 0;
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}
	$REP_ENV="$REP_ENV/$REP_CONFIG1" if ($CONFIG_TEST == 1);
	$REP_ENV="$REP_ENV/$REP_CONFIG2" if ($CONFIG_TEST == 2);
	$REP_ENV="$REP_ENV/$REP_CONFIG3" if ($CONFIG_TEST == 3);
	$REP_ENV="$REP_ENV/$REP_CONFIG4" if ($CONFIG_TEST == 4);
	$REP_ENV="$REP_ENV/$REP_CONFIG5" if ($CONFIG_TEST == 5);
	$REP_ENV="$REP_ENV/$REP_CONFIG6" if ($CONFIG_TEST == 6);

	
	# Liste les r�pertoires de test si l'option -h est positionn�
	if ($opt_h){
		my $TEST_LIST = `ls $REP_ENV`;
		print "Liste des env de test pour la cat�gorie $CONFIG_TEST :\n";
		print "$TEST_LIST\n";
		exit 0;
	}

	$REP_ENV = "$REP_ENV/$VERSION/$TEST";

#Definir le r�pertoire de configuration cible
	if ($CONFIG_TEST > 0  && $CONFIG_TEST <= 3) {
		$REP_CONFIG="$REP_CONFIG_C2";
	}

	if ($CONFIG_TEST > 3  && $CONFIG_TEST <= 6) {
		$REP_CONFIG="$REP_CONFIG_NC2";
	}

	print "From $REP_ENV to root\@$DLIP_NAME:/rd1/RUN\n";
# Copier les fichiers de conf vers le rep cible
    	link_exe();
}
else {
	print "erreur dans les options choisies...\n";
} 
exit 0;


