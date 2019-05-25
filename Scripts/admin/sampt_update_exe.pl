#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("h");
# my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
my $LOCAL_DIR_EXE_LYNX = "/h7_usr/sil2_usr/samptivq/EXECUTABLES_LYNX";

my $DLIP_NAME = "rackP0";

if ($opt_h ) { 
	print "sampt_update_exe.pl [-h] [-r n°rack] \n";
	print " recopie les nouveaux exe dans le rep /rd1/EXE\n";
	exit 0;
}
# Si toutes les options sont definies (sauf t optionnelle
if( ! $opt_h ) {
	#system("rcp $LOCAL_DIR_EXE_LYNX/RECORDER/recorder-v0.4_lynx0S-4.0_build_number_34/recorder root\@$DLIP_NAME:/rd1/EXE/recorder");
	system("rcp $LOCAL_DIR_EXE_LYNX/SLP/slp_v3.0-build8/slp root\@$DLIP_NAME:/rd1/EXE/slp");
} 
exit 0;


