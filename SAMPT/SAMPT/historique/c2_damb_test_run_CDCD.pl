#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hlc:");

my $VERSION_DLIP = "not_defined";
my $DLIP_IP_ADR = "200.1.18.83";
my $DLIP_PORT = "10005";
my $MIDS_PORT = "1024";
my @NOM_PROCESS ;
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/C2_DAMB";
my $REP_TEST_CONFIG1 = "$REP_TEST/Tests_DAMB_CDCD/PIM";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if ($opt_h) { 
	print "$0 [-h] [-c 1 à 9]: init du repertoire de run  \n";
	print "c=1 répertoire test : $REP_TEST/Tests_DAMB_CDCD/PIM\n";
	print "c=2 répertoire test : $REP_TEST_CONFIG2/$VERSION_DLIP\n";
	print "c=3 répertoire test : $REP_TEST_CONFIG3/$VERSION_DLIP\n";
	print "c=4 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=5 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=6 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
	print "c=7 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=8 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=9 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
}

# Si toutes les options sont definies

if( ! $opt_h && $opt_c ) {
	# Definir le repertoire de test
	my $CONFIG_TEST = $opt_c;	
	my $REP_TEST_ATR;
	$REP_TEST_ATR = "$REP_TEST_CONFIG1" if ($CONFIG_TEST == 1);
	$REP_TEST_ATR = "$REP_TEST_CONFIG2" if ($CONFIG_TEST == 2);
	$REP_TEST_ATR = "$REP_TEST_CONFIG3" if ($CONFIG_TEST == 3);
	$REP_TEST_ATR = "$REP_TEST_CONFIG4" if ($CONFIG_TEST == 4);
	$REP_TEST_ATR = "$REP_TEST_CONFIG5" if ($CONFIG_TEST == 5);
	$REP_TEST_ATR = "$REP_TEST_CONFIG6" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATR\n";

# Definir le nom du test
	opendir DIR , $REP_TEST_ATR;
	my @dir = readdir(DIR);
		foreach my $NOM_TEST (@dir) {	
			next if($NOM_TEST =~ /^\./);
			chdir $REP_TEST_ATR;
			if( -d $NOM_TEST ){
				print "Process $NOM_TEST...\n";
				chdir $NOM_TEST;
				system ("rm -f host_test_driver mids_test_driver start osim_test_driver start_scen stop_scen save_log *.log");
				system ("ln -s ../../../../tools/SCCOA/BINAIRES/Test_Drivers/host_test_driver c2_host_test_driver");
				system ("ln -s ../../../../tools/SCCOA/BINAIRES/Test_Drivers/mids_test_driver");
				system ("ln -s ../../../../tools/SCCOA/Tools/start start_scen");
				system ("ln -s ../../../../tools/SCCOA/Tools/stop_scen");
				
		}
	}
	close DIR;
}
exit 0;



