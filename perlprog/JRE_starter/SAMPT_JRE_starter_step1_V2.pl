#!/usr/bin/perl -w
# Lancement SAMPT JRE de façon graphique
# Augmentation de la tempo pour les process Windows
# Arrêt et redémarrage du Host TD avec le TDL router
# V3 le 20/1/2013
# Updae suppression Spylinks L16
# Démarrage auto des IHM associé au JREP et TDL
# Arrêt au démarrage du DLIP C3M
# Utilisation de répertoire standart pour les applis JREM DLIPCOM,...
# Step 2 : ajout de la supervisio du JREP Name
# ajout de la configuration des tag des routes pour le DLIPCOM
#  par S. Mouchot

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use JreProcessorsConfiguration;
use DlipComOperationalConfiguration;
#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $HOME_DIR="/export/home/thales";
my $putty_session = "JRE-Gateway";

my $rack_Lynx_IP = "24.1.1.1";
my $jrepName;

my $synchro_lynx_ok = 1;
my $synchro_sun_ok = 0;
my @TaskList = ("TDL_ROUTER", "DLIPCOM",  
				"JREP", "JREM", "TOPLINKSPY" , "TMCT");
my @solaris_process_list;
my @windows_process_list;

my $LOG_DIR = "D:\\LOG";
# ordre d'affichage des boutons

my $i = 3;
my $JRE_LABEL_NUM = $i;
$i++;
my $TDL_ROUTER_NUM = $i;
$i++;
my $DLIPCOM_NUM= $i;
$i++;
my $JREP_NUM = $i;
$i++;
my $JREM_NUM = $i;
$i++;
my $TOPLINKSPY_LABEL_NUM = $i;
$i++;
my $TOPLINKSPY_NUM = $i;
$i++;
my $TMCT_LABEL_NUM = $i;
$i++;
my $TMCT_NUM = $i;
$i++;
my $HOST_NUM = $i;
$i++;
# Boutons de commande
my $CMD_LABEL_NUM = $i;
$i++;
my $CMD_CONTEXT_NUM = $i;
$i++;
my $CMD_START_NUM = $i;
$i++;
#my $CMD_STATUS_NUM = $i;
#$i++;
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
				'CMD' 		=> "cd $HOME_DIR/TDL_ROUTER; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./tdl_router_main >& /dev/null &",
				'LOG' 		=> "tdl_router_main.log",
				'LOG_DIR' 	=> "$HOME_DIR/TDL_ROUTER",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_TDL_ROUTER_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

local $JREP = {	'NUM'		=> $JREP_NUM, 
				'EXE' 		=> "./jre_main",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ulimit -s unlimited; export TZ=GMT; ./start_JREP >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_JREP >& /dev/null &",
				'CMD' 		=> "cd $HOME_DIR/Scripts; ulimit -s unlimited; export TZ=GMT; ./jre_main >& /dev/null &",
				'LOG' 		=> "jre.log",
				'LOG_DIR' 	=> "$HOME_DIR/JREP/trace",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_JREP_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

local $HOST = {	'NUM'		=> $HOST_NUM, 
				'EXE' 		=> "./host_test_driver",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_HOST_TD 0 >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_HOST_TD >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "host_driver_test.log",
				'LOG_DIR' 	=> "$HOME_DIR/HOST_TD",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_HOST_TD_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

# Process Windows

local $DLIPMng = {	'NUM'		=> $DLIPMng_NUM, 
				'EXE' 		=> "launcher.bat",
				'RUN_DIR' 	=> "D:\\THALES\\DLIPmng_V1R1E5_NAWAS\\DLIPL16Mng-Delivery\\",
				'WIN_NAME'	=> "DLIP L16 Mng",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $JREM = {	'NUM'		=> $JREM_NUM, 
				'EXE' 		=> "launch.bat",
				'RUN_DIR' 	=> "D:\\THALES\\JREM\\bin",
				'WIN_NAME'	=> "JRE Management",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLIPCOM = {	'NUM'		=> $DLIPCOM_NUM, 
				'EXE' 		=> "DLIPCOM.bat",
				'RUN_DIR' 	=> "D:\\THALES\\DLIPCOM\\",
				'WIN_NAME'	=> "DLIP Communication Manager",
				'START' 	=> "DLIPCOM.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $CONTEXTBUILDER = {	'NUM'		=> 0, 
				'EXE' 		=> "ContextFileBuilder.bat",
				'RUN_DIR' 	=> "D:\\THALES\\ContextFileBuilder\\",
				'WIN_NAME'	=> "ContextFileBuilder",
				'START' 	=> "ContextFileBuilder.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $TOPLINKSPY = {	'NUM'		=> $TOPLINKSPY_NUM, 
				'EXE' 		=> "TopLink-Spy.exe",

				'RUN_DIR' 	=> "D:\\THALES\\TOPLINKSPY\\TopLink\-Spy",
				'WIN_NAME'	=> "TopLink\-Spy",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "E:\\THALES\\TOPLINKSPY\\TopLink-Spy\\Logs",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};


local $DLTE_TDL = {	'NUM'		=> 0, 
				'EXE' 		=> "launch_dltes16_TDL.bat",
				'RUN_DIR' 	=> "D:\\THALES\\DLTE_S16_TDL",
				'WIN_NAME'	=> "dlte_s16 TDL",
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
				'RUN_DIR' 	=> "D:\\THALES\\DLTE_S16_TDL",
				'WIN_NAME'	=> "Console de Traces du DLTE-S16 -Version 1.9.2- TDL",
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
				'RUN_DIR' 	=> "D:\\THALES\\TMCT\\bin\\",
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
my @Hframe;
my @photo;
my $startPhoto;
my $stopPhoto;
my $startInactivePhoto;
my $stopInactivePhoto;
my $blankPhoto;	

# print $ENV{PWD};
if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}

if(! $opt_h) {

	my $ref = JreProcessorsConfiguration::readConfigFile();
	print "$ref\n";
	$jrepName = JreProcessorsConfiguration::getJrepName();
	$mw = Tkx::widget->new(".");
	#Titre de la fenêtre principale
	$mw->g_wm_title( "SAMPT : MINT L16 JRE  Starter step1" );
		
	$widthLabel = 15;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	# Affichage vertical fenêtre principale
	my $string = " MINT L16 JRE Starter ";
	
	#waiting for SUN synchronization
	my $SUN_SYNCHRO_STATE = 0;
	my $LYNX_SYNCHRO_STATE = 0;

	# Verif synchro DLIP
	while ( ! $LYNX_SYNCHRO_STATE){
		my $NTP_CMD = `rsh $rack_Lynx_IP -l dlip \"ntpq -p\"`;
		print "$NTP_CMD \n wait for Lynx synchro...";
		$LYNX_SYNCHRO_STATE = 1 if ($NTP_CMD =~ /\*/ || $synchro_lynx_ok);
		sleep 1;
	}
	print "Lynx Synchro ok !\n";
	while ( ! $SUN_SYNCHRO_STATE){
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
		if ($i == 0){
			$Hframe[$i]->new_ttk__label(-text  => "-- Configuration ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
		}
		if ($i == 1){
			$Hframe[$i]->new_ttk__label(-text =>"JREP Name :",-anchor => 'e', -width => 15)->g_grid(-column => 2, -row => $i);
 			$Hframe[$i]->new_ttk__entry(-text => \$jrepName, -state => 'readonly', -width => 12)->g_grid(-column => 3, -row => $i);
		}
		if ($i == 2){
			$Hframe[$i]->new_ttk__label(-text  => "Routes ID :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&routeConfig ,
								-text => "Config", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);
		}
		if ($i == 3){
			$Hframe[$i]->new_ttk__label(-text  => "-- Executtion : ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Stop", -width => 5)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "Start", -width => 5)->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $JRE_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- JREP ---", -width => 10)->g_grid(-column => 3, -row => $i);

		}
		elsif ($i == $TMCT_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- TMCT ---", -width => 10)->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $TOPLINKSPY_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel)->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text => "--- SPYLINKS ---", -width => 12)->g_grid(-column => 3, -row => $i);

		}
		elsif ($i == $CMD_LABEL_NUM) {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 2, -row => $i);
			$Hframe[$i]->new_ttk__label(-text  => "--- Commands ---", -width => $widthLabel, -anchor => 'w')->g_grid(-column => 3, -row => $i);
		}
		elsif ($i == $CMD_CONTEXT_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "JRE Context :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startContextBuilder ,
								-text => "Build", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		elsif ($i == $CMD_START_NUM){
			$Hframe[$i]->new_ttk__label(-text  => "Process :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startAll,
								-text => "Start All", -width => 10, );
			$startButton[$i]->g_grid(-column => 3, -row => $i);		
		}
		#elsif ($i == $CMD_STATUS_NUM){
		#	$Hframe[$i]->new_ttk__label(-text  => "Process Status :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
		#	$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&updateAll,
		#						-text => "Refresh", -width => 10,  );
		#	$startButton[$i]->g_grid(-column => 3, -row => $i);		
		#}
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
	$jrepName = JreProcessorsConfiguration::getJrepName();
	print "$jrepName\n";
	$mw->g_wm_geometry("+10+10");
	updateStatusAll();
	timer(5000);
	startAll();
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

sub startAll {
	if(confirmAction ("Start All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			startProcess($task);
		}
	}	
}

sub stopAll {
	if(confirmAction ("Stop All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			stopProcess($task);
		}
	}	
}

sub updateStatusAll {
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
	print "$$task->{'OPERATING_SYST'}\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "startInactivePhoto" && ! isLynxProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes") {
			startLynxProcess($task);		
		}
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if($image eq "startInactivePhoto" && ! isSolarisProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){
			startSolarisProcess ($task); 
			if($task eq "TDL_ROUTER"){
				startWindowsProcess ("DLTE_TDL") if( ! isWindowsProcessRunning ("DLTE_TDL"));
				stopSolarisProcess("HOST");
				startSolarisProcess("HOST");
				#startProcess("DLIPCOM");
			}
			if($task eq "JREP"){
				#startProcess("JREM");
			}
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		#startWindowsProcess ("CONTEXTBUILDER")  if($task eq "DLIPCOM" && confirmAction("Update context file ?") eq "yes");
		#startWindowsProcess ("DATASERVER") if($task eq "SPYLINKS" && ! isWindowsProcessRunning("DATASERVER"));
		#startWindowsProcess("DLVM") if($task eq "SPYLINKS" && ! isWindowsProcessRunning("DLVM"));
		startWindowsProcess($task) if($image eq "startInactivePhoto" && ! isWindowsProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes");
		sleep 10 if($task eq "JREM" || $task eq "OSIM" || $task eq "TOPLINKSPY");
		updateSolarisProcessList();
	}
	updateStatusProcess ($task);
}

sub stopProcess {
	my $task = shift;
	my $image = $stopButton[$$task->{'NUM'}]->cget('-image');
	print "stop $task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		print "Lynx process ...\n";
		if($image eq "stopInactivePhoto" && isLynxProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			stopLynxProcess($task);
			#stopWindowsProcess("DLTE_C3M");
			#stopWindowsProcess("DLTE_CONSOLE_C3M");
		}
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if($image eq "stopInactivePhoto" && isSolarisProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			stopSolarisProcess ($task) ;
			if($task eq "TDL_ROUTER"){
				stopSolarisProcess("HOST");
				stopWindowsProcess("DLTE_TDL");
				stopWindowsProcess("DLTE_CONSOLE_TDL");
				#stopProcess("DLIPCOM");
			}
			if($task eq "JREP"){
				#stopProcess("JREM");
			}
		}
		updateSolarisProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		if($image eq "stopInactivePhoto" && isWindowsProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			if($task eq "OSIM"){
				stopWindowsProcess ("MAPPOINT");
			}
			if($task eq "SPYLINKS_L16"){
				stopWindowsProcess("DLVM");
				stopWindowsProcess("DATASERVER");
			}
			stopWindowsProcess($task);
		}
		sleep 1;
		updateWindowsProcessList();
	}
	print " update $task\n";
	updateStatusProcess($task) ;
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
	if(confirmAction("Save Log File ? It will stop all applications !")){
		stopAll();
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
			#my $C3M_dir = $DLIP_C3M->{"LOG_DIR"};
			#system("rcp -b DLIP_C3M.dlip:$C3M_dir\/\*.log .") if ( confirmAction("Save C3M log ?"));
			# retrieve DLIP log
			my $TDL_dir = $TDL_ROUTER->{"LOG_DIR"};
			#print "pscp thales\@$putty_session:$TDL_dir\/\*.log $LOG_DIR\\$newDir\n";
			system("pscp thales\@$putty_session:$TDL_dir\/\*.log $LOG_DIR\\$newDir") if ( confirmAction("Save DLIP log ?"));
			acquittementAction("That's all flok !");
			# retrieve JREP log
			my $JREP_dir = $JREP->{"LOG_DIR"};
			system("pscp thales\@$putty_session:$JREP_dir/*.log $LOG_DIR\\$newDir") if ( confirmAction("Save JREP log ?"));
			acquittementAction("That's all folk !");
			#system("XCOPY /I \"$SPYLINKS_LOG_DIR\\*.rcd\" $LOG_DIR\\$newDir") if (confirmAction("Save Spylinks log ?"));
			
		}
	}
}
sub clearLog{
	my $clear_cmd = $TDL_ROUTER->{'CLEAR_LOG'};
	system("plink $putty_session $clear_cmd") if(confirmAction("Clear TDL router Log File ?"));
	$clear_cmd = $JREP->{'CLEAR_LOG'};
	system("plink $putty_session $clear_cmd") if(confirmAction("Clear JRE Log File ?"));
	acquittementAction("That's all folk !");
}

sub exitJREStarter {
	stopAll();
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
			$PID = $PID[1];
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