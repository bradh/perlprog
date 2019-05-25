#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hlc:v:t:");

my $VERSION_DLIP = "SAMPT_V4";

my @NOM_PROCESS ;
my $REP_TEST = "/free2/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if ($opt_h) { 
	print "sampt_test_config.pl [-h] [-c 1 à 9] [-v nom_version][-t nom_test]: init du repertoire de run  \n";
	print "c=1 répertoire test : $REP_TEST_CONFIG1/$VERSION_DLIP\n";
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

if( ! $opt_h && $opt_c && $opt_t ) {
# Definir la version du DLIP (par defaut $VERSION_DLIP)
	my $VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v"if($opt_v);
# Definir le nom du test
	my $NOM_TEST = "$opt_t";
	my $NOM_TEST_MINUS = lc $NOM_TEST;
	print "$NOM_TEST_MINUS\n";

# Definir le repertoire de test ATR et ATP
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}
	$REP_TEST_ATR = "$REP_TEST_CONFIG1/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 1);
	$REP_TEST_ATR = "$REP_TEST_CONFIG2/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 2);
	$REP_TEST_ATR = "$REP_TEST_CONFIG3/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 3);
	$REP_TEST_ATR = "$REP_TEST_CONFIG4/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 4);
	$REP_TEST_ATR = "$REP_TEST_CONFIG5/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 5);
	$REP_TEST_ATR = "$REP_TEST_CONFIG6/$VERSION/$NOM_TEST/ATR" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATR\n";

	$REP_TEST_ATP = "$REP_TEST_CONFIG1/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 1);
	$REP_TEST_ATP = "$REP_TEST_CONFIG2/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 2);
	$REP_TEST_ATP = "$REP_TEST_CONFIG3/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 3);
	$REP_TEST_ATP = "$REP_TEST_CONFIG4/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 4);
	$REP_TEST_ATP = "$REP_TEST_CONFIG5/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 5);
	$REP_TEST_ATP = "$REP_TEST_CONFIG6/$VERSION/$NOM_TEST/ATP" if ($CONFIG_TEST == 6);
	print "$REP_TEST_ATP\n";

# Configuration du rep ATR
# suppression de tous les fichiers du répertoire
	system("rm -fr $REP_TEST_ATR/*");
# lien vers les tests driver
	system("ln -s /h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver $REP_TEST_ATR/");
	system("ln -s /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver $REP_TEST_ATR/");
# lien vers les fichiers de conf des test driver dans ATP
	system("ln -s ../ATP/host_test_driver.conf $REP_TEST_ATR/"); 
	system("ln -s ../ATP/l16_test_driver.conf $REP_TEST_ATR/"); 
	system("ln -s ../ATP/ti_test_driver_c2.conf $REP_TEST_ATR/")if ($opt_l);
# lien vers les fichiers d'entrée
	system("ln -s ../ATP/$NOM_TEST_MINUS.xhd $REP_TEST_ATR/");
	system("ln -s ../ATP/$NOM_TEST_MINUS.fom $REP_TEST_ATR/");
	system("ln -s ../ATP/$NOM_TEST_MINUS.ji $REP_TEST_ATR/");
	system("ln -s ../ATP/ti_test_driver_c2.dem_apu $REP_TEST_ATR/")if ($opt_l);

# création du fichier host_test_driver.conf

my $InputFile = "host_test_driver.conf";
open Fout, ">$REP_TEST_ATP/$InputFile" or die "impossible ouvrir $REP_TEST_ATP/$InputFile\n";
print Fout "Host_Header_Revision      = V1\n";
print Fout "use_channel_4             = true\n";
print Fout "Session_ID                = 0\n";
print Fout "Connection_Number         = 1\n";
print Fout "socket_type_1             = TCP_CLIENT\n";
print Fout "Host_Name_1               = NC23_Host\n";
print Fout "Host_Logical_ID_1         = 100\n";
print Fout "Host_Connection_Type_1    = TCP_CLIENT\n";
print Fout "Local_Port_1              = 18200\n";
print Fout "Input_File_1              = $NOM_TEST_MINUS.xhd\n";
print Fout "Output_File_1             = $NOM_TEST_MINUS.xdh\n";
print Fout "Network_Broadcast_Address = 200.1.18.255\n";
print Fout "Channel4_Hosts_Port       = 14000\n";
print Fout "Channel4_DLIP_Port        = 15000\n";
print Fout "Host_Address              = 200.1.18.1\n";
print Fout "Write_TX_And_RX           = On\n";
print Fout "SysTN_Alloc               = OFF\n";
print Fout "First_SysTN               = 10\n";
print Fout "First_LTN                 = 512\n";
print Fout "RC_Simulation             = ON\n";
print Fout "Host_XML_Dictionnary      = /dlip_ref/s_dlip/Tools/Aladdin_V2/v7r0e2_With_Check/Dictionaries/Host/d_sampt_c2_block_v105.xml\n";
close Fout;

# Création du fichier de conf du l16_test_driver

my $InputFile = "l16_test_driver.conf";
open Fout, ">$REP_TEST_ATP/$InputFile" or die "impossible ouvrir $REP_TEST_ATP/$InputFile\n";

print Fout "Broadcast_Address      = 200.1.18.255\n";
print Fout "Connection_Number     = 1\n";
print Fout "Socket_Protocol_1     = MIDS\n"; 
print Fout "Socket_Type_1         = TCP_SERVER\n";
print Fout "Local_Port_1          = 1024 \n";
print Fout "Input_File_1          = $NOM_TEST_MINUS.fom\n";
print Fout "Output_File_1         = $NOM_TEST_MINUS.fim\n";
print Fout "J_Output_File_1       = $NOM_TEST_MINUS.jo\n";
print Fout "J_Input_File_1        = $NOM_TEST_MINUS.ji\n";
print Fout "Scenario_Duration     = 7200.0\n";
print Fout "Write_Tx_ANd_Rx       = On\n";
print Fout "Current_Init_State    = Load_Complete_Valid_Data\n"; 
print Fout "Net_Entry_Status      = Fine_Synchronization_Achieved\n";

close Fout;

# Création du fichier de conf du .ji vide

my $InputFile = "$NOM_TEST_MINUS.ji";

open Fout, ">$REP_TEST_ATP/$InputFile" or die "impossible ouvrir $REP_TEST_ATP/$InputFile\n";
close Fout;
	
}
exit 0;
