#!/usr/bin/perl -w
# Lancement CWIX 2012 de façon graphique
# Augmentation de la tempo pour les process Windows
# Arrêt et redémarrage du Host TD avec le TDL router
# V3 le 12/12/2012
# Updae suppression Spylinks L16
# Démarrage auto des IHM associé au JREP et TDL
# Arrêt au démarrage du DLIP C3M
# Utilisation de répertoire standart pour les applis JREM DLIPCOM,...
# Mise à jour MAJOR du 6 fev 2013
#  par S. Mouchot

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use Net::Ping;
#use JreProcessorsConfiguration;
use DlipComOperationalConfiguration;

#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $HOME_DIR="/export/home/thales";
my $putty_session = "JRE-Gateway";
my $rack_Lynx_IP = "24.1.8.1";
my $rack_SUN_ETH_IP = "24.1.7.66";
my $jrepName;
my $synchro_lynx_ok = -1;
my $synchro_sun_ok = -1;
my $useMIDS = 1;
my $mids_db = "24.1.2.101";
my $mids_db_present = 0;
my $mids_db_connected = 0;
my $mids_status_label = "not present";
my $mids_num = 2;
my $firt_ping_mids = 0;
my $dlms_present = 0;
my $dlms_connected = 0;
my $dlms_ip = "24.1.8.31";
my $dlms_sun_ip = "24.1.8.66"; 
my $dlms_port = "2112";
my $dlms_status_label = "not present";
my $dlms_num = 3;
my $dli1_present = 0;
my $dli1_connected = 0;
my $dli1_ip = "24.1.6.30";
my $dli1_sun_ip = "24.1.6.66";
my $dli1_port = "2110";
my $dli1_status_label = "not Present";
my $dli1_num = 4;
my $dli2_present = 0;
my $dli2_connected = 0;
my $dli2_ip = "24.1.7.35";
my $dli2_sun_ip = "24.1.7.66";
my $dli2_port = "2111";
my $dli2_status_label = "not present";
my $dli2_num = 5;
my $systemInit =1;

my @TaskList = ( "DLIPCOM", "TDL_ROUTER", "TOPLINKSPY", "TMCT",);
my @solaris_process_list;
my @windows_process_list;

my $LOG_DIR = "E:\\LOG";

# ordre d'affichage des boutons
my $i = 7;
local $JRE_LABEL_NUM = $i;
$i++;
local $DLIPCOM_NUM= $i;
$i++;
local $TDL_ROUTER_NUM = $i;
$i++;
local $TOPLINKSPY_LABEL_NUM = $i;
$i++;
local $TOPLINKSPY_NUM = $i;
$i++;
local $TMCT_LABEL_NUM = $i;
$i++;
local $TMCT_NUM = $i;
$i++;
# Boutons config
my $CONFIG_LABEL_NUM = $i++;
my $CONFIG_ROUTE_ID = $i++;
# Boutons de commande
my $CMD_LABEL_NUM = $i;
$i++;
my $CMD_START_NUM = $i;
$i++;
my $CMD_LOG_NUM = $i;
$i++;
my $CMD_CLEAR_NUM = $i;
$i++;
my $CMD_EXIT_NUM = $i;

# Process Lynx

local $DLIP_C3M = {	'NUM'	=> 0, 
				'EXE' 		=> "./mct_main",
				'RUN_DIR' 	=> "/home1/dlip/Ops",
				'START' 	=> "rsh $rack_Lynx_IP -l dlip cd Ops;start",
				'STOP' 		=> "rsh $rack_Lynx_IP -l dlip cd Ops;stop",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "/home1/dlip/Ops",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "LYNX"
};

# Solaris Process

local $TDL_ROUTER = {	'NUM'		=> $TDL_ROUTER_NUM, 
				'EXE' 		=> "./tdl_router_main",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./start_TDL_ROUTER >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_TDL_ROUTER >& /dev/null &",
				'CMD' 		=> "cd $HOME_DIR/TDL_ROUTER; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./router_main >& /dev/null &",
				'LOG' 		=> "router_main.log",
				'LOG_DIR' 	=> "$HOME_DIR/TDL_ROUTER",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_TDL_ROUTER_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

local $HOST = {	'NUM'		=> $HOST_NUM, 
				'EXE' 		=> "./host_test_driver",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_HOST_TD 1 >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_HOST_TD >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "host_test_driver.log",
				'LOG_DIR' 	=> "$HOME_DIR/HOST_TD",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_HOST_TD_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

local $L16_TD = {	'NUM'		=> $L16_TD_NUM, 
				'EXE' 		=> "./l16_driver_test",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_L16_TD_TEST >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_L16_TD_TEST >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "l16_test_driver.log",
				'LOG_DIR' 	=> "$HOME_DIR/L16_TD_TEST",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_L16_TD_TEST_log",
				'OPERATING_SYST'	=> "SOLARIS"
};
# Process Windows

local $DLIPCOM = {	'NUM'		=> $DLIPCOM_NUM, 
				'EXE' 		=> "DLIPCOM.bat",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\DLIPCOM\\",
				'WIN_NAME'	=> "DLIP Communication Manager",
				'START' 	=> "DLIPCOM.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $TOPLINKSPY = {	'NUM'		=> $TOPLINKSPY_NUM, 
				'EXE' 		=> "TopLink-Spy.exe",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\TopLink\-Spy\\TopLink\-Spy",
				'WIN_NAME'	=> "TopLink\-Spy",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "C:\\Program\ Files\\THALES\\TopLink\-Spy\\TopLink-Spy\\Logs",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $AIS = {	'NUM'		=> $AIS_NUM, 
				'EXE' 		=> "AIS.exe",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\L16ES\\AIS\\",
				'WIN_NAME'	=> "AIS.exe",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $NPG = {	'NUM'		=> $NPG_NUM, 
				'EXE' 		=> "npg.bat",
				'RUN_DIR' 	=> "C:\\Program Files\\Npg\\bin\\",
				'WIN_NAME'	=> "npg.exe",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLTE_TDL = {	'NUM'		=> 0, 
				'EXE' 		=> "launch_dltes16_TDL.bat",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\DLTE_S16_TDL",
				'WIN_NAME'	=> "dlte_s16 TDL",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLTE_C3M = {	'NUM'		=> 0, 
				'EXE' 		=> "launch_dltes16_C3M.bat",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\DLTE_S16_C3M",
				'WIN_NAME'	=> "dlte_s16 C3M",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLTE_CONSOLE_TDL = {	'NUM'		=> 0, 
				'EXE' 		=> "javaw.exe",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\DLTE_S16_TDL",
				'WIN_NAME'	=> "Console de Traces du DLTE-S16 -Version 1.9.2- TDL",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLTE_CONSOLE_C3M = {	'NUM'		=> 0, 
				'EXE' 		=> "javaw.exe",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\DLTE_S16_C3M",
				'WIN_NAME'	=> "Console de Traces du DLTE-S16 -Version 1.9.2- C3M",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $TMCT = {	'NUM'		=> $TMCT_NUM, 
				'EXE' 		=> "tmct_monolithique_ss.exe",
				'RUN_DIR' 	=> "C:\\Program\ Files\\THALES\\TMCT\\bin\\",
				'WIN_NAME'	=> "tmct_mono",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

my $mw;
my	@startButton;
my	@stopButton;
my $widthLabel;
my $widthEntry;
my @Hframe;
my @photo;
my $startPhoto;
my $stopPhoto;
my $startInactivePhoto;
my $stopInactivePhoto;
my $blankPhoto;
my $voyant_Status_OK;
my $voyant_Status_warning;
my $voyant_Status_alarm;

# print $ENV{PWD};
if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}

if(! $opt_h) {
	$mw = Tkx::widget->new(".");
	$mw->g_wm_title( "FLORAKO Starter " );
		
	$widthLabel = 15;
	$widthEntry = 10;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	$voyant_Status_OK = Tkx::image_create_photo("status_OK", -file => "Images/Status_OK.gif");
	$voyant_Status_warning = Tkx::image_create_photo("status_warning", -file => "Images/Status_warning.gif");
	$voyant_Status_alarm = Tkx::image_create_photo("status_alarm", -file => "Images/Status_alarm.gif");
	# Affichage vertical fenêtre principale	
	my $string = " FLORAKO Starter       ";
	
	#waiting for SUN synchronization
	my $SUN_SYNCHRO_STATE = 0;
	my $LYNX_SYNCHRO_STATE = 0;
	while ( ! $SUN_SYNCHRO_STATE ){
		my $NTP_CMD = `plink $putty_session \"ntpq -p\"`;
		print "wait for SUN synchro...";
		$SUN_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*/ || $synchro_sun_ok);
		sleep 1;
	}
	print "SUN Synchro ok !\n";
	for my $i (0 ..(length($string)-1)){
		my $task = undef;
		foreach my $ltask (@TaskList){
			#print "$ltask\n";
			#print "$$ltask->{'NUM'} $i\n";
			$task = $ltask if( $$ltask->{'NUM'} == $i );
		}
		#print "$$task->{'NUM'} $i $task\n" if (defined($task));
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
		$Hframe[$i]->new_ttk__label( -image => $photo[$i], -width => $widthLabel, -anchor => 'w')->g_grid(-column => 0, -row => $i);
		$Hframe[$i]->g_grid(-column => 0, -row => $i, -sticky => 'w');
		if (defined($task)){
			#print "init start stop button $$task->{'NUM'}\n";
			initStartStopButton($task);
		}
		
		if ($i == 1){
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "-- Status --", -width => $widthLabel, -anchor => 'w')->g_grid(-column => 3, -row => $i);
		}
		if ($i == $mids_num){
			$Hframe[$i]->new_ttk__label(-text  => "MIDS Cnx :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__label( -image => $voyant_Status_alarm);
			$stopButton[$i]->g_grid(-column => 4, -row => $i);
			$stopLabel[$i] = $Hframe[$i]->new_ttk__entry( -text => \$mids_status_label, -width => $widthEntry);
			$stopLabel[$i]->g_grid(-column => 5, -row => $i, -padx => 5);
		}
		if ($i == $dlms_num){
			$Hframe[$i]->new_ttk__label(-text  => "DLMS Cnx :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__label( -image => $voyant_Status_alarm);
			$stopButton[$i]->g_grid(-column => 4, -row => $i);
			$stopLabel[$i] = $Hframe[$i]->new_ttk__entry( -text => \$dlms_status_label, -width => $widthEntry);
			$stopLabel[$i]->g_grid(-column => 5, -row => $i, -padx => 5);
		}
		if ($i == $dli1_num){
			$Hframe[$i]->new_ttk__label(-text  => "DLI_1 Cnx :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__label( -image => $voyant_Status_alarm);
			$stopButton[$i]->g_grid(-column => 4, -row => $i);
			$stopLabel[$i] = $Hframe[$i]->new_ttk__entry( -text => \$dli1_status_label, -width => $widthEntry);
			$stopLabel[$i]->g_grid(-column => 5, -row => $i, -padx => 5);
		}
		if ($i == $dli2_num){
			$Hframe[$i]->new_ttk__label(-text  => "DLI_2 Cnx :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__label( -image => $voyant_Status_alarm);
			$stopButton[$i]->g_grid(-column => 4, -row => $i);
			$stopLabel[$i] = $Hframe[$i]->new_ttk__entry( -text => \$dli2_status_label, -width => $widthEntry);
			$stopLabel[$i]->g_grid(-column => 5, -row => $i, -padx => 5);
		}	
		if ($i == 6){
			$Hframe[$i]->new_ttk__label(-text  => "EXE : ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Stop", -width => 5)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Start", -width => 5)->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $JRE_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- LTM ---", -width => 10)->g_grid(-column => 3, -row => $i);

		}
		elsif ($i == $TMCT_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- TMCT ---", -width => 10)->g_grid(-column => 3, -row => $i);

		}
		elsif ($i == $TOPLINKSPY_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- TOPLINKSPY ---", -width => 12)->g_grid(-column => 3, -row => $i);

		}
		if ($i == $CONFIG_LABEL_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "-- Configuration --", -width => $widthLabel, -anchor => 'w')->g_grid(-column => 3, -row => $i);
		}
		if ($i == $CONFIG_ROUTE_ID){
			$Hframe[$i]->new_ttk__label(-text  => "Routes ID :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&routeConfig ,	-text => "Config", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $CMD_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- Commands ---", -width => $widthLabel, -anchor => 'w')->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $CMD_START_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Process :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&restartAll,
								-text => "Restart All", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		elsif ($i == $CMD_LOG_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Log :", -width => $widthLabel,  -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&saveLog,
								-text => "Save", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		elsif ($i == $CMD_CLEAR_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Log :", -width => $widthLabel,  -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&clearLog,
								-text => "Clear", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		elsif ($i == $CMD_EXIT_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "JRE Stater :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&exitJREStarter,
								-text => "Exit", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		$i +=  1;
	}
	$mw->g_wm_geometry("+10+10");
	updateStatusAll();
	timer(1000);
	Tkx::MainLoop();
}

sub  initStartStopButton {
	my $task = shift;
	my $initialStartPhoto, my $initialStopPhoto;
	my $j = $$task->{'NUM'};
	#print "bouton $j $task\n";

	my $exe = $$task->{'EXE'};
	$initialStartPhoto = "startInactivePhoto";
	$initialStopPhoto = "stopPhoto";	
	$Hframe[$j]->new_ttk__label(-text  => "$task : ", -width => $widthLabel,-anchor => 'e')->g_grid(-column => 2, -row => $j, -sticky => 'w');
	$stopButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&stopProcess, $task],
								-image => $initialStopPhoto);
	#$stopButton[$j]->configure( -borderwidth => 15);
	$stopButton[$j]->g_grid(-column => 3, -row => $j, -sticky => 'w');
	$startButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&startProcess, $task],
								-image => $initialStartPhoto);
	$startButton[$j]->g_grid(-column => 4, -row => $j, -sticky => 'w');
}

sub startContextBuilder{
	startWindowsProcess("CONTEXTBUILDER") if(confirmAction ("Build JRE Context ?") eq "yes");
}

sub restartAll {
	if(confirmAction ("Start All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			if(($task ne "JREM") && ($task ne "DLIPCOM") && ($task ne "DLIPMNG")){
				stopProcess($task);
			}
		}
		foreach my $task (@TaskList){
			startProcess($task);
		}
	}	
}

sub restartAllWithoutConfirmation {
	foreach my $task (@TaskList){
		if(($task eq "TDL_ROUTER") || ($task eq "DLIPCOM")){
			stopProcessWithoutConfirmation($task);
		}
		startProcessWithoutConfirmation($task);
	}
}

sub stopAll {
	if(confirmAction ("Stop All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			stopProcess($task);
		}
	}	
}

sub stopAllWithoutConfirmation {
	foreach my $task (@TaskList){
		stopProcessWithoutConfirmation($task);
	}	
}

sub updateStatusAll {
	updateStatusMIDS();
	updateStatusDLMS();
	updateStatusDLI1();
	updateStatusDLI2();
	updateWindowsProcessList();
	updateSolarisProcessList();
	foreach my $task (@TaskList){
		updateStatusProcess($task);
	}
}
	
sub startProcess {
	my $task = shift;
	print "start $task\n";
	my $image = $startButton[$$task->{'NUM'}]->cget('-image');
	#print "$$task->{'OPERATING_SYST'}\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "startInactivePhoto" && ! isLynxProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes") {
			startLynxProcess($task);
		}
	}	
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if($image eq "startInactivePhoto" && ! isSolarisProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){
			startSolarisProcess ($task); 
			sleep 1;
			if($task eq "TDL_ROUTER"){
				stopSolarisProcess("HOST");
				startSolarisProcess("HOST");
				#startProcess("DLIPCOM");
			}
			if($task eq "JREP"){
				#startProcess("JREM");
			}
			if($task eq "DLIP"){
				#startProcess("DLIPMNG");
			}
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($task) if($image eq "startInactivePhoto" && ! isWindowsProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes");
		if($task eq "DLIPMNG"){
			startProcess("DLIP");
			startProcess("JREP_STL");
		}
		if($task eq "DLIPCOM"){
			#startProcess("TDL_ROUTER");
		}
		if($task eq "JREM"){
			startProcess("JREP");
		}
		sleep 15 if($task eq "JREM" || $task eq "OSIM" || $task eq "TOPLINKSPY");
		updateSolarisProcessList();
	}
	updateStatusProcess ($task);
	#updateStatusMIDS();
}

sub startProcessWithoutConfirmation {
	my $task = shift;
	print "start $task\n";
	my $image = $startButton[$$task->{'NUM'}]->cget('-image');
	#print "$$task->{'OPERATING_SYST'}\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "startInactivePhoto" && ! isLynxProcessRunning ($task)) {
			startLynxProcess($task);
		}
	}	
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if($image eq "startInactivePhoto" && ! isSolarisProcessRunning ($task)){
			startSolarisProcess ($task); 
			sleep 1;
			if($task eq "TDL_ROUTER"){
				stopSolarisProcess("HOST");
				startSolarisProcess("HOST");
				#startProcess("DLIPCOM");
			}
			if($task eq "JREP"){
				#startProcess("JREM");
			}
			if($task eq "DLIP"){
				#startProcess("DLIPMNG");
			}
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($task) if($image eq "startInactivePhoto" && ! isWindowsProcessRunning ($task));
		if($task eq "DLIPMNG"){
			startProcessWithoutConfirmation("DLIP");
			startProcessWithoutConfirmation("JREP_STL");
		}
		if($task eq "DLIPCOM"){
			#startProcessWithoutConfirmation("TDL_ROUTER");
		}
		if($task eq "JREM"){
			startProcessWithoutConfirmation("JREP");
		}
		sleep 15 if($task eq "JREM" || $task eq "OSIM" || $task eq "TOPLINKSPY");
		updateSolarisProcessList();
	}
	updateStatusProcess ($task);
	#updateStatusMIDS();
}

sub stopProcess {
	my $task = shift;
	my $image = $stopButton[$$task->{'NUM'}]->cget('-image');
	print "stop $task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "stopInactivePhoto" && isLynxProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			stopLynxProcess($task);
		}
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		stopSolarisProcess ($task) if($image eq "stopInactivePhoto" && isSolarisProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes");
		if($task eq "TDL_ROUTER"){
			stopSolarisProcess("HOST");
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){	
		stopWindowsProcess($task) if($image eq "stopInactivePhoto" && isWindowsProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes");
		sleep 1;
		updateWindowsProcessList();
	}
	print " update $task\n";
	updateStatusProcess($task) ;
	updateStatusMIDS();
}

sub stopProcessWithoutConfirmation {
	my $task = shift;
	my $image = $stopButton[$$task->{'NUM'}]->cget('-image');
	print "stop $task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "stopInactivePhoto" && isLynxProcessRunning ($task)){
			stopLynxProcess($task);
		}
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		stopSolarisProcess ($task) if($image eq "stopInactivePhoto" && isSolarisProcessRunning ($task));
		if($task eq "TDL_ROUTER"){
			stopSolarisProcess("HOST");
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		
		stopWindowsProcess($task) if($image eq "stopInactivePhoto" && isWindowsProcessRunning ($task));	
		sleep 1;
		updateWindowsProcessList();
	}
	print " update $task\n";
	updateStatusProcess($task);
	#updateStatusMIDS();
}

sub updateStatusProcess {
	my $task = shift;
	if($$task->{'OPERATING_SYST'}eq "SOLARIS" ) {
		if ( isSolarisProcessRunning($task)) {
				$stopButton[$$task->{'NUM'}]->configure(-image => 'stopInactivePhoto');
				$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
		}
		else {
			$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
			$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
		}
	}
	if($$task->{'OPERATING_SYST'}eq "LYNX") {
		if ( isLynxProcessRunning($task)) {
				$stopButton[$$task->{'NUM'}]->configure(-image => 'stopInactivePhoto');
				$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
		}
		else {
				$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
				$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
		}
	}	
	if ($$task->{'OPERATING_SYST'}eq "WINDOWS" ) {
		if ( isWindowsProcessRunning ($task)){
			$stopButton[$$task->{'NUM'}]->configure(-image => 'stopInactivePhoto');
			$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
		}
		else {
			$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
			$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
		}
	}
}	

sub saveLog {
	if(confirmAction("Save Log File ? stop all applications first !")){
		my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
		$year += 1900; $mon += 1;
		$mon = "0".$mon if($mon <10);
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
			chdir($newDir);
			print "create dir\n";
			my $log_dir = $TDL_ROUTER->{"LOG_DIR"};
			#print "pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir\n";
			system("pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir") if ( confirmAction("Save TDL log ?"));
			$log_dir = $HOST->{"LOG_DIR"};
			#print "pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir\n";
			 if ( confirmAction("Save TDL log ?")){
				system("pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir");
				system("pscp thales\@$putty_session:$log_dir\/\*.xdh $LOG_DIR\\$newDir");
				$log_dir = $L16_TD->{"LOG_DIR"};
				#print "pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir\n";
				system("pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir");
				system("pscp thales\@$putty_session:$log_dir\/\*.fim $LOG_DIR\\$newDir");
			}			
			acquittementAction("That's all flok !");
			# retrieve JREP log
			#my $JREP_dir = $JREP->{"LOG_DIR"};
			#system("pscp thales\@$putty_session:$JREP_dir/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save JREP log ?"));
			#acquittementAction("That's all folk !");
			#system("XCOPY /I \"$SPYLINKS_LOG_DIR\\*.rcd\" $LOG_DIR\\$newDir") if (confirmAction("Save Spylinks log ?"));
			
		}
	}
}

sub clearLog{
	$clear_cmd = $TDL_ROUTER->{'CLEAR_LOG'};
	if(confirmAction("Clear TDL router Log File ?")){
		system("plink $putty_session $clear_cmd") ;
		$clear_cmd = $HOST->{'CLEAR_LOG'};
		system("plink $putty_session $clear_cmd");
		$clear_cmd = $L16_TD->{'CLEAR_LOG'};
		system("plink $putty_session $clear_cmd");
	}
	#$clear_cmd = $JREP->{'CLEAR_LOG'};
	#system("plink $putty_session $clear_cmd") if(confirmAction("Clear JRE Log File ?"));
	#acquittementAction("That's all folk !");
}

sub exitJREStarter {
	stopAll();
	saveLog();
	clearLog();
	$mw->g_destroy();
}

sub updateSolarisProcessList{
	my $process_list = `plink $putty_session ps -df`;
	(@solaris_process_list) = split("\n", $process_list);
	return 0;
}

sub isSolarisProcessRunning {
	my $task = shift;
	my $process_name = $$task->{'EXE'};
	my $PID = 0;
	#print "process : $process_name\n";
	foreach my $current_process (@solaris_process_list){
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
	my $task = shift;
	my $process_cmd = $$task->{'START'};
	print "$process_cmd\n";
	return system ("plink $putty_session \"$process_cmd\"");
}

sub stopSolarisProcess {
	my $task = shift;
	my $process_cmd = $$task->{'STOP'};
	return system ("plink $putty_session \"$process_cmd\"");
}

sub isLynxProcessRunning {
	my $task = shift;
	my $process_name = $$task->{'EXE'};
	my $PID = 0;
	print "process : $process_name\n";
	my $process_list = `rsh $rack_Lynx_IP -l dlip  ps -ax`;
	(my @process_list) = split("\n", $process_list);
	foreach my $current_process (@process_list){
		#print "$current_process\n";
		if ($current_process =~/$process_name/){
			print "here it is !\n";
			(my @PID) = split(" ", $current_process);
			$PID = $PID[0];
			print "$PID\n";
			last;
		}
	}
	return $PID;
}

sub startLynxProcess {
	my $task = shift;
	my $process_cmd = $$task->{'START'};
	print "$process_cmd\n";
	return system("$process_cmd");
	}
	
sub stopLynxProcess {
	my $task = shift;
	#my $PID_process = isLynxProcessRunning($task);
	my $stop_cmd = $$task->{'STOP'};
	print "$stop_cmd\n";
	return system("$stop_cmd");
	}

sub updateWindowsProcessList {
	my $process_list = `tasklist.exe \/V`;
	(@windows_process_list) = split("\n", $process_list);
	return 0;
}

sub isWindowsProcessRunning {
	my $task = shift;
	my $process_name = $$task->{'WIN_NAME'};
	my $PID = 0;
	print "process : $process_name\n";
	foreach my $current_process (@windows_process_list){
		#print "$current_process\n";
		if ($current_process =~ /$process_name/){
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
	my $task = shift;
	my $process_cmd = $$task->{'EXE'};
	my $process_run_dir = $$task->{'RUN_DIR'};
	my $process_win_name = $$task->{'WIN_NAME'};
	#print "$process_cmd\n";
	print" cd \"$process_run_dir\" && start /B /MIN	\"$process_win_name\" $process_cmd ";
	#system("cd \"$process_run_dir\" && start /B /MIN	\"$process_win_name\" $process_cmd ");
	return system("start /D \"$process_run_dir\"  /MIN	\"$process_win_name\" $process_cmd ");
}

sub stopWindowsProcess {
	my $task = shift;
	my $PID_process = isWindowsProcessRunning($task);
	#print "$process, $process_run_dir\n";
	return system("taskkill /PID $PID_process /T /F") if($PID_process);
}

sub updateStatusMIDS {
	isMIDSPresent();
	isMIDSConnected();
	if( !$systemInit){
		if($mids_db_present ){
			if($mids_db_connected ) {
				$stopButton[2]->configure(-image => 'status_OK');
				$mids_status_label = "Connected";
			}
			else { 
				$stopButton[2]->configure(-image => 'status_warning');
				$mids_status_label = "Present";
			}
			if(! $first_ping_mids) {
				$first_ping_mids = 1;
				restartAllWithoutConfirmation();
			}
		}
		else{
			$stopButton[2]->configure(-image => 'status_alarm');
			$mids_status_label = "not Present";
			stopProcessWithoutConfirmation("TDL_ROUTER");
			stopProcessWithoutConfirmation("DLIPCOM");
			$first_ping_mids = 0;
		}
		print "update mids_db_present = $mids_db_present \n";
		print "update first_ping_mids = $first_ping_mids \n";
	}
	else {
		$systemInit = 0;
		if($mids_db_present ){
			if($mids_db_connected ) {
				$stopButton[2]->configure(-image => 'status_OK');
				$first_ping_mids = 1;
				$mids_status_label = "Connected";
			}
			else { 
				$stopButton[2]->configure(-image => 'status_warning');
				$mids_status_label = "Present";
			}
		}
		else{
			$stopButton[2]->configure(-image => 'status_alarm');
			$mids_status_label = "not Present";
		}
		print "update mids_db_present = $mids_db_present \n";
		print "update first_ping_mids = $first_ping_mids \n";
	}
	return 0;
}

sub updateStatusDLMS {
	isDLMSPresent();
	isDLMSConnected();
	if($dlms_present ){
		if($dlms_connected ) {
			$stopButton[$dlms_num]->configure(-image => 'status_OK');
			$dlms_status_label = "Connected";
		}
		else { 
			$stopButton[$dlms_num]->configure(-image => 'status_warning');
			$dlms_status_label = "Present";
		}
	}
	else{
		$stopButton[$dlms_num]->configure(-image => 'status_alarm');
		$dlms_status_label = "not Present";
	}
}

sub updateStatusDLI1 {
	isDLI1Present();
	isDLI1Connected();
	if($dli1_present ){
		if($dli1_connected ) {
			$stopButton[$dli1_num]->configure(-image => 'status_OK');
			$dli1_status_label = "Connected";
		}
		else { 
			$stopButton[$dli1_num]->configure(-image => 'status_warning');
			$dli1_status_label = "Present";
		}
	}
	else{
		$stopButton[$dli1_num]->configure(-image => 'status_alarm');
		$dli1_status_label = "not Present";
	}
}

sub updateStatusDLI2 {
	isDLI2Present();
	isDLI2Connected();
	if($dli2_present ){
		if($dli2_connected ) {
			$stopButton[$dli2_num]->configure(-image => 'status_OK');
			$dli2_status_label = "Connected";
		}
		else { 
			$stopButton[$dli2_num]->configure(-image => 'status_warning');
			$dli2_status_label = "Present";
		}
	}
	else{
		$stopButton[$dli2_num]->configure(-image => 'status_alarm');
		$dli2_status_label = "not Present";
	}
}

sub isMIDSPresent{
	$mids_db_present = 0;
	print "Wait for MIDS ping response ...\n";
	my $result = `plink $putty_session \"ping $mids_db 1\"`;
	$mids_db_present = 1 if( $result =~ /alive/);	
	print "$result : $mids_db_present\n";
	return 	$mids_db_present;
}

sub isMIDSConnected {
	$mids_db_connected = 0;
	my $result = `plink $putty_session \"netstat -a | grep MIDS_DB.1024 \"`;
	$mids_db_connected = 1 if($result =~ /ESTABLISHED/);
	print "$result : $mids_db_connected\n";
	return $mids_db_connected;
}

sub isDLMSPresent{
	$dlms_present = 0;
	print "Wait for DLMS ping response ...\n";
	my $result = `plink $putty_session \"ping $dlms_ip 1\"`;
	$dlms_present = 1 if( $result =~ /alive/);	
	print "$result : $dlms_present\n";
	return 	$dlms_present;
}

sub isDLMSConnected {
	$dlms_connected = 0;
	print "netstat -a | grep $dlms_sun_ip.$dlms_port ";
	my $result = `plink $putty_session \"netstat -a | grep $dlms_sun_ip.$dlms_port \"`;
	$dlms_connected = 1 if($result =~ /ESTABLISHED/);
	print "$result : $dlms_connected\n";
	return $dlms_connected;
}

sub isDLI1Present{
	$dli1_present = 0;
	print "Wait for DLI1 ping response ...\n";
	my $result = `plink $putty_session \"ping $dli1_ip 1\"`;
	$dli1_present = 1 if( $result =~ /alive/);	
	print "$result : $dli1_present\n";
	return 	$dli1_present;
}

sub isDLI1Connected {
	$dli1_connected = 0;
	my $result = `plink $putty_session \"netstat -a | grep $dli1_sun_ip.$dli1_port \"`;
	$dli1_connected = 1 if($result =~ /ESTABLISHED/);
	print "$result : $dli1_connected\n";
	return $dli1_connected;
}

sub isDLI2Present{
	$dli2_present = 0;
	print "Wait for DLI2 ping response ...\n";
	my $result = `plink $putty_session \"ping $dli2_ip 1\"`;
	$dli2_present = 1 if( $result =~ /alive/);	
	print "$result : $dli2_present\n";
	return 	$dli2_present;
}

sub isDLI2Connected {
	$dli2_connected = 0;
	my $result = `plink $putty_session \"netstat -a | grep $dli2_sun_ip.$dli2_port \"`;
	$dli2_connected = 1 if($result =~ /ESTABLISHED/);
	print "$result : $dli2_connected\n";
	return $dli2_connected;
}

sub isMIDSPresent2 {
	 my $p = Net::Ping->new();
     if ($p->ping($mids_db)){
     	$mids_db_present = 1 ;
     }
     else{
     	$mids_db_present = 0;
     }
	 #print "is mids_db_present = $mids_db_present \n";
     $p->close();
}

sub confirmAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Confirmation",
             -message => $text,
             -type => 'yesno'
           );
    #print "response = $reponse";
	return $reponse;
}

sub acquittementAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Acquittement",
             -message => $text,
             -type => 'ok'
           );
    #print "response = $reponse";
	return $reponse;
}

sub routeConfig{
 	DlipComOperationalConfiguration::new($mw);
 	
}

sub timer {
	my $interval = shift;
	repeat ($interval, sub { updateStatusAll()});
}

 sub repeat{
      my $ms  = shift;
      my $sub = shift;
      #print "$ms, $sub\n";
      my $repeater; # repeat wrapper
      $repeater = sub { $sub->(@_); Tkx::after($ms, $repeater);};
      my $repeat_id=Tkx::after($ms, $repeater);
      return $repeat_id;
 }