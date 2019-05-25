#!/usr/bin/perl -w

###################################################################################
######################################################################
############

use Getopt::Std;

getopts("hc:v:ust:lr:");
my @NOM_PROCESS ;

my $VERSION_DLIP = "SAMPT_V3P";

my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";


my $REP_RUN = "/rd1/RUN"; # répertoire du test

my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";

my $RSH_CMD;
my $RSH_CMD1 = "rsh   $DLIP_HOTE1 -l root";
my $RSH_CMD2 = "rsh   $DLIP_HOTE2 -l root";

# List des process à surveiller
my @Processes = ( 	"sampt_main",
			"recorder",
			"slp",
			"SNCP");
my $RAM_FREE;
my $RAM_USED;
my $RAM_TOTAL;		
my $Log_file="watchRAM.log";

# Definition des utilitaires systeme:
my $PS_PROCESS="ps -ax";

my $Delta_echantillon = 12; # en seconde
my $Nbre_echantillon = 30;

if ($opt_h) { 
	print "watchRAM.pl [-h] [-r 1(p0) ou 2(p1) ] [-c 1 ou 9] [-v nom_version][-t nom_test]: mesure la RAM\n";
	print "c=1 répertoire test : $REP_TEST_CONFIG1/$VERSION_DLIP\n";
	print "c=2 répertoire test : $REP_TEST_CONFIG2/$VERSION_DLIP\n";
	print "c=3 répertoire test : $REP_TEST_CONFIG3/$VERSION_DLIP\n";
	print "c=4 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=5 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=6 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
	print "c=7 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=8 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=9 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
	exit 0;
}

if( ! $opt_h && $opt_c && $opt_t && $opt_r) {


# Definir la version du DLIP (par defaut $VERSION_DLIP)
	my $VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v"if($opt_v);
# Definir le nom du test
	my $NOM_TEST = "$opt_t";
# Definir le rack
	$RSH_CMD = $RSH_CMD1;
	$RSH_CMD = $RSH_CMD2 if ($opt_r == 2);
# Definir le repertoire de test 
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
		exit 0;
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}
	$REP_TEST = "$REP_TEST_CONFIG1/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 1);
	$REP_TEST = "$REP_TEST_CONFIG2/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 2);
	$REP_TEST = "$REP_TEST_CONFIG3/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 3);
	$REP_TEST = "$REP_TEST_CONFIG4/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 4);
	$REP_TEST = "$REP_TEST_CONFIG5/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 5);
	$REP_TEST = "$REP_TEST_CONFIG6/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 6);
	print "$REP_TEST\n";
	
	chdir($REP_TEST);

	system("rm -f $Log_file");
	open Fout,">$Log_file" or die "Imposible creer $Log_file\n";
	print Fout "RAM totale\tRAM free\t RAM used\n";

	close Fout;
	#my $I=$Nbre_echantillon;
	my $I = 1;
	my @PS;
	while ($I!=0){
		#print"boucle : $I\n";
		@PS = (`$RSH_CMD ps -ax`);
		foreach my $LIGNE (@PS) {
      			chomp ($LIGNE);
			#print"$LIGNE\n";
      				if ($LIGNE =~ /physical\/virtual/) {
				  #print"$LIGNE\n";
      					$RAM_FREE = (split " ",$LIGNE) [0];
					$RAM_FREE = (split "/",$RAM_FREE)[0];
					$RAM_FREE =~ s/K//;
					$RAM_USED = (split " ",$LIGNE) [3];
					$RAM_USED =~ s/K//;
      					print "free :	$RAM_FREE \n";
					print "used : 	$RAM_USED\n";
    				}
		
		}
		# Calcul de nouveau échantillon
		open Fout,">>$Log_file" or die "Imposible creer $Log_file\n";
		$RAM_TOTAL = $RAM_USED + $RAM_FREE;
		print Fout "$RAM_TOTAL\t $RAM_FREE\t $RAM_USED";

		print Fout "\n";
 		close Fout;
		sleep ${Delta_echantillon};
		#$I= $I-1;
	}
}
exit 0;


