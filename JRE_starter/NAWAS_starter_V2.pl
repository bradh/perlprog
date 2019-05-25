#!/usr/bin/perl -w
# Lancement demo marine de façon graphique
#
#  par S. Mouchot

use Getopt::Std;
#use strict;
use Tkx;
use Threads;

#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $putty_session = "JRE-Gateway";

my @TaskList = ("DLIP", "JREP");

my $LOG_DIR = "E:\\LOG";
# ordre d'affichage des boutons
local $C3M_LABEL_NUM = 1;
local $AIS_NUM = 2;
local $OSIM_NUM = 3;
local $DLIP_C3M_NUM = 4;
local $TMCT_NUM = 5;
local $SPY_LABEL_NUM = 6;
local $SPY_NUM = 7;
local $DATASERVER_NUM = 8;
local $DLVM_NUM = 9;

local $JRE_LABEL_NUM = 10;
local $DLIP_NUM = 11;
local $JREP_NUM = 12;
local $DLIPMng_NUM = 13;
local $JREM_NUM = 14;
local $SPY_JRE_NUM = 15;

my $CMD_LABEL_NUM = 16;
my $CMD_START_NUM = 17;
my $CMD_STATUS_NUM = 18;
my $CMD_LOG_NUM = 19;
my $CMD_EXIT_NUM = 20;

# Process Lynx

local $DLIP_C3M = {	'NUM'		=> $DLIP_C3M_NUM, 
				'EXE' 		=> "./mct_main",
				'RUN_DIR' 	=> "/home1/dlip/Ops",
				'START' 	=> "rsh 24.1.1.1 -l dlip cd Ops;start",
				'STOP' 		=> "rsh 24.1.1.1 -l dlip cd Ops;stop",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "/home1/dlip/Ops",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "LYNX"
};

# Solaris Process
local $DLIP = {	'NUM'		=> $DLIP_NUM, 
				'EXE' 		=> "./dlip_main",
				'RUN_DIR' 	=> "/export/home/thales/scripts",
				'START' 	=> "cd /export/home/thales/scripts; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./start_DLIP >& /dev/null &",
				'STOP' 		=> "cd /export/home/thales/scripts; ./stop_DLIP >& /dev/null &",
				'CMD' 		=> "cd /export/home/thales/scripts; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./dlip_main >& /dev/null &",
				'LOG' 		=> "dlip_main.log",
				'LOG_DIR' 	=> "/export/home/thales/DLIP",
				'CLEAR_LOG' 	=> "cd /export/home/thales/scripts; ./clear_DLIP_log",
				'OPERATING_SYST'	=> "SOLARIS"
};
local $JREP = {	'NUM'		=> $JREP_NUM, 
				'EXE' 		=> "./jre_main",
				'RUN_DIR' 	=> "/export/home/thales/scripts",
				'START' 	=> "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./start_JREP >& /dev/null &",
				'STOP' 		=> "cd $JREP_RUN_DIR; ./stop_JREP >& /dev/null &",
				'CMD' 		=> "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./jre_main >& /dev/null &",
				'LOG' 		=> "jre.log",
				'LOG_DIR' 	=> "/export/home/thales/DLIP",
				'CLEAR_LOG' 	=> "cd $JREP_RUN_DIR; ./clear_JREP_log",
				'OPERATING_SYST'	=> "SOLARIS"
};





my $DLIPMng_EXE = "launcher.bat";
my $DLIPMng_WIN_NAME = "DLIP L16 Mng";
my $DLIPMng_RUN_DIR = "E:\\THALES\\DLIPmng_V1R1E5_NAWAS\\DLIPL16Mng-Delivery\\";

my $JREM_EXE = "launch.bat";
my $JREM_WIN_NAME = "JRE Management";
my $JREM_RUN_DIR = "E:\\THALES\\JREM_V14R3_NAWAS\\bin";

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
my $AIS_RUN_DIR = "C:\\Program Files\\L16ES\\AIS\\";
my $AIS_LOG_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\Logs";

my $NPG_EXE = "npg.bat";
my $NPG_WIN_NAME = "npg.exe";
my $NPG_RUN_DIR = "C:\\Program Files\\Npg\\bin\\";
my $NPG_LOG_DIR = "C:\\Program Files\\Spy-LinksV3BetaRev2\\Logs";



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
my $widthLabel;
my @Hframe;
my @photo;
my $startPhoto;
my $stopPhoto;
my $startInactivePhoto;
my $stopInactivePhoto;
my $blankPhoto;	

my $i;

my$mw;

# print $ENV{PWD};
if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}

if(! $opt_h) {

	$mw = Tkx::widget->new(".", -background => 'grey');
	$mw->g_wm_title( "THALES : NAWAS Starter" );
		
	$widthLabel = 10;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	
	my $string = " CWIX Starter       ";
	
	#waiting for SUN synchronization
	my $SUN_SYNCHRO_STATE = 0;
	my $LYNX_SYNCHRO_STATE = 0;
	while(0){
	#while(0&& ! $SUN_SYNCHRO_STATE){
		my $NTP_CMD = `plink $putty_session \"ntpq -p\"`;
		print "wait for SUN synchro...";
		$SUN_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*LOCAL/);
		sleep 1;
	}
	print "SUN Synchro ok !\n";
	while(0){
	#while(00&&! $LYNX_SYNCHRO_STATE){
		my $NTP_CMD = `rsh 24.1.1.1 -l dlip \"ntpq -p\"`;
		print "$NTP_CMD \n wait for Lynx synchro...";
		$LYNX_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*/);
		sleep 1;
	}
	print "Lynx Synchro ok !\n";	
	for $i (0 ..(length($string)-1)){
		my $task = undef;
		foreach my $ltask (@TaskList){
			$task = $ltask if($$ltask->{'NUM'} == $i );
		}
		print "$$task->{'NUM'} $i $task\n" if (defined($task));
		my $character = substr($string, $i, 1);
		print "$character\n";
		 if($character =~ /\s/){
		 	$character = "Blank";
		 }
		 else {
		 	$character = uc $character;
		 }
		# Affichage du caractère 
		$Hframe[$i] = $mw->new_ttk__frame();
		$photo[$i] = Tkx::image_create_photo( "image$i", -file => "Images/$character.gif");		
		$Hframe[$i]->new_ttk__label( -image => $photo[$i], -width => $widthLabel, -background => 'white', -anchor => 'w')->g_grid(-column => 0, -row => $i);
		$Hframe[$i]->g_grid(-column => 0, -row => $i);
		if (defined($task)){
			print "init stat stop button $$task->{'NUM'}\n";
			initStartStopButton($task);
		}
		if ($i == 0){
			$Hframe[$i]->new_ttk__label(-text  => "EXE : ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Stop", -width => 5)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Start", -width => 5)->g_grid(-column => 3, -row => $i);
			
		}
		elsif ($i == $JRE_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- JREP ---", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $C3M_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- C3M ---", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $SPY_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- SPYLINKS ---", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $CMD_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- Commands ---", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 3, -row => $i);
		}

		elsif ($i == $CMD_START_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Process :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startAll,
								-text => "Start All", -width => 10, );
			$startButton[$i]->g_grid(-column => 1, -row => $i);		
		}
		elsif ($i == $CMD_STATUS_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Process Status :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&updateStatus,
								-text => "Refresh", -width => 10,  );
			$startButton[$i]->g_grid(-column => 1, -row => $i);		
		}
		elsif ($i == $CMD_LOG_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Log :", -width => $widthLabel,  -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&saveLog,
								-text => "Save", -width => 10, );
			$startButton[$i]->g_grid(-column => 1, -row => $i);		
		}
		elsif ($i == $CMD_EXIT_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "JRE Stater :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&exitJREStarter,
								-text => "Exit", -width => 10, );
			$startButton[$i]->g_grid(-column => 1, -row => $i);		
		}
		else {
			#$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			#$stopButton[$i] = $Hframe[$i]->new_ttk__label(-image => "blankPhoto");
			#$stopButton[$i]->g_grid(-column => 1, -row => $i);
			#$startButton[$i] = $Hframe[$i]->new_ttk__label(-image => "blankPhoto");
			#$startButton[$i]->g_grid(-column => 1, -row => $i);
			
		}
		$i +=  1;
	}
	#$mw->geometry("-200+10");
	#$mw->update;		
	startAll();
	#my $timer1 = threads->create(\&timer, \&updateStatus, 10, 0);


	Tkx::MainLoop();
}

sub  initStartStopButton {
	my $task = shift;
	my $initialStartPhoto, my $initialStopPhoto;
	my $j = $$task->{'NUM'};

	my $exe = $$task->{'EXE'};
	$initialStartPhoto = "startPhoto";
	$initialStopPhoto = "stopInactivePhoto";	
	$Hframe[$j]->new_ttk__label(-text  => "$task : ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $j);
	$stopButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&stopProcess, $task],
								-image => $initialStopPhoto, -width => 5);
	$stopButton[$j]->g_grid(-column => 3, -row => $j);
	$startButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&startProcess, $task],
								-image => $initialStartPhoto);
	$startButton[$j]->g_grid(-column => 4, -row => $j);
}

sub startAll {
	foreach my $task (@TaskList){
		startProcess($task);
	} 	
}

sub timer {
my($subroutine, $interval, $max_iteration) = @_;
for (my $count = 1; $max_iteration == 0 || $count <= $max_iteration; 
$count++) {
sleep $interval;
&$subroutine;
}
}

	
sub startProcess {
	my $task = shift;
	my $image = $startButton[$$task->{'NUM'}]->cget('-image');
	print "$task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		startLynxProcess($$task->{'START'}) if($image eq "startInactivePhoto" && ! isLynxProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "Yes");
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		startSolarisProcess ($$task->{'START'}) if($image eq "startInactivePhoto" && ! isSolarisProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "Yes");
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($$task->{'START'}) if($image eq "startInactivePhoto" && ! isWindowsProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "Yes");
	}
}

sub stopProcess {
	my $task = shift;
	my $image = $stopButton[$$task->{'NUM'}]->cget('-image');
	print "$task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		stopLynxProcess($$task->{'STOP'}) if($image eq "stopInactivePhoto" && isLynxProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "Yes");
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		stopSolarisProcess ($$task->{'STOP'}) if($image eq "stopInactivePhoto" && isSolarisProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "Yes");
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($$task->{'Stop'}) if($image eq "stopInactivePhoto" && isWindowsProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "Yes");
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

sub updateStatusProcess {
	my $task = shift;
	if($$task->{'OPERATING_SYST'}eq "SOLARIS" && isSolarisProcessRunning($$task->{'EXE'})) {
		$stopButton[$DLIP->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIP->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIP->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$DLIP->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	if($$task->{'OPERATING_SYST'}eq "LYNX" && isLynxProcessRunning($$task->{'EXE'})) {
		$stopButton[$JREP_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$JREP_NUM]->configure(-image => 'stopPhoto');
		$startButton[$JREP_NUM]->configure(-image => 'startInactivePhoto');
	}
	if ($$task->{'OPERATING_SYST'}eq "WINDOWS" && isWindowsProcessRunning ($$task->{'EXE'})){
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLIPMng_NUM]->configure(-image => 'stopPhoto');
		$startButton[$DLIPMng_NUM]->configure(-image => 'startInactivePhoto');
	}
}	

sub saveLog {
	if(confirmAction("Save Log File ? It will stop all applications !")){
		updateStatusProcess;
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
			#system("rcp -b DLIP_C3M.dlip:$DLIP_C3M_LOG_DIR/*.log .");
			# retrieve DLIP log
			#print "pscp thales\@$putty_session:$DLIP_LOG_DIR/*.log $LOG_DIR\\$newDir\n";
			system("pscp thales\@$putty_session:$DLIP->{'LOG_DIR'}/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save DLIP log ?"));
			acquittementAction("That's all flok !");
			# retrieve JREP log
			#system("pscp thales\@$putty_session:$JREP_LOG_DIR/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save JREP log ?"));
			acquittementAction("That's all folk !");
			system("XCOPY /I \"$SPY_LOG_DIR\\*.rcd\" $LOG_DIR\\$newDir") if (confirmAction("Save Spylinks log ?"));
			
		}
	}
	if(confirmAction("Clear Log File ?")){
		startSolarisProcess($DLIP->{'CLEAR_LOG'});
		startSolarisProcess($JREP->{'CLEAR_LOG'});
		#system("DEL /Q \"$SPY_LOG_DIR\\*.rcd\"");
	}
}

sub exitJREStarter {

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
	my $process_list = `rsh 24.1.1.1 -l dlip  ps -ax`;
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
	
	return -1;
}
sub acquittementAction {
	
	return -1;
}


