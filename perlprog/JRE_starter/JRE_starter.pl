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

my $DLIP_EXE = "./dlip_main";
my $DLIP_RUN_DIR = "/export/home/thales/scripts";
my $DLIP_START = "cd $DLIP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./start_DLIP >& /dev/null &";
my $DLIP_STOP = "cd $DLIP_RUN_DIR; ./stop_DLIP >& /dev/null &";
my $DLIP_CMD = "cd $DLIP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./$DLIP_EXE >& /dev/null &";
my $DLIP_LOG = "altbmd1c_main.log";
my $DLIP_LOG_DIR ="/export/home/thales/DLIP";
my $CLEAR_DLIP_LOG = "cd $DLIP_RUN_DIR; ./clear_DLIP_log";

my $JREP_EXE = "jre_main";
my $JREP_RUN_DIR = "/export/home/thales/scripts";
my $JREP_START = "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./start_JREP >& /dev/null &";
my $JREP_STOP = "cd $JREP_RUN_DIR; ./stop_JREP >& /dev/null &";
my $JREP_CMD = "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./$JREP_EXE >& /dev/null &";
my @JREP_LOG = ("jre.log", "jre-1.log");
my $JREP_LOG_DIR = "/export/home/thales/JREP/trace";
my $CLEAR_JREP_LOG = "cd $JREP_RUN_DIR; ./clear_JREP_log";

my $DLIPMng_EXE = "launcher.bat";
my $DLIPMng_WIN_NAME = "launcher.bat";
my $DLIPMng_RUN_DIR = "E:\\THALES\\DLIPmng_V1R1E5_Nobel_Ardent\\DLIPL16Mng-Delivery";

my $JREM_EXE = "launch.bat";
my $JREM_WIN_NAME = "JRE Management";
my $JREM_RUN_DIR = "E:\\THALES\\JREM_V14R0_Noble_Ardent\\bin";

my $SPY_EXE = "launch_spylinks.js";
my $SPY_WIN_NAME = "DLEM";
my $SPY_RUN_DIR = "E:\\THALES\\SpyLinks";
my $SPY_LOG_DIR = "C:\\Program Files\\TCF\\Spylinks\\DLEM\\Software";

my $DATASERVER_EXE = "";
my $DATASERVER_WIN_NAME = "DataServer";
my $DATASERVER_RUN_DIR = "";

my $DLVM_EXE = "launch_dlvm.js";
my $DLVM_WIN_NAME = "DLVM";
my $DLVM_RUN_DIR = "E:\\THALES\\SpyLinks";

my $TMCT_EXE = "tmct_monolithique_ss.exe";
my $TMCT_RUN_DIR = "E:\\THALES\\TMCT\\bin";
my $TMCT_WIN_NAME = "Thales TMCT";

my	@startButton;
my	@stopButton;
my $i;

my $mw;

# print $ENV{PWD};
if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}

if(! $opt_h) {
	
	$mw = MainWindow->new(-background => 'grey');
	$mw->title( "THALES : JRE Starter" );
	
	
	my $widthLabel = 15;
	my @Hframe;
	my @photo;
	my $startPhoto= $mw->Photo("startPhoto", -file => "Images/Start_actif.gif");
	my $stopPhoto= $mw->Photo("stopPhoto", -file => "Images/Stop_actif.gif");
	my $startInactivePhoto= $mw->Photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	my $stopInactivePhoto= $mw->Photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	my $blankPhoto = $mw->Photo("blankPhoto", -file => "Images/Blank.gif");
	
	my $string = " JRE Starter ";
	
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
		elsif ($i == 1){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isSolarisProcessRunning($DLIP_EXE)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}			
			$Hframe[$i]->Label(-text  => "DLIP :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLIP,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLIP,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}

		elsif ($i == 2){
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
		elsif ($i == 3){
			my $initialStartPhoto, my $initialStopPhoto;
			if(isWindowsProcessRunning($DLIPMng_WIN_NAME)){
				$initialStartPhoto = "startPhoto";
				$initialStopPhoto = "stopInactivePhoto";
			}
			else {
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			}	
			$Hframe[$i]->Label(-text  => "DLIP Mng:", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$stopButton[$i] = $Hframe[$i]->Button(-command => \&stopDLIPMng,
								-image => $initialStopPhoto, -background => 'grey')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&startDLIPMng,
								-image => $initialStartPhoto, -background => 'grey')->pack(-side => 'left');
		}
		elsif ($i == 4){
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
		elsif ($i == 5){
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
		elsif ($i == 6){
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
		
		elsif ($i == 7){
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
		elsif ($i == 8){
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
		elsif ($i == 9){
			$Hframe[$i]->Label(-text  => "Process Status :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&updateStatus,
								-text => "Refresh", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		elsif ($i == 10){
			$Hframe[$i]->Label(-text  => "Log :", -width => $widthLabel, -background => 'grey', -anchor => 'e')->pack(-side => 'left');
			$startButton[$i] = $Hframe[$i]->Button(-command => \&saveLog,
								-text => "Save", -width => 10, -background => 'grey', )->pack(-side => 'left');		
		}
		elsif ($i == 11){
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
	$mw->geometry("-40+10");
	$mw->update;
	MainLoop();
}	

sub startDLIP {
	my $image = $startButton[1]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($DLIP_EXE) && confirmAction ("Start DLIP ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($DLIP_START);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($DLIP_EXE) ){
		$stopButton[1]->configure(-image => 'stopInactivePhoto');
		$startButton[1]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[1]->configure(-image => 'stopPhoto');
		$startButton[1]->configure(-image => 'startInactivePhoto');
	}
}

sub stopDLIP {
	my $image = $stopButton[1]->cget('-image');
	print "$image\n";
	if( $image eq "stopInactivePhoto" && isSolarisProcessRunning ($DLIP_EXE) && confirmAction ("Stop DLIP ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($DLIP_STOP);
		#stopSolarisProcess ($DLIP_EXE);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isSolarisProcessRunning ($DLIP_EXE) ){
		$stopButton[1]->configure(-image => 'stopInactivePhoto');
		$startButton[1]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[1]->configure(-image => 'stopPhoto');
		$startButton[1]->configure(-image => 'startInactivePhoto');
	}
}
sub startJREP {
	my $image = $startButton[2]->cget('-image');
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
		$stopButton[2]->configure(-image => 'stopInactivePhoto');
		$startButton[2]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[2]->configure(-image => 'stopPhoto');
		$startButton[2]->configure(-image => 'startInactivePhoto');
	}
}

sub stopJREP {
	my $image = $stopButton[2]->cget('-image');
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
		$stopButton[2]->configure(-image => 'stopInactivePhoto');
		$startButton[2]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[2]->configure(-image => 'stopPhoto');
		$startButton[2]->configure(-image => 'startInactivePhoto');
	}
}

sub startDLIPMng {
	my $image = $startButton[3]->cget('-image');
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
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME) ){
		$stopButton[3]->configure(-image => 'stopInactivePhoto');
		$startButton[3]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[3]->configure(-image => 'stopPhoto');
		$startButton[3]->configure(-image => 'startInactivePhoto');
	}
}

sub stopDLIPMng {
	my $image = $stopButton[3]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLIPMng_WIN_NAME) && confirmAction ("Stop DLIP Manager ?") eq "Yes") {
		#print "$image\n";
		stopWindowsProcess ($DLIPMng_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME) ){
		$stopButton[3]->configure(-image => 'stopInactivePhoto');
		$startButton[3]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[3]->configure(-image => 'stopPhoto');
		$startButton[3]->configure(-image => 'startInactivePhoto');
	}
}
sub startJREM {
	my $image = $startButton[4]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isWindowsProcessRunning ($JREM_WIN_NAME) && confirmAction ("Start JREP Manager ?") eq "Yes") {
		#print "$image\n";
		startWindowsProcess ($JREM_EXE, $JREM_RUN_DIR, $JREM_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	if (isWindowsProcessRunning ($JREM_WIN_NAME) ){
		$stopButton[4]->configure(-image => 'stopInactivePhoto');
		$startButton[4]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[4]->configure(-image => 'stopPhoto');
		$startButton[4]->configure(-image => 'startInactivePhoto');
	}
}

sub stopJREM {
	my $image = $stopButton[4]->cget('-image');
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
		$stopButton[4]->configure(-image => 'stopInactivePhoto');
		$startButton[4]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[4]->configure(-image => 'stopPhoto');
		$startButton[4]->configure(-image => 'startInactivePhoto');
	}
}

sub startSpyLinks {
	my $image = $startButton[5]->cget('-image');
	print "$image\n";
	;
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
	my $image = $stopButton[5]->cget('-image');
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
	my $image = $startButton[6]->cget('-image');
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
	my $image = $stopButton[6]->cget('-image');
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
	my $image = $stopButton[7]->cget('-image');
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

sub startTMCT {
	my $image = $startButton[8]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" 
		&& ! isWindowsProcessRunning ($TMCT_WIN_NAME) 
		&& confirmAction ("Start TMCT ?") eq "Yes") {
		#print "$image\n";
		startWindowsProcess ($TMCT_EXE, $TMCT_RUN_DIR, $TMCT_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if( ! $image eq "startInactivePhoto" );
		print "Operation not permitted !\n";		
	}
	updateTMCTState();
}

sub stopTMCT {
	my $image = $stopButton[8]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($TMCT_WIN_NAME) && confirmAction ("Stop TMCT ?") eq "Yes") {
		#print "$image\n";
		#stopWindowsProcess ($SPY_WIN_NAME);
		stopWindowsProcess ($TMCT_WIN_NAME);
	}
	else {
		acquittementAction("Operation not permitted") if ( ! $image eq "stopInactivePhoto");
		print "Operation not permitted !\n";		
	}
	stopEXCELProcess();
	updateTMCTState();
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
		$stopButton[5]->configure(-image => 'stopInactivePhoto');
		$startButton[5]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[5]->configure(-image => 'stopPhoto');
		$startButton[5]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DLVM_WIN_NAME) ){
		$stopButton[6]->configure(-image => 'stopInactivePhoto');
		$startButton[6]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[6]->configure(-image => 'stopPhoto');
		$startButton[6]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DATASERVER_WIN_NAME) ){
		$stopButton[7]->configure(-image => 'stopInactivePhoto');
		$startButton[7]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[7]->configure(-image => 'stopPhoto');
		$startButton[7]->configure(-image => 'startInactivePhoto');
	}
}

sub updateTMCTState {
	if (isWindowsProcessRunning ($TMCT_WIN_NAME) ){
		$stopButton[8]->configure(-image => 'stopInactivePhoto');
		$startButton[8]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[8]->configure(-image => 'stopPhoto');
		$startButton[8]->configure(-image => 'startInactivePhoto');
	}
}	

sub updateStatus {
	if(isSolarisProcessRunning($DLIP_EXE)) {
		$stopButton[1]->configure(-image => 'stopInactivePhoto');
		$startButton[1]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[1]->configure(-image => 'stopPhoto');
		$startButton[1]->configure(-image => 'startInactivePhoto');
	}
	if(isSolarisProcessRunning($JREP_EXE)) {
		$stopButton[2]->configure(-image => 'stopInactivePhoto');
		$startButton[2]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[2]->configure(-image => 'stopPhoto');
		$startButton[2]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DLIPMng_WIN_NAME)){
		$stopButton[3]->configure(-image => 'stopInactivePhoto');
		$startButton[3]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[3]->configure(-image => 'stopPhoto');
		$startButton[3]->configure(-image => 'startInactivePhoto');
	}
	if(isWindowsProcessRunning($JREM_WIN_NAME)){
		$stopButton[4]->configure(-image => 'stopInactivePhoto');
		$startButton[4]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[4]->configure(-image => 'stopPhoto');
		$startButton[4]->configure(-image => 'startInactivePhoto');
	}
	updateTMCTState;
	updateSpyLinksState;	
}	

sub saveLog {
	if(confirmAction("Save Log File ? It will stop all applications !")){
		stopDLIP;
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
			# retrieve DLIP log
			#print "pscp thales\@$putty_session:$DLIP_LOG_DIR/*.log $LOG_DIR\\$newDir\n";
			system("pscp thales\@$putty_session:$DLIP_LOG_DIR/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save DLIP log ?"));
			acquittementAction("That's all flok !");
			# retrieve JREP log
			system("pscp thales\@$putty_session:$JREP_LOG_DIR/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save JREP log ?"));
			acquittementAction("That's all folk !");
			system("XCOPY /I \"$SPY_LOG_DIR\\*.rcd\" $LOG_DIR\\$newDir") if (confirmAction("Save Spylinks log ?"));
			
		}
	}
	if(confirmAction("Clear Log File ?")){
		startSolarisProcess($CLEAR_DLIP_LOG);
		startSolarisProcess($CLEAR_JREP_LOG);
		#system("DEL /Q \"$SPY_LOG_DIR\\*.rcd\"");
	}
}

sub exitJREStarter {
	stopDLIP;
	stopJREP;
	stopDLIPMng;
	stopJREM;
	stopSpyLinks;
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

sub isWindowsProcessRunning {
	my $process_name = shift;
	my $PID = 0;
	#print "process : $process_name\n";
	my $process_list = `tasklist.exe /V`;
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
		
sub startWindowsProcess {
	my $process_cmd = shift;
	my $process_run_dir = shift;
	my $process_win_name = shift;
	#print "$process_cmd\n";
	system("cd \"$process_run_dir\" && start	\"$process_win_name\" $process_cmd ");
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
	my $dialog = $mw->Dialog(-text => "$question", -title => 'Operator acquittement', -default_button => 'Ok', -buttons => [qw/Ok/]);
	my $response = $dialog->Show(-popover => $mw);
	return $response;
}


