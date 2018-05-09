#!/usr/bin/perl -w
# Lancement demo marine de façon graphique
#
#  par S. Mouchot

use Getopt::Std;
use strict;
use Tk;
use Tk::Photo;
use Tk::Dialog;

#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $putty_session = "JRE-Gateway";

my $LOG_DIR = "E:\\LOG";
# ordre d'affichage des boutons
my $C3M_LABEL_NUM = 1;
my $AIS_NUM = 2;
my $OSIM_NUM = 4;
my $DLIP_C3M_NUM = 3;
my $TMCT_NUM = 5;
my $SPY_LABEL_NUM = 6;
my $SPY_NUM = 7;
my $DATASERVER_NUM = 8;
my $DLVM_NUM = 9;

my $JRE_LABEL_NUM = 10;
my $TDL_ROUTER_NUM = 11;
my $JREP_NUM = 12;
my $DLIPMng_NUM = 13;
my $JREM_NUM = 14;
my $DLIPCOM_NUM= 15;
my $L16_NUM = 16;
my $HOST_NUM = 17;
my $SPY_JRE_NUM = 18;

my $CMD_LABEL_NUM = 19;
my $CMD_START_NUM = 20;
my $CMD_STATUS_NUM = 21;
my $CMD_LOG_NUM = 22;
my $CMD_EXIT_NUM = 23;

my $L16_EXE = "./l16_test_driver";
my $L16_RUN_DIR = "/export/home/thales/L16_TD";
my $L16_START = "cd $L16_RUN_DIR; ./start_L16 >& /dev/null &";
my $L16_STOP = "cd $L16_RUN_DIR; ./stop_L16 >& /dev/null &";
my @L16_LOG = ("l16_driver_test.log");
my $L16_LOG_DIR = "$L16_RUN_DIR";
my $CLEAR_L16_LOG = "cd $L16_RUN_DIR; rm -fr *.log";

my $HOST_EXE = "./host_test_driver";
my $HOST_RUN_DIR = "/export/home/thales/Scripts";
my $HOST_START = "cd $HOST_RUN_DIR; ./start_HOST_TD >& /dev/null &";
my $HOST_STOP = "cd $HOST_RUN_DIR; ./stop_HOST_TD >& /dev/null &";
my @HOST_LOG = ("host_driver_test.log");
my $HOST_LOG_DIR = "$HOST_RUN_DIR";
my $CLEAR_HOST_LOG = "cd $HOST_RUN_DIR; rm -fr *.log";


my $VANILLA_EXE = "./dlip";
my $VANILLA_RUN_DIR = "/export/home/thales/VANILLA";
my $VANILLA_START = "cd $VANILLA_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./dlip.sh >& /dev/null &";
my $VANILLA_STOP = "cd $VANILLA_RUN_DIR; ./stop_VANILLA.sh >& /dev/null &";
my $VANILLA_CMD = "cd $VANILLA_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./$VANILLA_EXE >& /dev/null &";
my $VANILLA_LOG = "dlip.log";
my $VANILLA_LOG_DIR ="/export/home/thales/VANILLA";
my $CLEAR_VANILLA_LOG = "cd $VANILLA_RUN_DIR; ./clear_DLIP_log";

my $TDL_ROUTER_EXE = "./tdl_router_main";
my $TDL_ROUTER_RUN_DIR = "/export/home/thales/Scripts";
my $TDL_ROUTER_START = "cd $TDL_ROUTER_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./start_TDL_ROUTER >& /dev/null &";
my $TDL_ROUTER_STOP = "cd $TDL_ROUTER_RUN_DIR; ./stop_TDL_ROUTER >& /dev/null &";
my $TDL_ROUTER_CMD = "cd $TDL_ROUTER_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./$TDL_ROUTER_EXE >& /dev/null &";
my $TDL_ROUTER_LOG = "tdl_router_main.log";
my $TDL_ROUTER_LOG_DIR ="/export/home/thales/TDL_ROUTER";
my $CLEAR_TDL_ROUTER_LOG = "cd $TDL_ROUTER_RUN_DIR; ./clear_TDL_ROUTER_log";

my $JREP_EXE = "jre_main";
my $JREP_RUN_DIR = "/export/home/thales/Scripts";
my $JREP_START = "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./start_JREP >& /dev/null &";
my $JREP_STOP = "cd $JREP_RUN_DIR; ./stop_JREP >& /dev/null &";
my $JREP_CMD = "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./$JREP_EXE >& /dev/null &";
my @JREP_LOG = ("jre.log", "jre-1.log");
my $JREP_LOG_DIR = "/export/home/thales/JREP/trace";
my $CLEAR_JREP_LOG = "cd $JREP_RUN_DIR; ./clear_JREP_log";

my $DLIPMng_EXE = "launcher.bat";
my $DLIPMng_WIN_NAME = "DLIP L16 Mng";
my $DLIPMng_RUN_DIR = "E:\\THALES\\DLIPmng_V1R1E5_CWIX_2012\\DLIPL16Mng-Delivery\\";

my $JREM_EXE = "launch.bat";
my $JREM_WIN_NAME = "JRE Management";
my $JREM_RUN_DIR = "E:\\THALES\\JREM_V14R3_CWIX_2012\\bin";

my $DLIPCOM_EXE = "DLIPCOM.bat";
my $DLIPCOM_RUN_DIR="C:\\Program Files\\DLIPCOMMng\\DLIPCOMMNG\\";
my $DLIPCOM_WIN_NAME = "DLIPCOM.bat";

my $SPY_EXE = "launch_spylinks.js";
my $SPY_WIN_NAME = "DLEM";
my $SPY_RUN_DIR = "C:\\Program Files\\TCF\\SpyLinks";
my $SPY_LOG_DIR = "C:\\Program Files\\TCF\\Spylinks\\DLEM\\Software\Logs";

my $DATASERVER_EXE = "";
my $DATASERVER_WIN_NAME = "DataServer";
my $DATASERVER_RUN_DIR = "";

my $DLVM_EXE = "launch_dlvm.js";
my $DLVM_WIN_NAME = "DLVM";
my $DLVM_RUN_DIR = "E:\\THALES\\SpyLinks";

my $SPY_JRE_EXE = "Spy-Links.exe";
my $SPY_JRE_WIN_NAME = "";
my $SPY_JRE_RUN_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\";
my $SPY_JRE_LOG_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\Logs";

my $AIS_EXE = "AIS.exe";
my $AIS_WIN_NAME = "AIS.exe";
my $AIS_RUN_DIR = "C:\\Program Files\\NCL16\\AIS\\";
my $AIS_LOG_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\Logs";

my $NPG_EXE = "npg.bat";
my $NPG_WIN_NAME = "npg.exe";
my $NPG_RUN_DIR = "C:\\Program Files\\Npg\\bin\\";
my $NPG_LOG_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\Logs";

my $DLIP_C3M_EXE = "mct_main";
my $DLIP_C3M_START = "rsh 24.1.1.4 -l dlip cd Ops;start";
my $DLIP_C3M_STOP= "rsh 24.1.1.4 -l dlip cd Ops;stop";
my $DLIP_C3M_RUN_DIR = "/home1/dlip/Ops";
my $DLIP_C3M_LOG_DIR = "/home1/dlip/Ops";

my $OSIM_EXE = "E:\\THALES\\OSIM\\OSIM.EXE";
my $OSIM_RUN_DIR = "E:\\THALES\\OSIM";
my $OSIM_WIN_NAME = "OSIM";
my $MAPPOINT_EXE = "MapPoint.exe";

my $TMCT_EXE = "tmct_monolithique_ss.exe";
my $TMCT_RUN_DIR = "E:\\THALES\\TMCT\\bin\\";
my $TMCT_WIN_NAME = "tmct_mono";

my $DLTE_C3M_EXE = "launch_DLTE_C3M.bat";
my $DLTE_C3M_RUN_DIR = "E:\\THALES\\DLTE_S16";
my $DLTE_C3M_WIN_NAME = "DLTE C3M";

my $DLTE_ALTBMD_EXE = "launch_DLTE_ALTBMD.bat";
my $DLTE_ALTBMD_RUN_DIR = "E:\\THALES\\DLTE_S16";
my $DLTE_ALTBMD_WIN_NAME = "DLTE ALTBMD";

my $DLTE_SIMU_EXE = "launch_SimuL16.bat";
my $DLTE_SIMU_RUN_DIR = "C:\\Program Files\\TCF\\SimuL16\\DLTE_S16";
my $DLTE_SIMU_WIN_NAME = "DLTE SIMU";
my $DLTE_IHM_WIN_NAME = "DLTE IHM";

my	@startButton;
my	@stopButton;	

my $i;

my$mw;

# print $ENV{PWD};
if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}

if(! $opt_h) {
	my @Hframe;
	my @photo;
	my $widthLabel = 15;
	$mw = MainWindow->new(-background => 'grey');
	$mw->title( "THALES : CWIX 2012 Starter " );
	
	
	my $startPhoto= $mw->Photo("startPhoto", -file => "Images/Start_actif.gif");
	my $stopPhoto= $mw->Photo("stopPhoto", -file => "Images/Stop_actif.gif");
	my $startInactivePhoto= $mw->Photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	my $stopInactivePhoto= $mw->Photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	my $blankPhoto = $mw->Photo("blankPhoto", -file => "Images/Blank.gif");
	
	my $string = " CWIX 12 Starter         ";
	
	#waiting for SUN synchronization
	my $SUN_SYNCHRO_STATE = 0;
	my $LYNX_SYNCHRO_STATE = 0;
	
	while(! $SUN_SYNCHRO_STATE){
		my $NTP_CMD = `plink $putty_session \"ntpq -p\"`;
		print "wait for SUN synchro...";
		$SUN_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*/);
		sleep 1;
	}
	print "SUN Synchro ok !\n";
	while(! $LYNX_SYNCHRO_STATE){
		my $NTP_CMD = `rsh 24.1.1.4 -l dlip \"ntpq -p\"`;
		print "$NTP_CMD \n wait for Lynx synchro...";
		$LYNX_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*/);
		sleep 1;
	}
	print "Lynx Synchro ok !\n";
		
	for $i (0 .. (length($string)-1)){
		my $character = substr($string, $i, 1);
		print "$character\n";
		 if($character =~ /\s/){
		 	$character = "Blank";
		 }
		 else {
		 	$character = uc $character;
		 }
		$Hframe[$i] = $mw->Frame(-background => 'grey')->pack(-side => 'top');
		$photo[$i] = $Hframe[$i]->Photo( "image$i", -file => "Images/$character.gif");
		$Hframe[$i]->Label( -image => $photo[$i], -width => $widthLabel+15, -height => 30, -background => 'grey')->pack(-side => 'left');

		if ($i == 0){
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "Stop", -width => 5, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "Start", -width => 5,  -background => 'grey')->pack(-side => 'left');
			
		}
		elsif ($i == $JRE_LABEL_NUM) {
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "--- JREP ---", -width => 10, -background => 'grey')->pack(-side => 'left');

		}
		elsif ($i == $C3M_LABEL_NUM) {
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "--- C3M ---", -width => 10, -background => 'grey')->pack(-side => 'left');

		}
		elsif ($i == $SPY_LABEL_NUM) {
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "--- SPYLINKS ---", -width => 12, -background => 'grey')->pack(-side => 'left');

		}
		elsif ($i == $CMD_LABEL_NUM) {
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey')->pack(-side => 'left');
			$Hframe[$i]->Label(-text => "--- Commands ---", -width => 16, -background => 'grey')->pack(-side => 'left');

		}
		elsif ($i == $L16_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isSolarisProcessRunning($L16_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}	
			$Hframe[$i]->Label(-text  => "L16 TD :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopL16,
								-image => $initialStopPhoto , -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startL16,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $HOST_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isSolarisProcessRunning($HOST_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}	
			$Hframe[$i]->Label(-text  => "HOST TD :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopHOST,
								-image => $initialStopPhoto , -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startHOST,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $TDL_ROUTER_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isSolarisProcessRunning($TDL_ROUTER_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}			
			$Hframe[$i]->Label(-text  => "TDL_ROUTER :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopTDL_ROUTER,
							-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startTDL_ROUTER,
							-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left'); 
		}

		elsif ($i == $JREP_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isSolarisProcessRunning($JREP_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}	
			$Hframe[$i]->Label(-text  => "JREP :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopJREP,
								-image => $initialStopPhoto , -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startJREP,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $DLIPMng_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLIPMng_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}	
			$Hframe[$i]->Label(-text  => "DLIP Mng :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLIPMng,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLIPMng,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $JREM_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($JREM_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "JREP Mng :",  -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopJREM,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startJREM,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $DLIPCOM_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLIPCOM_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "DLIPCOM Mng :",  -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLIPCOM,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLIPCOM,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $SPY_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($SPY_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "SpyLinks :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopSpyLinks,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startSpyLinks,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $DLVM_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLVM_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "Tactical Visu :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopVisu,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startVisu,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		
		elsif ($i == $DATASERVER_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DATASERVER_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "Data Server :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDataServer,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDataServer,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}		
		elsif ($i == $DLIP_C3M_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isLynxProcessRunning($DLIP_C3M_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "DLIP C3M :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopC3M,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startC3M,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $OSIM_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($OSIM_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "OSIM :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopOSIM,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startOSIM,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $AIS_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($AIS_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "AIS    :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopAIS,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startAIS,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $TMCT_NUM){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($TMCT_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "TMCT :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopTMCT,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startTMCT,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == 111){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLTE_ALTBMD_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "DLTE JRE", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLTE_ALTBMD,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLTE_ALTBMD,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		
		elsif ($i == 112){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLTE_SIMU_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}
			$Hframe[$i]->Label(-text  => "DLTE SIMU :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLTE_SIMU,
								-image => $initialStopPhoto, -background => 'grey', )->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLTE_SIMU,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == $CMD_START_NUM){
			$Hframe[$i]->Label(-text  => "Process :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startAll,
								-text => "Start All", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		elsif ($i == $CMD_STATUS_NUM){
			$Hframe[$i]->Label(-text  => "Process Status :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&updateStatus,
								-text => "Refresh", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		elsif ($i == $CMD_LOG_NUM){
			$Hframe[$i]->Label(-text  => "Log :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&saveLog,
								-text => "Save", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		elsif ($i == $CMD_EXIT_NUM){
			$Hframe[$i]->Label(-text  => "JRE Stater :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&exitJREStarter,
								-text => "Exit", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		else {
			$Hframe[$i]->Label(-text  => "", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Label(-image => "blankPhoto", -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Label(-image => "blankPhoto", -background => 'grey')->pack(-side => 'left');
			
		}
		$i +=  1;
	}
	$mw->geometry("-200+10");
	$mw->update;		
	#startAll();
	updateStatus();
	MainLoop();
}

sub startAll {
	startAIS();
	startC3M();
	sleep 3;
	startOSIM();
	sleep 3;
	startTMCT();
	sleep 1;
	startSpyLinks();
	sleep 3;
#	startTDL_ROUTER();
#	sleep 1;
#	startJREP();
#	startJREM();
#	startDLIPCOM();
#	startDLIPMng();
#	sleep 3;
	updateStatus();
}
	
sub startTDL_ROUTER {
	my $image = $startButton[$TDL_ROUTER_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($TDL_ROUTER_EXE) && confirmAction ("Start TDL_ROUTER ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($TDL_ROUTER_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($TDL_ROUTER_EXE) ){
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopPhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopTDL_ROUTER {
	my $image = $stopButton[$TDL_ROUTER_NUM]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isSolarisProcessRunning ($TDL_ROUTER_EXE) && confirmAction ("Stop TDL_ROUTER ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($TDL_ROUTER_STOP);
		#stopSolarisProcess ($TDL_ROUTER_EXE);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($TDL_ROUTER_EXE) ){
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopPhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub startL16 {
	my $image = $startButton[$L16_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($L16_EXE) && confirmAction ("Start L16 TD?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($L16_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($L16_EXE) ){
		$stopButton[$L16_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$L16_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$L16_NUM]->configure(-image => 'stopPhoto');
		$startButton[$L16_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopL16 {
	my $image = $stopButton[$L16_NUM]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isSolarisProcessRunning ($L16_EXE) && confirmAction ("Stop L16 TD?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($L16_STOP);
		#stopSolarisProcess ($L16_EXE);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($L16_EXE) ){
		$stopButton[$L16_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$L16_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$L16_NUM]->configure(-image => 'stopPhoto');
		$startButton[$L16_NUM]->configure(-image => 'startInactivePhoto');
	}
}
sub startHOST {
	my $image = $startButton[$HOST_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($HOST_EXE) && confirmAction ("Start HOST TD ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($HOST_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($HOST_EXE) ){
		$stopButton[$HOST_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$HOST_NUM]->configure(-image => 'stopPhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopHOST {
	my $image = $stopButton[$HOST_NUM]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isSolarisProcessRunning ($HOST_EXE) && confirmAction ("Stop HOST ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($HOST_STOP);
		#stopSolarisProcess ($HOST_EXE);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($HOST_EXE) ){
		$stopButton[$HOST_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$HOST_NUM]->configure(-image => 'stopPhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startInactivePhoto');
	}
}


sub startJREP {
	my $image = $startButton[$JREP_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($JREP_EXE) && confirmAction ("Start JREP ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($JREP_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($JREP_EXE) ){
		$stopButton[$JREP_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREP_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopJREP {
	my $image = $stopButton[$JREP_NUM]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isSolarisProcessRunning ($JREP_EXE) && confirmAction ("Stop JREP ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($JREP_STOP);
		#stopSolarisProcess ($JREP_EXE);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($JREP_EXE) ){
		$stopButton[$JREP_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREP_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub startC3M {
	my $image = $startButton[$DLIP_C3M_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isLynxProcessRunning ($DLIP_C3M_EXE) && confirmAction ("Start DLIP C3M ?") eq "Yes") {
		print "$image\n";
		print "$DLIP_C3M_START\n";
		startLynxProcess ($DLIP_C3M_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isLynxProcessRunning ($DLIP_C3M_EXE) ){
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopC3M {
	my $image = $stopButton[$DLIP_C3M_NUM]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isLynxProcessRunning ($DLIP_C3M_EXE) && confirmAction ("Stop DLIP C3M ?") eq "Yes") {
		#print "$image\n";
		startLynxProcess ($DLIP_C3M_STOP);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isLynxProcessRunning ($DLIP_C3M_EXE) ){
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub startDLIPMng {
	my $image = $startButton[$DLIPMng_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isWindowsProcessRunning ($DLIPMng_WIN_NAME) && confirmAction ("Start DLIP Manager ?") eq "Yes") {
		#print "$image\n";
		startWindowsProcess ($DLIPMng_EXE, $DLIPMng_RUN_DIR, $DLIPMng_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 3;
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME) ){
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopDLIPMng {
	my $image = $stopButton[$DLIPMng_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLIPMng_WIN_NAME) && confirmAction ("Stop DLIP Manager ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($DLIPMng_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME) ){
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startInactivePhoto');
	}
}
sub startJREM {
	my $image = $startButton[$JREM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "startInactivePhoto" && ! isWindowsProcessRunning ($JREM_WIN_NAME) && confirmAction ("Start JREP Manager ?") eq "Yes") {
		#print "$image\n";
		startWindowsProcess ($JREM_EXE, $JREM_RUN_DIR, $JREM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 5;
	if (isWindowsProcessRunning ($JREM_WIN_NAME) ){
		$stopButton[$JREM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub startDLIPCOM {
	my $image = $startButton[$DLIPCOM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "startInactivePhoto" && ! isWindowsProcessRunning ($DLIPCOM_WIN_NAME) && confirmAction ("Start DLIPCOM Manager ?") eq "Yes") {
		#print "$image\n";
		startWindowsProcess ($DLIPCOM_EXE, $DLIPCOM_RUN_DIR, $DLIPCOM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 5;
	if (isWindowsProcessRunning ($DLIPCOM_WIN_NAME) ){
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopJREM {
	my $image = $stopButton[$JREM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($JREM_WIN_NAME) && confirmAction ("Stop JREP Manager ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($JREM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isWindowsProcessRunning ($JREM_WIN_NAME) ){
		$stopButton[$JREM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub stopDLIPCOM {
	my $image = $stopButton[$DLIPCOM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLIPCOM_WIN_NAME) && confirmAction ("Stop DLIPCOM Manager ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($DLIPCOM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isWindowsProcessRunning ($DLIPCOM_WIN_NAME) ){
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub startSpyLinks {
	my $image = $startButton[$SPY_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "startInactivePhoto" && ! isWindowsProcessRunning ($SPY_WIN_NAME) && confirmAction ("Start Spy Links ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
		startWindowsProcess ($SPY_EXE, $SPY_RUN_DIR, $SPY_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 15;
	updateSpyLinksState();
}

sub stopSpyLinks {
	my $image = $stopButton[$SPY_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($SPY_WIN_NAME) && confirmAction ("Stop Spy Links ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($SPY_WIN_NAME);
		stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	updateSpyLinksState();
}

sub startVisu {
	my $image = $startButton[$DLVM_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($DLVM_WIN_NAME) 
		&& isWindowsProcessRunning ($SPY_WIN_NAME)
		&& confirmAction ("Start Tactical Visu ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($DATASERVER_WIN_NAME);
		startWindowsProcess ($DLVM_EXE, $DLVM_RUN_DIR, $DLVM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateSpyLinksState();
}

sub stopVisu {
	my $image = $stopButton[$DLVM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLVM_WIN_NAME) && confirmAction ("Stop Tactical Visu ?") eq "Yes") {
		#print "$image\n";
		#stopWindowsProcess ($SPY_WIN_NAME);
		stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	updateSpyLinksState();
}

sub startDataServer {
	acquittementAction("Operation not permitted");
	updateSpyLinksState();
}

sub stopDataServer {
	my $image = $stopButton[$DATASERVER_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DATASERVER_WIN_NAME) && confirmAction ("Stop Data Server ?") eq "Yes") {
		#print "$image\n";
		#stopWindowsProcess ($SPY_WIN_NAME);
		#stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted");
		print "Operation not permitted !\n";		
	}
	updateSpyLinksState();
}

sub startOSIM {
	my $image = $startButton[$OSIM_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($OSIM_WIN_NAME) 
		&& confirmAction ("Start OSIM ?") eq "Yes") {
		print "$image\n";
		startWindowsProcess ($OSIM_EXE, $OSIM_RUN_DIR, $OSIM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateOSIMState();
}

sub stopOSIM {
	my $image = $stopButton[$OSIM_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($OSIM_WIN_NAME) && confirmAction ("Stop OSIM ?") eq "Yes") {
		print "$image\n";
		stopWindowsProcess ($MAPPOINT_EXE);
		stopWindowsProcess ($OSIM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateOSIMState();
}

sub startTMCT {
	my $image = $startButton[$TMCT_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($TMCT_WIN_NAME) 
		&& confirmAction ("Start TMCT ?") eq "Yes") {
		print "$image\n";
		startWindowsProcess ($TMCT_EXE, $TMCT_RUN_DIR, $TMCT_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateTMCT_State();
}

sub stopTMCT {
	my $image = $stopButton[$TMCT_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($TMCT_WIN_NAME) && confirmAction ("Stop TMCT ?") eq "Yes") {
		print "$image\n";
		stopWindowsProcess ($TMCT_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateTMCT_State();
}

sub startAIS {
	my $image = $startButton[$AIS_NUM]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($AIS_WIN_NAME) 
		&& confirmAction ("Start AIS ?") eq "Yes") {
		print "$image\n";
		startWindowsProcess ($AIS_EXE, $AIS_RUN_DIR, $AIS_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateAIS_State();
}

sub stopAIS {
	my $image = $stopButton[$AIS_NUM]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($AIS_WIN_NAME) && confirmAction ("Stop AIS ?") eq "Yes") {
		print "$image\n";
		stopWindowsProcess ($AIS_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateAIS_State();
}

sub startDLTE_SIMU {
	my $image = $startButton[12]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($DLTE_SIMU_WIN_NAME) 
		&& confirmAction ("Start DLTE SIMU ?") eq "Yes") {
		print "$image\n";
		startWindowsProcess ($DLTE_SIMU_EXE, $DLTE_SIMU_RUN_DIR, $DLTE_SIMU_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateDLTE_SIMU_State();
}

sub stopDLTE_SIMU {
	my $image = $stopButton[12]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLTE_SIMU_WIN_NAME) && confirmAction ("Stop DLTE SIMU ?") eq "Yes") {
		print "$image\n";
		stopWindowsProcess ($DLTE_IHM_WIN_NAME);
		stopWindowsProcess ($DLTE_SIMU_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateDLTE_SIMU_State();
}

sub stopEXCELProcess {
	my $PID = isWindowsProcessRunning("EXCEL.EXE");
	while ($PID){
		stopWindowsProcess("EXCEL.EXE");
		$PID = isWindowsProcessRunning("EXCEL.EXE");
	}
}

sub updateSpyLinksState {
		if (isWindowsProcessRunning ($SPY_WIN_NAME) ){
		$stopButton[$SPY_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$SPY_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$SPY_NUM]->configure(-image => 'stopPhoto');
		$startButton[$SPY_NUM]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DLVM_WIN_NAME) ){
		$stopButton[$DLVM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLVM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLVM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLVM_NUM]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DATASERVER_WIN_NAME) ){
		$stopButton[$DATASERVER_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DATASERVER_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DATASERVER_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DATASERVER_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub updateOSIMState {
	if (isWindowsProcessRunning ($OSIM_WIN_NAME) ){
		$stopButton[$OSIM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$OSIM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$OSIM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$OSIM_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub updateTMCT_State {
	if (isWindowsProcessRunning ($TMCT_WIN_NAME) ){
		$stopButton[$TMCT_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$TMCT_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$TMCT_NUM]->configure(-image => 'stopPhoto');
		$startButton[$TMCT_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub updateAIS_State {
	if (isWindowsProcessRunning ($AIS_WIN_NAME) ){
		$stopButton[$AIS_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$AIS_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$AIS_NUM]->configure(-image => 'stopPhoto');
		$startButton[$AIS_NUM]->configure(-image => 'startInactivePhoto');
	}
}

sub updateDLTE_SIMU_State {
	if (isWindowsProcessRunning ($DLTE_SIMU_WIN_NAME) ){
		$stopButton[12]->configure(-image => 'stopInactivePhoto');
		$startButton[12]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[12]->configure(-image => 'stopPhoto');
		$startButton[12]->configure(-image => 'startInactivePhoto');
	}
}				

sub updateC3MState{
	if (isLynxProcessRunning ($DLIP_C3M_EXE) ){
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIP_C3M_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIP_C3M_NUM]->configure(-image => 'startInactivePhoto');
	}
}		

sub updateStatus {
	if(isSolarisProcessRunning($L16_EXE)) {
		$stopButton[$L16_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$L16_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$L16_NUM]->configure(-image => 'stopPhoto');
		$startButton[$L16_NUM]->configure(-image => 'startInactivePhoto');
	}
	if(isSolarisProcessRunning($HOST_EXE)) {
		$stopButton[$HOST_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$HOST_NUM]->configure(-image => 'stopPhoto');
		$startButton[$HOST_NUM]->configure(-image => 'startInactivePhoto');
	}
	if(isSolarisProcessRunning($TDL_ROUTER_EXE)) {
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$TDL_ROUTER_NUM]->configure(-image => 'stopPhoto');
		$startButton[$TDL_ROUTER_NUM]->configure(-image => 'startInactivePhoto');
	}
	if(isSolarisProcessRunning($JREP_EXE)) {
		$stopButton[$JREP_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREP_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME)){
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startInactivePhoto');
	}
	if(isWindowsProcessRunning($JREM_WIN_NAME)){
		$stopButton[$JREM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREM_NUM]->configure(-image => 'startInactivePhoto');
	}
	if(isWindowsProcessRunning($DLIPCOM_WIN_NAME)){
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPCOM_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPCOM_NUM]->configure(-image => 'startInactivePhoto');
	}
	updateSpyLinksState;	
	updateDLTE_SIMU_State;
	updateTMCT_State;
	updateAIS_State;
	updateOSIMState;
	updateC3MState;
}	

sub saveLog {
	if(confirmAction("Save Log File ? It will stop all applications !")){
		stopC3M;
		stopTDL_ROUTER;
		stopJREP;
		stopSpyLinks;
		updateStatus;
		my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
		$year += 1900; $mon += 1;
		$mon = "0".$mon if($mon<10);
		$mday = "0".$mday if($mday <10);
		$hour = "0".$hour if($hour <10);
		$min = "0".$min if($min <10);
		$sec = "0".$sec if($sec <10);
		my $newDir = "$year-$mon-$mday-$hour-$min-$sec";
		chdir($LOG_DIR);
		if (! -d "$LOG_DIR\\$newDir"){
			system("mkdir $LOG_DIR\\$newDir") if (confirmAction("Make new dir $LOG_DIR\\$newDir ?"));
		}
		if (-d  "$LOG_DIR\\$newDir"){
			print "create dir\n";
			# 
			system("rcp -b DLIP_C3M.dlip:$DLIP_C3M_LOG_DIR/*.log .");
			# retrieve DLIP log
			#print "pscp thales\@$putty_session:$TDL_ROUTER_LOG_DIR/*.log $LOG_DIR\\$newDir\n";
			system("pscp thales\@$putty_session:$TDL_ROUTER_LOG_DIR/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save DLIP log ?"));
			acquittementAction("That's all flok !");
			# retrieve JREP log
			system("pscp thales\@$putty_session:$JREP_LOG_DIR/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save JREP log ?"));
			acquittementAction("That's all folk !");
			system("XCOPY /I \"$SPY_LOG_DIR\\*.rcd\" $LOG_DIR\\$newDir") if (confirmAction("Save Spylinks log ?"));
			
		}
	}
	if(confirmAction("Clear Log File ?")){
		startSolarisProcess($CLEAR_TDL_ROUTER_LOG);
		startSolarisProcess($CLEAR_JREP_LOG);
		#system("DEL /Q \"$SPY_LOG_DIR\\*.rcd\"");
	}
}

sub exitJREStarter {
	stopTDL_ROUTER;
	stopJREP;
	stopL16;
	stopDLIPMng;
	stopJREM;
	stopDLIPCOM;
	stopSpyLinks;
	stopOSIM;
	stopC3M;
	stopAIS;
	stopTMCT;
	stopDLTE_SIMU;
	exit 0 if(confirmAction("Exit JRE starter ?"));
}

sub isSolarisProcessRunning {
	my $process_name = shift;
	my $PID = 0;
	#print "process : $process_name\n";
	my $process_list = `plink $putty_session ps -edf`;
	(my @process_list) = split("\n", $process_list);
	foreach my $current_process (@process_list){
		#print "$current_process\n";
		if ($current_process =~/$process_name/){
			#print "here it is !\n";
			(my @PID) = split(" ", $current_process);
			$PID = $PID[1];
			#print "$PID\n";
			last;
		}
	}
	return $PID;
}
		
sub startSolarisProcess {
	my $process_cmd = shift;
	#print "$process_cmd\n";
	system("plink $putty_session \"$process_cmd\"");
	return;
}
sub stopSolarisProcess {
	my $process_name = shift;
	my $PID_process = isSolarisProcessRunning($process_name);
	#print "$process, $process_run_dir\n";
	system("plink $putty_session \"kill -9 $PID_process\"");
	return;
}

sub isLynxProcessRunning {
	my $process_name = shift;
	my $PID = 0;
	#print "process : $process_name\n";
	my $process_list = `rsh 24.1.1.4 -l dlip  ps -ax`;
	(my @process_list) = split("\n", $process_list);
	foreach my $current_process (@process_list){
		print "$current_process\n";
		if ($current_process =~/$process_name/){
			print "here it is !\n";
			(my @PID) = split(" ", $current_process);
			$PID = $PID[1];
			print "$PID\n";
			last;
		}
	}
	return $PID;
}
sub startLynxProcess {
	my $process_cmd = shift;
	#print "$process_cmd\n";
	system("$process_cmd");
	return 0;
	}
sub stopLynxProcess {
	my $process_name = shift;
	my $PID_process = isLynxProcessRunning($process_name);
	print "$process_name, $PID_process\n";
	system("$process_name");
	return 0;
	}

sub isWindowsProcessRunning {
	my $process_name = shift;
	my $PID = 0;
	print "process : $process_name\n";
	my $process_list = `tasklist.exe /V`;
	(my @process_list) = split("\n", $process_list);
	foreach my $current_process (@process_list){
		#print "$current_process\n";
		if ($current_process =~/$process_name/){
			print "here it is !\n";
			(my @PID) = split(" ", $current_process);
			$PID = $PID[1];
			print "$PID\n";
			last;
		}
	}
	return $PID;
}
		
sub startWindowsProcess {
	my $process_cmd = shift;
	my $process_run_dir = shift;
	my $process_win_name = shift;
	#print "$process_cmd\n";
	print" cd \"$process_run_dir\" && start /B /MIN	\"$process_win_name\" $process_cmd ";
	#system("cd \"$process_run_dir\" && start /B /MIN	\"$process_win_name\" $process_cmd ");
	system("start /D \"$process_run_dir\"  /MIN	\"$process_win_name\" $process_cmd ");
	return;
}
sub stopWindowsProcess {
	my $process_name = shift;
	my $PID_process = isWindowsProcessRunning($process_name);
	#print "$process, $process_run_dir\n";
	system("taskkill /PID $PID_process /T /F") if($PID_process);
	return;
}

sub confirmAction {
	my $question = shift;
	my $dialog = $mw->Dialog(-text => "$question", -title => 'Operator confirmation', -default_button => 'Yes', -buttons => [qw/Yes No/]);
	my $response = $dialog->Show(-popover => $mw);
	return $response;
}
sub acquittementAction {
	my $question = shift;
	my $dialog = $mw->Dialog(-text => "$question", -title => 'Operator confirmation', -default_button => 'Yes', -buttons => [qw/OK/]);
	my $response = $dialog->Show(-popover => $mw);
	return $response;
}

