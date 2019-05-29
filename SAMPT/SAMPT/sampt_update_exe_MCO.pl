#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hr:");
# my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
#my $LOCAL_DIR_EXE_LYNX = "/h7_usr/sil2_usr/samptivq/EXECUTABLES_LYNX";
my $LOCAL_DIR_EXE_LYNX = "/h7_usr/dlip_ref/dlip_doc/Affaire/SAMPT/Livraisons";

my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";
my $DLIP_HOTE3 = "200.1.18.3";
my $DLIP_NAME1 = "rackP0";
my $DLIP_NAME2 = "rackP1";
my $DLIP_NAME3 = "rackDev";

my $DLIP_NAME;


if ($opt_h ) { 
	print "sampt_update_exe.pl [-h] [-r n°rack] [-v] [-c]\n";
	print " recopie les nouveaux exe dans le rep /rd1/EXE\n";
	exit 0;
}
# Si toutes les options sont definies (sauf t optionnelle
if( ! $opt_h && $opt_r && $opt_c && $opt_v) {

# Définir le rack
	$RACK_NB = $opt_r;

	$DLIP_NAME = $DLIP_NAME1;
	$DLIP_NAME = $DLIP_NAME2 if($opt_r == 2);
	$DLIP_NAME = $DLIP_NAME3 if($opt_r == 3);
	
	my $DLIP_VERSION = $opt_v;
	my $DLIP_CONFIG = $opt_c;

	#system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.4_lynx0S-4.0_build_number_33/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
    #system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.5_lynx0S-4.0_build_numnober_85/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp_v3.01-build18/slp root\@$DLIP_NAME:/rd1/EXE/slp");
    system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_NC2/$DLIP_VERSION/NonC2/Binaires/Lynx/sampt_non_c2_oa_lynx_main  root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2") if ($DLIP_CONFIG > 3);
    system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/$DLIP_VERSION/C2/Binaires/Lynx/sampt_c2_oa_lynx_main root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2")if ($DLIP_CONFIG < 4 );
} 
exit 0;


