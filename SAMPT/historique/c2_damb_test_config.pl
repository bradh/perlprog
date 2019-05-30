#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hlc:");

my $debug = 0;

my $VERSION_DLIP = "V1R0E1_beta";
my $EXE_DIR = "../../../EXECUTABLES/CDCD";
my $DLIP_IP_ADR = "200.1.18.83";
my $DLIP_PORT = "10005";
my $MIDS_PORT = "1024";
my @NOM_PROCESS ;
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/C2_DAMB";
my $REP_TEST_CONFIG1 = "$REP_TEST/Tests_DAMB_CDCD/PIM";
my $REP_TEST_CONFIG2 = "$REP_TEST/Tests_DAMB_CDCD/PEU";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if ($opt_h) { 
	print "$0 [-h] [-c 1 à 9]: init du repertoire de run  \n";
	print "c=1 répertoire test : $REP_TEST_CONFIG1\n";
	print "c=2 répertoire test : $REP_TEST_CONFIG2\n";
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
				system ("rm -f MP.Param mct_main mct_main.cfg mct_main.trt start_mct stop_mct host_test_driver mids_test_driver start osim_test_driver start_scen stop_scen wait_scen save_log *.log") if(! $debug);
				system ("ln -s ../../../../tools/SCCOA/BINAIRES/Test_Drivers/host_test_driver c2_host_test_driver")if(! $debug);
				system ("ln -s ../../../../tools/SCCOA/BINAIRES/Test_Drivers/mids_test_driver")if(! $debug);
				system ("ln -s ../../../../tools/SCCOA/Tools/start start_scen")if(! $debug);
				system ("ln -s ../../../../tools/SCCOA/Tools/stop_scen")if(! $debug);
				system ("ln -s ../../../../tools/SCCOA/Tools/wait_scen")if(! $debug);
				
				open fout , ">tempo" or die " impossibleouvrir toto";
				open fin , "<  c2_host_test_driver.conf" or die "impossible ouvrir  c2_host_test_driver.conf";
				while (<fin>) {
					my $line = $_;
					if($line =~ /Remote_Port_1/){
						print fout "Remote_Port_1                = $DLIP_PORT\n";
						next;
					}
					if($line =~ /Remote_Hostname_1/){
						print fout "Remote_Hostname_1            = $DLIP_IP_ADR\n";
						next;
					}
					print fout $line;
				}
				close fin;
				close fout;
				system("mv c2_host_test_driver.conf c2_host_test_driver.conf.old")if(! $debug);
				system("mv tempo c2_host_test_driver.conf")if(! $debug);
				system ("mv mids_test_driver.conf.old mids_test_driver.conf");
				open fout , ">tempo" or die " impossibleouvrir toto";
				open fin , "<  mids_test_driver.conf" or die "impossible ouvrir  mids_test_driver.conf";
				while (<fin>) {
					my $line = $_;
					if($line =~ /Local_Port_1/){
						print fout "Local_Port_1                = $MIDS_PORT\n";
						next;
					}
					print fout $line;
				}
				close fin;
				close fout;
				system("mv mids_test_driver.conf mids_test_driver.conf.old")if(! $debug);
				system("mv tempo mids_test_driver.conf")if(! $debug);
		}
	}
	close DIR;
}
exit 0;



