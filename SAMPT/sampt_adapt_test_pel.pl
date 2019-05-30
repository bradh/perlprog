#!/usr/bin/perl -w
# Lance la non reg sampt
#  se base sur la liste des tests dans le fichier /free2/samptivq/tests/NON_C2/reference_ATP/fichiers_communs/sampt_non_reg_test_list.txt

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hlnuc:v:t:");


my $VERSION = "SAMPT_MCO";

my $Network_Broadcast_Address = "200.1.18.2";
my $Channel4_Hosts_Port = "14000";
my $Channel4_DLIP_Port = "15000";
my $TD_Host_Address = "200.1.18.50";
my $DLIP_Address = "200.1.18.2";
my $MIDS_Port = "1024";
my $TI_Port = "10200";


my $TEST_NAME = "";
$TEST_NAME = $opt_t if( defined $opt_t);

my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if($opt_h){
  $opt_h = 0;
  print "$$\n";
  print " $0 -c <config test> -v <DLIP version>   \n";
  print "Lance la mise a jour des repertoires de test\n"; 
  print "-l liste les tests\n";
  print "-u met a jour les fichiers de conf des TD\n";
  print "-t <nom du test> traite 1 seul test\n";
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
	$REP_TEST_ATR = "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_TEST_ATR = "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 2);
	$REP_TEST_ATR = "$REP_TEST_CONFIG3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_TEST_ATR = "$REP_TEST_CONFIG4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_TEST_ATR = "$REP_TEST_CONFIG5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_TEST_ATR = "$REP_TEST_CONFIG6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATR\n";

	chdir ("$REP_TEST_ATR/$TEST_NAME")or die "Impossible chdir $REP_TEST_ATR \n";
	
	print "$TEST_NAME \n";
	my $current_dir;
	# changement des droits sur les fichiers
	system("chmod 664 \*");
	# suppression des test driver
	system("rm -fr host_test_driver ");
	system("rm -fr l16_test_driver ");
	system("rm -fr ti_test_driver ");
	# lien vers les tests driver
	system("ln -sf /h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver ");
	system("ln -sf /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver ");
	system("ln -sf /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver ti_test_driver");
	# chngement des droits d execution
	system("chmod +x host_test_driver l16_test_driver ti_test_driver");
					
					# modification des nom des fichiers de test
					#system("sampt_change_test_name.pl $TEST_NAME $test_name");
					
					
	# mis a jour des @IP + n° de port
	# traitement host_test_driver.conf
	open Fin, "<$REP_TEST_ATR/$TEST_NAME/host_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/host_test_driver.conf\n";
	open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
	while(<Fin>){
		my $line = $_;
		chomp $line;
		$line = "Network_Broadcast_Address = $Network_Broadcast_Address" if( $line =~ /Network_Broadcast_Address/);
		#$line = "Channel4_Hosts_Port       = $Channel4_Hosts_Port" if( $line =~ /Channel4_Hosts_Port/);
		#$line = "Channel4_DLIP_Port        = $Channel4_DLIP_Port" if( $line =~ /Channel4_DLIP_Port/);
		$line = "Host_Address              = $TD_Host_Address" if( $line =~ /Host_Address/);
		#$line = "Input_File_1              = $test_name.xhd" if( $line =~ /Input_File_1/);
		#$line = "Output_File_1             = $test_name.xdh" if( $line =~ /Output_File_1/);
		print Fout "$line\n"; 
	}
	close Fin;
	close Fout;
	system("mv $REP_TEST_ATR/$TEST_NAME/temp.conf $REP_TEST_ATR/$TEST_NAME/host_test_driver.conf");
						
	# traitement l16_test_driver.conf
	open Fin, "<$REP_TEST_ATR/$TEST_NAME/l16_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/l16_test_driver.conf\n";
	open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
	while(<Fin>){
		my $line = $_;
		chomp $line;
		$line = "Broadcast_Address         = $Network_Broadcast_Address" if( $line =~ /Broadcast_Address/);
		$line = "Local_Port_1              = $MIDS_Port" if( $line =~ /Local_Port_1/);
		#$line = "Input_File_1              = $test_name.fom" if( $line =~ /^\s*Input_File_1/);
		#$line = "Output_File_1             = $test_name.fim" if( $line =~ /^\s*Output_File_1/);
		#$line = "J_Output_File_1           = $test_name.jo" if( $line =~ /J_Output_File_1/);
		#$line = "J_Input_File_1            = $test_name.ji" if( $line =~ /J_Input_File_1/);
		print Fout "$line\n";
	}
	close Fin;
	close Fout;
	system("mv $REP_TEST_ATR/$TEST_NAME/temp.conf $REP_TEST_ATR/$TEST_NAME/l16_test_driver.conf");
					
	# traitement ti_test_driver.conf
	open Fin, "<$REP_TEST_ATR/$TEST_NAME/ti_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/ti_test_driver.conf\n";
	open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
	while(<Fin>){
		my $line = $_;
		chomp $line;
		$line = "Broadcast_Address     = $Network_Broadcast_Address" if( $line =~ /Broadcast_Address/);
		$line = "Remote_Hostname_1     = $DLIP_Address" if( $line =~ /Remote_Hostname_1/);
		$line = "Remote_Port_1         = $TI_Port"  if( $line =~ /Remote_Port_1/);
		print Fout "$line\n";
	}
	close Fin;
	close Fout;
	system("mv $REP_TEST_ATR/$TEST_NAME/temp.conf $REP_TEST_ATR/$TEST_NAME/ti_test_driver.conf");
	# traitement sampt_main.cfg
	open Fin, "<$REP_TEST_ATR/$TEST_NAME/sampt_main.cfg" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/sampt_main.cfg\n";
        open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
        while(<Fin>){
                my $line = $_;
                chomp $line;
                $line = "Network_Broadcast_Address     = $TD_Host_Address" if( $line =~ /Network_Broadcast_Address/);
                $line = "DLIP_Address     = $DLIP_Address" if( $line =~ /DLIP_Address/);
                $line = "SLP_Initialization_Path         = ./"  if( $line =~ /SLP_Initialization_Path/);
                print Fout "$line\n";
        }
        close Fin;
        close Fout;
        system("mv $REP_TEST_ATR/$TEST_NAME/temp.conf $REP_TEST_ATR/$TEST_NAME/sampt_main.cfg");
	# traitement du script run.sh
	system("touch $REP_TEST_ATR/$TEST_NAME/run.sh") if ( -e "$REP_TEST_ATR/$TEST_NAME/run.sh");
	open Fin, "<$REP_TEST_ATR/$TEST_NAME/run.sh" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/run.sh\n";
        open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
	print Fout "sampt_init_local.pl -r 1 -c $CONFIG_TEST -t $TEST_NAME\n";
	my $compas = 0;
	my $retrieve = 0;
	my $init = 0;
        while(<Fin>){
                my $line = $_;
                chomp $line;
                $line =~ s/.*\/sampt_launcher\s(\d+)\s+normal/sampt_start_test_MCO.pl -r 1 -c $CONFIG_TEST -t $TEST_NAME -i -l -s $1 -x/;
		$compas = 1 if ($line =~ /compas/);
		$retrieve = 1 if ($line =~ /sampt_retrieve_log_MCO.pl/);
		$init = 1 if( $line =~ /sampt_init_local.pl/);
                print Fout "$line\n" if( ! $init );
		#print "$line init = $init\n";
		$init = 0;
        }
	print Fout "sampt_retrieve_log_MCO.pl -r 1 -c $CONFIG_TEST -t $TEST_NAME\n" if( ! $retrieve);
	print Fout "compas \n" if(! $compas);
        close Fin;
        close Fout;
        system("mv $REP_TEST_ATR/$TEST_NAME/temp.conf $REP_TEST_ATR/$TEST_NAME/run.sh");
	system("chmod +x  $REP_TEST_ATR/$TEST_NAME/run.sh");
}
exit 0;
