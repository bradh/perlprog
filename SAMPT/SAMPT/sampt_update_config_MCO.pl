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
my $MIDS_Port = "1025";
my $TI_Port = "10200";


my $TEST_NAME_INPUT = "";
$TEST_NAME_INPUT = $opt_t if( defined $opt_t);

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
	$REP_TEST_ATR= "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_TEST_ATR = "$REP_TEST_CONFIG2/$VERSION" if ($CONFIG_TEST == 2);
	$REP_TEST_ATR = "$REP_TEST_CONFIG3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_TEST_ATR = "$REP_TEST_CONFIG4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_TEST_ATR = "$REP_TEST_CONFIG5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_TEST_ATR = "$REP_TEST_CONFIG6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATR\n";

	chdir ("$REP_TEST_ATR");
	
	# Boucle pour lire l'ensemle des tests
	opendir Dir, "$REP_TEST_ATR" or die "impossible ouvrir $REP_TEST_ATR !";
	my (@DIR) = readdir Dir;
	foreach my $TEST_NAME (@DIR) {
		print "$TEST_NAME  $TEST_NAME_INPUT \n";
		my $test_name = lc $TEST_NAME;
		if ( $TEST_NAME eq "$TEST_NAME_INPUT"  || $TEST_NAME_INPUT eq "") {
		#if ( defined $opt_t && $TEST_NAME eq /$TEST_NAME_INPUT/);
			if ( ! (defined $opt_l) && -d "$REP_TEST_ATR/$TEST_NAME" && $TEST_NAME !~ /^\./  && $TEST_NAME !~ /_PEU/ ){
				my $current_dir;
				print "processing $TEST_NAME ...\n";
				chdir("$REP_TEST_ATR/$TEST_NAME") if (-d "$REP_TEST_ATR/$TEST_NAME");
				# si le repertoire ATR exist on le nettoye on le recopie dans le rep racine on le supprime
				if( -d "$REP_TEST_ATR/$TEST_NAME/ATR") {
					chdir("$REP_TEST_ATR/$TEST_NAME/ATR");
					$current_dir = `pwd`;
					print " Current dir : $current_dir\n \n";
					system("sampt_clean_dir.sh");
					chdir("..");
					$current_dir = `pwd`;
					print " Current dir : $current_dir\n";
					system("cp -rf ATR/* .");
					system("rm -fr ATR");
				}
				if( ! -d "$REP_TEST_ATR/$TEST_NAME/ATR" && -d "$REP_TEST_ATR/$TEST_NAME/ATP") {
					$current_dir = `pwd`;
					print "$current_dir rm ATP\n";
					system("rm -fr ATP");
				}
				if( ! -d "$REP_TEST_ATR/$TEST_NAME/ATR" && ! -d "$REP_TEST_ATR/$TEST_NAME/ATP") {
					# suppression des test driver
					system("rm -fr host_test_driver ");
					system("rm -fr l16_test_driver ");
					system("rm -fr ti_test_driver ");
					# lien vers les tests driver
					system("ln -sf /h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver ");
					system("ln -sf /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver ");
					system("ln -sf /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver ti_test_driver");
					
					# modification des nom des fichiers de test
					system("sampt_change_test_name.pl $test_name $TEST_NAME");
					
					
					if( defined $opt_n ){
						# création du fichier host_test_driver.conf
						my $InputFile = "host_test_driver.conf";
						open Fout, ">$REP_TEST_ATR/$TEST_NAME/$InputFile" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/$InputFile\n";
						print Fout "Host_Header_Revision      = V1\n";
						print Fout "use_channel_4             = true\n";
						print Fout "Session_ID                = 0\n";
						print Fout "Connection_Number         = 1\n";
						print Fout "socket_type_1             = TCP_CLIENT\n";
						print Fout "Host_Name_1               = NC23_Host\n";
						print Fout "Host_Logical_ID_1         = 100\n";
						print Fout "Host_Connection_Type_1    = TCP_CLIENT\n";
						print Fout "Local_Port_1              = 18200\n";
						print Fout "Input_File_1              = $TEST_NAME.xhd\n";
						print Fout "Output_File_1             = $TEST_NAME.xdh\n";
						print Fout "Network_Broadcast_Address = $Network_Broadcast_Address\n";
						print Fout "Channel4_Hosts_Port       = $Channel4_Hosts_Port\n";
						print Fout "Channel4_DLIP_Port        = $Channel4_DLIP_Port\n";
						print Fout "Host_Address              = $TD_Host_Address\n";
						print Fout "Write_TX_And_RX           = On\n";
						print Fout "SysTN_Alloc               = OFF\n";
						print Fout "First_SysTN               = 10\n";
						print Fout "First_LTN                 = 512\n";
						print Fout "RC_Simulation             = ON\n";
						print Fout "Host_XML_Dictionnary      = /dlip_ref/s_dlip/Tools/Aladdin_V2/v7r0e2_With_Check/Dictionaries/Host/d_sampt_c2_block_v105.xml\n";
						close Fout;
						
						# traitement l16_test_driver.conf
						open Fout, ">$REP_TEST_ATR/$TEST_NAME/l16_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/l16_test_driver.conf\n";
						print Fout "Broadcast_Address     = $Network_Broadcast_Address\n";
						print Fout "Connection_Number     = 1\n";
						print Fout "Socket_Protocol_1     = MIDS\n"; 
						print Fout "Socket_Type_1         = TCP_SERVER\n";
						print Fout "Local_Port_1          = $MIDS_Port \n";
						print Fout "Input_File_1          = $TEST_NAME.fom\n";
						print Fout "Output_File_1         = $TEST_NAME.fim\n";
						print Fout "J_Output_File_1       = $TEST_NAME.jo\n";
						Print Fout "J_Input_File_1        = $TEST_NAME.ji\n";
						print Fout "Scenario_Duration     = 7200.0\n";
						print Fout "Write_Tx_ANd_Rx       = On\n";
						print Fout "Current_Init_State    = Load_Complete_Valid_Data\n"; 
						print Fout "Net_Entry_Status      = Fine_Synchronization_Achieved\n";
						close Fout;

						# traitement ti_test_driver
						open Fout, ">$REP_TEST_ATR/$TEST_NAME/ti_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/ti_test_driver.conf\n";
						print Fout "Broadcast_Address     = $Network_Broadcast_Address\n";
						print Fout "Connection_Number     = 1\n";
						print Fout "Socket_Protocol_1     = SLP\n";
						print Fout "Socket_Type_1         = TCP_CLIENT\n";
						print Fout "Remote_Hostname_1     = $DLIP_Address\n";
						print Fout "Remote_Port_1         = $TI_Port\n";
						print Fout "Input_File_1          = ti_test_driver.dem_apu\n";
						print Fout "Output_File_1         = ti_test_driver.rep_ind_apu\n";
						print Fout "J_Output_File_1       = ti_test_driver.jo\n";
						#J_Intput_File_1       = ti_test_driver.ji
						print Fout "Scenario_Duration     = 500.0\n";
						print Fout "Write_Tx_ANd_Rx       = On\n";
						close Fout;
					}
					if( $opt_u ) {
						# mis à jour des @IP + n° de port
						# traitement host_test_driver.conf
						open Fin, "<$REP_TEST_ATR/$TEST_NAME/host_test_driver.conf" or die "impossible ouvrir $REP_TEST_ATR/$TEST_NAME/host_test_driver.conf\n";
						open Fout, ">$REP_TEST_ATR/$TEST_NAME/temp.conf" or die "Impossible ouvrir $REP_TEST_ATR/$TEST_NAME/temp.conf ! \n";
						while(<Fin>){
							my $line = $_;
							chomp $line;
							$line = "Network_Broadcast_Address = $Network_Broadcast_Address" if( $line =~ /Network_Broadcast_Address/);
							$line = "Channel4_Hosts_Port       = $Channel4_Hosts_Port" if( $line =~ /Channel4_Hosts_Port/);
							$line = "Channel4_DLIP_Port        = $Channel4_DLIP_Port" if( $line =~ /Channel4_DLIP_Port/);
							$line = "Host_Address              = $TD_Host_Address" if( $line =~ /Host_Address/);
							$line = "Input_File_1              = $TEST_NAME.xhd" if( $line =~ /Input_File_1/);
							$line = "Output_File_1             = $TEST_NAME.xdh" if( $line =~ /Output_File_1/);
							print Fout "$line\n";more 
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
							$line = "Input_File_1              = $TEST_NAME.fom" if( $line =~ /^\s*Input_File_1/);
							$line = "Output_File_1             = $TEST_NAME.fim" if( $line =~ /^\s*Output_File_1/);
							$line = "J_Output_File_1           = $TEST_NAME.jo" if( $line =~ /J_Output_File_1/);
							$line = "J_Input_File_1            = $TEST_NAME.ji" if( $line =~ /J_Input_File_1/);
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
					}
					system("touch $REP_TEST_ATR/$TEST_NAME/$TEST_NAME.ji") if( ! -f "$REP_TEST_ATR/$TEST_NAME/$TEST_NAME.ji");
					system("touch $REP_TEST_ATR/$TEST_NAME/$TEST_NAME.fom") if( ! -f "$REP_TEST_ATR/$TEST_NAME/$TEST_NAME.fom");
					system("ln -s ti_test_driver_c2.dem ti_test_driver.dem_apu") if($CONFIG_TEST < 4);
					system("ln -s ti_test_driver_nonc2.dem ti_test_driver.dem_apu") if($CONFIG_TEST > 3);
				}
				chdir ("..");	
			}
		}
	}
	close Dir;
}

exit 0;






