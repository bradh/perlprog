#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hr:");
# my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
my $LOCAL_DIR_EXE_LYNX = "/h7_usr/sil2_usr/samptivq/EXECUTABLES_LYNX";


my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";
my $DLIP_HOTE3 = "200.1.18.3";
my $DLIP_NAME1 = "rackP0";
my $DLIP_NAME2 = "rackP1";
my $DLIP_NAME3 = "rackDev";

my $DLIP_NAME;


if ($opt_h ) { 
	print "sampt_update_exe.pl [-h] [-r n°rack] \n";
	print " recopie les nouveaux exe dans le rep /rd1/EXE\n";
	exit 0;
}
# Si toutes les options sont definies (sauf t optionnelle
if( ! $opt_h && $opt_r) {

# Définir le rack
	$RACK_NB = $opt_r;

	$DLIP_NAME = $DLIP_NAME1;
	$DLIP_NAME = $DLIP_NAME2 if($opt_r == 2);
	$DLIP_NAME = $DLIP_NAME3 if($opt_r == 3);

	#system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.4_lynx0S-4.0_build_number_33/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
        #system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.5_lynx0S-4.0_build_numnober_85/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
        #system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.5_lynx0S-4.0_build_number_88/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp-v3.0.1-build14/slp root\@$DLIP_NAME:/rd1/EXE/slp");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp_v3.0-build8/slp root\@$DLIP_NAME:/rd1/EXE/slp");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp_v3.01-build18/slp root\@$DLIP_NAME:/rd1/EXE/slp");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp-v3.0.1-build18-O1-patch_string_equal root\@$DLIP_NAME:/rd1/EXE/slp");
	#system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp_v3.01-build18/slp root\@$DLIP_NAME:/rd1/EXE/slp");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/GAR_V1R0/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
	#system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V10R3/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V11R4E2_PERF/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V11R2E4fred/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V11R2E4/sampt_c2_oa_lynx_main root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
        system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_NC2/V11R2E4/sampt_non_c2_oa_lynx_main root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V11R2E2_PERF/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
        #system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_NC2/V10R3/sampt_main_NC2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2");
	#system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_NC2/V9R20/sampt_main root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2");

	#system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V10R1/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
	#system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_C2/V10R3E2/sampt_main_C2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_C2");
	#system("rcp $LOCAL_DIR_EXE_LYNX/DLIP_NC2/V10R1/sampt_main_NC2 root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2");
	#system("rcp  $LOCAL_DIR_EXE_LYNX/DLIP_NC2/V10R0E8_beta/sampt_non_c2_oa_lynx_main_2009_01_20_10h01m00s root\@$DLIP_NAME:/rd1/EXE/sampt_main_NC2");
} 
exit 0;


