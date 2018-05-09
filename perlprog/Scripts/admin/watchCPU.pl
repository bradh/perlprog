#!/usr/bin/perl -w

###################################################################################
##################################################################################

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
		
my $Log_file="watchCPU.log";

# Definition des utilitaires systeme:
my $PS_PROCESS="ps -ax";

my $Delta_echantillon = 6; # en seconde
my $Nbre_echantillon = 30;

if ($opt_h) { 
	print "watchCPU.pl [-h] [-r 1(p0) ou 2(p1) ] [-c 1 ou 9] [-v nom_version][-t nom_test]: mesure le CPU\n";
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
	my %CPU;
	foreach my $Process (@Processes){
		$CPU{$Process}=0;
		#print "$CPU{$Process}\n";
	}
	my %CPU_previous;
	foreach my $Process (@Processes){
		$CPU_previous{$Process}=0;
		#print "$CPU{$Process}\n";
	}


	system("rm -f $Log_file");
	open Fout,">$Log_file" or die "Imposible creer $Log_file\n";
	print Fout "CPU%\t\n";
	foreach my $Process (@Processes){
			print Fout "$Process \t";
	}  
	print Fout "\n";
	close Fout;
	#my $I=$Nbre_echantillon;
	my $I = 1;
	while ($I!=0){
		#print"boucle : $I\n";
		my @PS = (`$RSH_CMD ps -ax`);
		foreach my $LIGNE (@PS) {
      			chomp ($LIGNE);
			#print"$LIGNE\n";
			foreach my $Process (@Processes){
      				if ($LIGNE =~ /$Process/) {
      					$CPU{$Process}= (split " ",$LIGNE) [7];
   					my $PROC_NAME = (split " ", $LIGNE)[10];
      					#print "$RSH_CMD kill -9 $CPU{$Process}\n";
      					#print "$PROC_NAME CPU = $CPU{$Process}\n";
    				}
			}
		}
		# Calcul de nouveau échantillon
		open Fout,">>$Log_file" or die "Imposible creer $Log_file\n";
		foreach my $Process (@Processes){
			if ($CPU{$Process} =~ /\d?:\d?:\d?/){
				my ($heure, $minute, $seconde) = split (":", $CPU{$Process});
				$CPU{$Process} = $heure*3600+$minute*60+$seconde;
			}
			else{
			  if ($CPU{$Process} =~ /\d?:\d?/){
			    my ($minute, $seconde) = split (":", $CPU{$Process});
			    $CPU{$Process} = $minute*60+$seconde;
			  }
			}
			my $tmp = ($CPU{$Process}-$CPU_previous{$Process})/$Delta_echantillon;
			print Fout "$tmp \t";
			print Fout "H : $CPU{$Process} \t";
			print "$Process CPU = $tmp \n";
			$CPU_previous{$Process}= $CPU{$Process};
		} 
		print Fout "\n";
		print "\n";
 		close Fout;
		sleep ${Delta_echantillon};
		#$I= $I-1;
	}
}
exit 0;


