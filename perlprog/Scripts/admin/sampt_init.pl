#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hc:t:r:");
# my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
my $REP_ENV = "/h7_usr/sil2_usr/samptivq/TEST_ENV";
my $REP_CONFIG1 = "C2/UMAT";
my $REP_CONFIG2 = "C2/UMAT";
my $REP_CONFIG3 = "C2/SIMPLE";
my $REP_CONFIG4 = "NONC2/UMAT";
my $REP_CONFIG5 = "NONC2/UMAT";
my $REP_CONFIG6 = "NONC2/SIMPLE";

my $REP_CONFIG_C2 = "/hd1/CONFIG/C2"; # répertoire de config
my $REP_CONFIG_NC2 = "/hd1/CONFIG/NC2"; # répertoire de config

my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";
my $DLIP_NAME1 = "rackP0";
my $DLIP_NAME2 = "rackP1";
my $DLIP_NAME;
my $RSH_CMD;
my $RSH_CMD1 = "rsh $DLIP_HOTE1 -l root";
my $RSH_CMD2 = "rsh $DLIP_HOTE2 -l root";
my $RCP_CMD1 = "rcp root\@$DLIP_NAME1:/rd1/RUN/";
my $RCP_CMD2 = "rcp root\@$DLIP_NAME2:/rd1/RUN/";
my $RACK_NB;
my $DLIP_TYPE;
my $LINK_MODE;

# Tire un lien sur les executables et copie les fichiers de conf
sub link_exe() {
  for $FILE (`ls  $REP_ENV/`) {
    chomp $FILE;
	if (-f "$REP_ENV/$FILE" && $opt_r < 4){
	 if($FILE =~ /\.trc/ ||$FILE =~ /recorder\.bp/ || $FILE =~ /init_GF/ ){
	   print "Copie de $REP_ENV/$FILE vers root\@$DLIP_NAME:/rd1/RUN\n";
	   system ("rcp $REP_ENV/$FILE root\@$DLIP_NAME:/rd1/RUN");
	 }
	 if($FILE =~ /\.conf/ ||$FILE =~ /\.cfg/ || $FILE =~ /.*\..*/ || $FILE =~ /\.xml/ || $FILE =~ /\.mp/|| $FILE =~ /slp.bp/ ){
	   print "Copie de $REP_ENV/$FILE vers root\@$DLIP_NAME:/hd1/CONFIG/C2/\n";
	   system ("rcp $REP_ENV/$FILE root\@$DLIP_NAME:/hd1/CONFIG/C2/");
	 }
	}
	if (-f "$REP_ENV/$FILE" && $opt_r > 3){
	 if($FILE =~ /\.trc/ ||$FILE =~ /recorder\.bp/ || $FILE =~ /init_GF/ ){
	   print "Copie de $REP_ENV/$FILE vers root\@$DLIP_NAME:/rd1/RUN\n";
	   system ("rcp $REP_ENV/$FILE root\@$DLIP_NAME:/rd1/RUN");
	 }
	 if($FILE =~ /\.conf/ ||$FILE =~ /\.cfg/ || $FILE =~ /.*\..*/ || $FILE =~ /\.xml/ || $FILE =~ /\.mp/ || $FILE =~ /slp.bp/ ){
	   print "Copie de $REP_ENV/$FILE vers root\@$DLIP_NAME:/hd1/CONFIG/NC2/\n";
	   system ("rcp $REP_ENV/$FILE root\@$DLIP_NAME:/hd1/CONFIG/NC2/");
	 }
	}
       }     
  return 0;
}


if ($opt_h && ! $opt_r && ! $opt_c) { 
	print "sampt_init.pl [-h] [-r n°rack][-c n° de config] [-t config_test]: init du repertoire de run  \n";
	print " config_test : T_Standard (par defaut) ou T_Traversee\n";
	print "exemple 1 : sampt_init.pl -r 1(p0) -c 1 -t: init du repertoire de run en config nonC2 SIMPLE \n";
	print "exemple 2 : sampt_init.pl -r 2(p1) -c 2 : init du repertoire de run en config C2 UMAT  \n";
	print "exemple 3 : sampt_init.pl -r 2(p1) -c 2 -h: liste  \n";
	print "c=1 répertoire : $REP_ENV/$REP_CONFIG1\n";
	print "c=2 répertoire : $REP_ENV/$REP_CONFIG2\n";
	print "c=3 répertoire : $REP_ENV/$REP_CONFIG3\n";
	print "c=4 répertoire : $REP_ENV/$REP_CONFIG4\n";
	print "c=5 répertoire : $REP_ENV/$REP_CONFIG5\n";
	print "c=6 répertoire : $REP_ENV/$REP_CONFIG6\n";
	print "c=7 répertoire : $REP_ENV/$REP_CONFIG4\n";
	print "c=8 répertoire : $REP_ENV/$REP_CONFIG5\n";
	print "c=9 répertoire : $REP_ENV/$REP_CONFIG6\n";
	exit 0;
}
# Si toutes les options sont definies (sauf t optionnelle
if( $opt_c && $opt_r ) {
	my $TEST = "T_STANDARD";
	if($opt_t){
		$TEST = "$opt_t";
	}	
# Définir le rack
	$RACK_NB = $opt_r;
	$RSH_CMD= $RSH_CMD1;
	$RSH_CMD= $RSH_CMD2 if($opt_r == 2);
	$DLIP_NAME = $DLIP_NAME1;
	$DLIP_NAME = $DLIP_NAME2 if($opt_r == 2);

# Définir le réperoire des config de test ivq
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

	
	# Liste les répertoires de test si l'option -h est positionné
	if ($opt_h){
		my $TEST_LIST = `ls $REP_ENV`;
		print "Liste des env de test pour la catégorie $CONFIG_TEST :\n";
		print "$TEST_LIST\n";
		exit 0;
	}

	$REP_ENV = "$REP_ENV/$TEST";

#Definir le répertoire de configuration cible
	if ($CONFIG_TEST > 0  && $CONFIG_TEST <= 3) {
		$REP_CONFIG="$REP_CONFIG_C2";
#		print "toto\n";
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


