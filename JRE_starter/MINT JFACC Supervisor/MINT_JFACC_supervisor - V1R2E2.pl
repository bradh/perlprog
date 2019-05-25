 #!/usr/bin/perl -w
 # V1R2E1
 # suppression du fichier DLIP_Context à l'arrêt du TDL router pour un redémarrage correct du ToplinkCom
 # suppression de la gestion de l'IHM type starter
 # suppression du choix du MIDS au démarrage
# V1R2E0
# Ajour de la commande  StartAll dans le menu Proces
# Suppression des confirmations dans la commande restartAll
# Simplifaction de la commande de détection de déconnexion du MIDS
# La pop-up demandant à l'opérateur si le MIDS est utilisé n'est demandé qu'audémarrage et au restart
# Utilisation d'une DLTE en mode Master
# V1R0E1
# Ajout de la gestion des fichier .log .rcd
# Adaptation a l'OS Linux (vs SOLARIS)
# Gestion de la reconnexion au MIDS apres arret de ce dernier
# Gestion des modes master et use (avec ou sans MIDS) au re démarrage du TDL router
# Gestion dynamique du fichier Context
# Suppression des menus ComMgr
# Mise au propre des menu Log
#  par S. Mouchot le  11/03/14
# Classement des RCD par répertoire daté par MD et JYI le 09/04/2014
# Z. Aslan le 28/01/15:
# Modification de SaveRecording et SaveLog pour ne pas arrêter les appli pendant le transfert des RCD
# Modification de SaveRecording de façon à récupérer les RCD courants de la partition /jfacclog/DLIP 

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use JreProcessorsConfiguration;
use DlipComOperationalConfiguration;
#Tkx::package_require("style");
#Tkx::style__use("as", -priority => 70);
#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $debug = 0;

my $Disk_Label = "E:";
my $HOME_DIR="/jfacc";
my $HOME_WIN_DIR="$Disk_Label\\THALES";
my $CONFIG_DIR = "$Disk_Label\\CONFIGURATION";
my $RECORDING_DIR = "$Disk_Label\\RECORDING";
my $LOG_DIR = "$Disk_Label\\JFACCLOG";
my $putty_session = "JRE-Gateway";
my $user = "jfacc_op";

my $jrepName;
# Supervision MIDS
#my $mids_db = "MIDS_DB";
my $mids_db = "192.168.163.31";
my $mids_db_local = "192.168.164.18";
my $mids_db_port = "1024";
my $mids_db_present = 0;
my $mids_db_connected = 0;
my $mids_status_label = "not present";
my $host_status_label = "not present";
my $jrep_status_label = "not present";
my $dlp_status_label = "not present";
my $useMIDS = 0;
my $useMIDSLabel = "MIDS";
my $first_ping_mids = 0;
my $first_disconnection_mids = 0;
my $systemStart =1;
my $tdl_restarted = 0;
my @jre_gateway_connexion_list;

my $linux_ip = "192.168.0.13";
# Supervision cnx DLP
my $dlp_port_num = '2048';

# Supervision cnx JREP
my $jrep_port_num = '2703';

# Supervision cnx HOST
my $host_port_num = '8202';

my $synchro_linux_ok = 1;

my @TaskList = ("OSIM", "DLIP", 
				"TOPLINKCOM", "TDL_ROUTER",
				"JREM", "JREP",  
				);

my @linux_process_list;
my @windows_process_list;

my $LOG_DIR = "$Disk_Label\\LOG"; #JYI le 10/04/14: ce lecteur n existe pas. 

# ordre d'affichage des boutons
my $i = 0;
my $STATUS_NUM = $i;
$i++;
my $JREP_NAME_NUM = $i;
$i++;
my $HOST_CNX_NUM = $i;
$i++;
my $DLP_CNX_NUM = $i;
$i++;
my $JREP_CNX_NUM = $i;
$i++;
my $MIDS_CNX_NUM = $i;
$i++;
my $EXE_LABEL_NUM = $i;
$i++;
my $OSIM_NUM = $i;
$i++;
my $DLIP_NUM = $i;
$i++;
my $TOPLINKCOM_NUM= $i;
$i++;
my $TDL_ROUTER_NUM = $i;
$i++;
my $JREM_NUM = $i;
$i++;
my $JREP_NUM = $i;

# Boutons de commande
my $CMD_LABEL_NUM = $i;
$i++;
my $CMD_CONTEXT_NUM = $i;
$i++;
my $CMD_START_NUM = $i;
$i++;
my $CMD_LOG_NUM = $i;
$i++;
my $CMD_CLEAR_NUM = $i;
$i++;
my $CMD_EXIT_NUM = $i;
$i++;
my $HOST_NUM = $i;
$i++;
my $L16_TD_NUM = $i;

# Process Lynx


# Linux Process
local $DLIP = {	'NUM'		=> $DLIP_NUM, 
				'EXE' 		=> "./mct_main",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_DLIP",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_DLIP",
				'CMD' 		=> "cd $HOME_DIR/Ops/DLIP; ./mct_main >& /dev/null &",
				'CONFIG_DIR' => "$HOME_DIR/Ops/DLIP",
				'LOG' 		=> "mct_main.log",
				'LOG_DIR' 	=> "/jfacclog/DLIP",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_DLIP_log",
				'OPERATING_SYST'	=> "LINUX"
};

local $TDL_ROUTER = {	
				'NUM'		=> $TDL_ROUTER_NUM, 
				'EXE' 		=> "./tdl_router_main",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_TDL_ROUTER",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_TDL_ROUTER",
				'CMD' 		=> "cd $HOME_DIR/Ops/TDL_ROUTER; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./tdl_router_main >& /dev/null &",
				'CONFIG_DIR' => "$HOME_DIR/Ops/TDL_ROUTER",
				'LOG' 		=> "tdl_router_main.log",
				'LOG_DIR' 	=> "/jfacclog/TDL_ROUTER",
				'CLEAR_LOG' => "cd $HOME_DIR/Scripts; ./clear_TDL_ROUTER_log",
				'OPERATING_SYST'	=> "LINUX"
};
my $contextFileTDL = "DLIP_CONTEXT.xml";

local $JREP = {	'NUM'		=> $JREP_NUM, 
				'EXE' 		=> "./jre_main",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_JREP",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_JREP",
				'CMD' 		=> "cd $HOME_DIR/Ops/JREP/exe; ulimit -s unlimited; export TZ=GMT; ./jre_main >& /dev/null &",
				'CONFIG_DIR' => "$HOME_DIR/Ops/JREP/conf",
				'LOG' 		=> "jre.log",
				'LOG_DIR' 	=> "/jfacclog/JREP",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_JREP_log",
				'OPERATING_SYST'	=> "LINUX"
};

local $HOST = {	'NUM'		=> $HOST_NUM, 
				'EXE' 		=> "./host_test_driver",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_HOST_TD $useMIDS >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_HOST_TD >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "host_driver_test.log",
				'LOG_DIR' 	=> "/jfacclog/HOST_TD",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_HOST_TD_log",
				'OPERATING_SYST'	=> "LINUX"
};

# Process Windows
local $OSIM = {	'NUM'		=> $OSIM_NUM,
				'EXE' 		=> "OSIM.exe",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\OSIM\\",
				'WIN_NAME'	=> "OSIM",
				'START' 	=> "$HOME_WIN_DIR\\OSIM\\osim.exe",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $TOPLINKCOM = {	
				'NUM'		=> $TOPLINKCOM_NUM, 
				'EXE' 		=> "TOPLINKCOM.bat",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\TOPLINKCOM\\",
				'WIN_NAME'	=> "TopLink Communication Manager",
				'START' 	=> "TOPLINKCOM.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};
my $contextFileTLC = "Context_Data.xml";

local $JREM = {	'NUM'		=> $JREM_NUM, 
				'EXE' 		=> "JREM.bat",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\JREM\\bin",
				'WIN_NAME'	=> "JRE Management",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $CONTEXTBUILDER = {	
				'NUM'		=> 0, 
				'EXE' 		=> "ContextFileBuilder.bat",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\ContextFileBuilder\\",
				'WIN_NAME'	=> "ContextFileBuilder",
				'START' 	=> "ContextFileBuilder.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $TOPLINKVIEW = {	'NUM'		=> $TOPLINKVIEW_NUM, 
				'EXE' 		=> "TopLink-Spy.exe",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\TOPLINKSPY\\TopLink\-Spy",
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
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\DLTE_S16_TDL",
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
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\DLTE_S16_TDL",
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
				'EXE' 		=> "appli_tmct_hexagonal_ss.exe",
				'RUN_DIR' 	=> "$HOME_WIN_DIR\\TMCT\\bin\\",
				'WIN_NAME'	=> "tmct_hexagonal",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

my $mw;

my @startStopButton;
my $widthLabel;
my @Hframe;
my @photo;
my $startPhoto;
my $stopPhoto;
my $startInactivePhoto;
my $stopInactivePhoto;
my $blankPhoto;
my $traitSimpleVerticalPhoto;
my $traitSimpleVerticalOKPhoto;
my $traitSimpleVerticalKOPhoto;
my $traitSimpleHorizontalPhoto;
my $traitSimpleHorizontalOKPhoto;
my $traitSimpleHorizontalKOPhoto;

my $MIDS_CNX_LABEL;
my $DLP_CNX_LABEL;
my $JREP_CNX_LABEL;
my $HOST_CNX_LABEL;

my $HframeSchemaMain;
my @HframeSchema;
my @VframeSchema;

if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}
  
if(! $opt_h) {
	my $ref = JreProcessorsConfiguration::readConfigFile();
	print "$ref\n";
	$jrepName = JreProcessorsConfiguration::getJrepName();
	$mw = Tkx::widget->new(".");
	$mw->g_wm_title( "TOPLINK Supervisor" );
	#$mw->configure(-menu => mk_menu($mw));	
	$jrepName = JreProcessorsConfiguration::getJrepName();
	print "$jrepName\n";
	$HframeSchemaMain = $mw->new_ttk__frame();
	$mw->configure(-menu => mk_menu($mw));
	initSchemaButton();
	$HframeSchemaMain->g_grid();
	$mw->g_wm_geometry("-120+10");
	# Attente synchro SUN
	my $LINUX_SYNCHRO_STATE = 0;
	while ( ! $LINUX_SYNCHRO_STATE){
		my $NTP_CMD = `plink $putty_session \"ntpq -p\"`;
		print "wait for Linux synchro...";
		$LINUX_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*/ || $synchro_linux_ok);
		sleep 1;
	}
	print "Linux Synchro ok !\n";
	
	# Choix du terminal MIDS
	#checkMIDS();
	updateStatusAll();	
	timer(5000);
	Tkx::MainLoop();
}

sub mk_menu {
	my $menu = $mw->new_menu ();

  	my $process = $menu->new_menu(
          		-tearoff => 0,
          		-background => 'lightgrey'
      			);
      $menu->add_cascade(
          -label => "Process",
          -underline => 0,
          -menu => $process,
      );
      $process->add_command(
      		-label => "Restart All",
      		-underline => 0,
      		-command => \&restartAllWithoutConfirmation
      );	  
      $process->add_command(
      		-label => "Stop All",
      		-underline => 0,
      		-command => \&stopAllWithoutConfirmation
      );
      $process->add_command(
      		-label => "Start All",
      		-underline => 0,
      		-command => \&startAllWithoutConfirmation
      );
      $process->add_command(
          -label   => "Exit",
          -underline => 1,
          -command => [\&exitJREStarter],
      );
	  # Menu Configuration
      my $configuration = $menu->new_menu(
          		-tearoff => 0,
          		-background => 'lightgrey'
      );				
      $menu->add_cascade(
          -label => "Configuration",
          -underline => 0,
          -menu => $configuration,
      );
      $configuration->add_command(
      		-label => "Retrieve",
      		-underline => 0,
      		-command => \&retrieveConfiguration
      );
      $configuration->add_command(
      		-label => "Update",
      		-underline => 0,
      		-command => \&updateConfiguration
      );
	  # Menu Recording
      my $recording = $menu->new_menu(
          		-tearoff => 0,
          		-background => 'lightgrey'
      );				
      $menu->add_cascade(
          -label => "Recording",
          -underline => 0,
          -menu => $recording,
      );
      $recording->add_command(
      		-label => "Save",
      		-underline => 0,
      		-command => \&saveRecording
      );
      $recording->add_command(
      		-label => "Clear",
      		-underline => 0,
      		-command => \&clearRecording
      );
	  # Menu log
	  my $log = $menu->new_menu(
          		-tearoff => 0,
          		-background => 'lightgrey'
      );
      $menu->add_cascade(
          -label => "Log",
          -underline => 0,
          -menu => $log,
      );
      $log->add_command(
      		-label => "Save",
      		-underline => 0,
      		-command => \&saveLog
      );
      $log->add_command(
      		-label => "Clear",
      		-underline => 0,
      		-command => \&clearLog
      );
      return $menu;
} 

sub  initSchemaButton {
	my $task = shift;
	my $initialStartPhoto, my $initialStopPhoto;
	my $taskNum = $$task->{'NUM'};
	my $exe = $$task->{'EXE'};
	my ($width_pave, $width_cnx, $width_border) = (12, 4, 3);
	my ($height_pave, $height_cnx, $height_border) = (4, 2, 2);
	print "$width_pave, $width_cnx\n";

	$traitMultipleVerticalPhoto = Tkx::image_create_photo("trait_multiple_vertical", -file =>  "Images/trait_multiple_vertical.gif");
	$traitSimpleVerticalPhoto = Tkx::image_create_photo("trait_simple_vertical", -file => "Images/trait_simple_vertical.gif");
	$traitSimpleVerticalOKPhoto= Tkx::image_create_photo("trait_simple_vertical_OK", -file => "Images/trait_simple_vertical_OK.gif");
	$traitSimpleVerticalKOPhoto= Tkx::image_create_photo("trait_simple_vertical_KO", -file => "Images/trait_simple_vertical_KO.gif");
	$traitSimpleVerticalOOPhoto= Tkx::image_create_photo("trait_simple_vertical_OO", -file => "Images/trait_simple_vertical_OO.gif");
	$traitSimpleHorizontalPhoto= Tkx::image_create_photo("trait_simple_horizontal", -file => "Images/trait_simple_horizontal.gif");
	$traitSimpleHorizontalOKPhoto= Tkx::image_create_photo("trait_simple_horizontal_OK", -file => "Images/trait_simple_horizontal_OK.gif");
	$traitSimpleHorizontalKOPhoto= Tkx::image_create_photo("trait_simple_horizontal_KO", -file => "Images/trait_simple_horizontal_KO.gif");
	$traitSimpleHorizontalOOPhoto= Tkx::image_create_photo("trait_simple_horizontal_OO", -file => "Images/trait_simple_horizontal_OO.gif");
	
	$HframeSchemaMain = $mw->new_frame(-background => 'white');
	foreach my $i (0..8){
		foreach my $j (0..6){
			#print "$j, $i\n";
			$HframeSchema[$j*10+$i] = $HframeSchemaMain->new_ttk__frame();
			$HframeSchema[$j*10+$i]-> g_grid(-row => $j, -column => $i);
		}
	}
	# Row 0
	$HframeSchema[0]->new_label( -width => $width_border, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 0);
	$HframeSchema[1]->new_label( -width => $width_pave, -anchor => 'w',  -background => 'white', -height => $height_border) ->g_grid(-row => 0, -column => 1);
	$HframeSchema[2]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_border, -anchor => 'center') ->g_grid(-row => 0, -column => 2);
	$HframeSchema[3]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 3);
	$HframeSchema[4]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_border, -anchor => 'center') ->g_grid(-row => 0, -column => 4);
	$HframeSchema[5]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 5);
	$HframeSchema[6]->new_label( -width => $width_cnx, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 6);
	$HframeSchema[7]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 7);
	$HframeSchema[8]->new_label( -width => $width_border, -background => 'white', -height => $height_border)->g_grid(-row => 0, -column => 8);
	# Row 1 PAVE
	$HframeSchema[10]->new_label( -width => $width_border, -background => 'white', -height => $height_pave)->g_grid(-row => 1, -column => 0);
	$HframeSchema[11]->new_label( -width => $width_pave, -background => 'white', -height => $height_pave)->g_grid(-row => 1, -column => 1);
	$HframeSchema[12]->new_label( -width => $width_border, -background => 'white', -height => $height_pave)->g_grid(-row => 1, -column => 2);
	# Pave OSIM
	$startStopButton[$OSIM_NUM] = $HframeSchema[13]->new_button( -command => [\&startStopProcess, "OSIM"],
								 -text => "OSIM", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$OSIM_NUM]->g_grid(-row => 1, -column => 3);
	$HframeSchema[14]->new_label( -width => $width_cnx, 
								 -anchor => 'e',  -background => 'white', -height => $height_pave, -anchor => 'center') ->g_grid(-row => 1, -column => 4);
	# Pave TOPLINKCOM
	$startStopButton[$TOPLINKCOM_NUM] = $HframeSchema[15]->new_button( -command => [\&startStopProcess, "TOPLINKCOM"],
								 -text => "TOPLINKCOM", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$TOPLINKCOM_NUM]->g_grid(-row => 1, -column => 5);
	$HframeSchema[16]->new_label( -width => $width_cnx, 
								 -anchor => 'e',  -background => 'white', -height => $height_pave, -anchor => 'center') ->g_grid(-row => 1, -column => 6);
	# Pave JREM 
	$startStopButton[$JREM_NUM] = $HframeSchema[17]->new_button( -command => [\&startStopProcess, "JREM"],
								 -text => "JREM", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$JREM_NUM]->g_grid(-row => 1, -column => 7);
	$HframeSchema[18]->new_label( 	-width => $width_border, 
									-background => 'white', -height => $height_pave)->g_grid(-row => 1, -column => 8);
	# Row 2 CNX
	$HframeSchema[20]->new_label( -width => $width_border, 
									-background => 'white', -height => $height_cnx)->g_grid(-row => 2, -column => 0);	
	$HframeSchema[21]->new_label( -width => $width_pave, 
								 -anchor => 'e',  
								 -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 2, -column => 1);
	$HframeSchema[22]->new_label( -width => $width_cnx, 
								 -anchor => 'e',  
								 -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 2, -column => 2);
	# Connexion OSIM
	$HframeSchema[23]->new_label( -borderwidth => 0, -image => $traitSimpleVerticalPhoto)->g_grid(-row => 2, -column => 3);
								
	$HframeSchema[24]->new_label( -width => $width_cnx, 
								 -anchor => 'e',  
								 -background => 'white', -height => $height_cnx, -anchor => 'center')->g_grid(-row => 2, -column => 4);	
	# Connexion TOPLINKCOM
	$HframeSchema[25]->new_label( -borderwidth => 0, -image => $traitSimpleVerticalPhoto)->g_grid(-row => 2, -column => 5);
	$HframeSchema[26]->new_label( -width => $width_cnx, 
								 -anchor => 'e',  -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 2, -column => 6);
	$HframeSchema[27]->new_label( -borderwidth => 0, -image => $traitSimpleVerticalPhoto)->g_grid(-row => 2, -column => 7);
	$HframeSchema[28]->new_label( -width => $width_border, -background => 'white', -height => $height_cnx)->g_grid(-row => 2, -column => 8);	
	# Row 3	
	$HframeSchema[30]->new_label( -width => $width_border, 
									-background => 'white', 
									-height => $height_pave)->g_grid(-row => 3, -column => 0);
	# Pave Host platform
	$startStopButton[0] =$HframeSchema[31]->new_label( -text => "$jrepName", -width => $width_pave, 
								 -anchor => 'e',  -background => 'grey', -height => $height_pave, -anchor => 'center');
	$startStopButton[0]->g_grid(-row => 3, -column => 1);
	# Connexion HOST
	$HOST_CNX_LABEL = $HframeSchema[32]->new_label( -borderwidth => 0, -image => $traitSimpleHorizontalKOPhoto);
	$HOST_CNX_LABEL->g_grid(-row => 3, -column => 2);
	
	# Pave DLIP
	$startStopButton[$DLIP_NUM] = $HframeSchema[33]->new_button( -command => [\&startStopProcess, "DLIP"],
								 -text => "DLIP", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$DLIP_NUM]->g_grid(-row => 3, -column => 3);
	
	# Connexion DLP
	$DLP_CNX_LABEL = $HframeSchema[34]->new_label( -borderwidth => 0, -image => $traitSimpleHorizontalKOPhoto);
	$DLP_CNX_LABEL->g_grid(-row => 3, -column => 4);
	
	# Bouton TDL router
	$startStopButton[$TDL_ROUTER_NUM] = $HframeSchema[35]->new_button( -command => [\&startStopProcess, "TDL_ROUTER"],
								 -text => "TDL Router", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$TDL_ROUTER_NUM]->g_grid(-row => 3, -column => 5);
	
	# Connexion JREP
	$JREP_CNX_LABEL = $HframeSchema[36]->new_label( -borderwidth => 0, -image => $traitSimpleHorizontalKOPhoto);
	$JREP_CNX_LABEL->g_grid(-row => 3, -column => 6);
	
	# Pave JREP
	$startStopButton[$JREP_NUM] = $HframeSchema[37]->new_button( -command => [\&startStopProcess, "JREP"],
								 -text => "JRE Processor", -width => $width_pave, -background => 'grey', -height => $height_pave);
	$startStopButton[$JREP_NUM]->g_grid(-row => 3, -column => 7);
	$HframeSchema[38]->new_label( -width => $width_border, 
								-background => 'white', 
								-height => $height_pave)->g_grid(-row => 3, -column => 8);
	# Row 4		
	$HframeSchema[40]->new_label( -width => $width_border, -background => 'white', -height => $height_cnx)->g_grid(-row => 4, -column => 0);
	$HframeSchema[41]->new_label( -width => $width_pave, -anchor => 'e',  -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 4, -column => 1);
	$HframeSchema[42]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 4, -column => 2);
	$HframeSchema[43]->new_label( -width => $width_pave, -anchor => 'e',  -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 4, -column => 3);
	$HframeSchema[44]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_cnx, -anchor => 'center') ->g_grid(-row => 4, -column => 4);
	
	# MIDS Connexion
	$MIDS_CNX_LABEL = $HframeSchema[45]->new_label( -borderwidth => 0,  -image => $traitSimpleVerticalKOPhoto);
	$MIDS_CNX_LABEL->g_grid(-row => 4, -column => 5);
	$HframeSchema[46]->new_label( -width => $width_border, -background => 'white', -height => $height_cnx)->g_grid(-row => 4, -column => 6);
	$HframeSchema[47]->new_label( -borderwidth => 0, -image =>$traitMultipleVerticalPhoto)->g_grid(-row => 4, -column => 7);
	$HframeSchema[48]->new_label( -width => $width_border, -background => 'white', -height => $height_cnx)->g_grid(-row => 4, -column => 8);

	# Row 5		
	$HframeSchema[50]->new_label( -width => $width_border, 
									-background => 'white', 
									-height => $height_pave)->g_grid(-row => 5, -column => 0);
	
	$HframeSchema[51]->new_label( -width => $width_cnx, 
									-background => 'white', 
									-height => $height_pave) ->g_grid(-row => 5, -column => 1);
	$HframeSchema[52]->new_label( -width => $width_cnx, 
									-background => 'white', 
									-height => $height_pave) ->g_grid(-row => 5, -column => 2);
	$HframeSchema[53]->new_label( -width => $width_cnx, 
									-background => 'white', 
									-height => $height_pave) ->g_grid(-row => 5, -column => 3);
	$HframeSchema[54]->new_label( -width => $width_cnx, 
									-background => 'white', 
									-height => $height_pave) ->g_grid(-row => 5, -column => 4);
	# Bouton MIDS
	$startStopButton[$MIDS_CNX_NUM] =$HframeSchema[55]->new_label( -textvariable => \$useMIDSLabel, -width => $width_pave, 
								 -background => 'grey', 
								 -height => $height_pave, 
								 -anchor => 'center');
	$startStopButton[$MIDS_CNX_NUM]->g_grid(-row => 5, -column => 5);
	$HframeSchema[56]->new_label( -width => $width_border, 
								-background => 'white', -height => $height_pave)->g_grid(-row => 5, -column => 6);
	$HframeSchema[57]->new_label( -width => $width_border, 
								-background => 'white', -height => $height_pave)->g_grid(-row => 5, -column => 7);
	$HframeSchema[58]->new_label( -width => $width_border, 
								-background => 'white', -height => $height_pave)->g_grid(-row => 5, -column => 8);
	# Row 6		
	$HframeSchema[60]->new_label( -width => $width_border, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 0);
	$HframeSchema[61]->new_label( -width => $width_pave, -anchor => 'w',  -background => 'white', -height => $height_border) ->g_grid(-row => 6, -column => 1);
	$HframeSchema[62]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_border, -anchor => 'center') ->g_grid(-row => 6, -column => 2);
	$HframeSchema[63]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 6);
	$HframeSchema[64]->new_label( -width => $width_cnx, -anchor => 'e',  -background => 'white', -height => $height_border, -anchor => 'center') ->g_grid(-row => 6, -column => 4);
	$HframeSchema[65]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 5);
	$HframeSchema[66]->new_label( -width => $width_border, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 6);
	$HframeSchema[67]->new_label( -width => $width_pave, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 7);
	$HframeSchema[68]->new_label( -width => $width_border, -background => 'white', -height => $height_border)->g_grid(-row => 6, -column => 8);	
}

sub startContextBuilder{
	startWindowsProcess("CONTEXTBUILDER") if(confirmAction ("Build JRE Context ?") eq "yes");
}

sub restartAll {
	if(confirmAction ("Restart All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			stopProcess($task);
			startProcess($task);
		}
	}	
}

sub startAll {
	if(confirmAction ("Start All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			startProcess($task);
		}
	}	
}

sub startAllWithoutConfirmation {
	if(confirmAction ("Start All Process ?") eq "yes"){
			checkMIDS();
		#foreach my $task (@TaskList){
			startProcessWithoutConfirmation("JREP");
			startProcessWithoutConfirmation("JREM");
			startProcessWithoutConfirmation("TDL_ROUTER");
			#sleep 5;
			startProcessWithoutConfirmation("TOPLINKCOM");						
			startProcessWithoutConfirmation("DLIP");
			startProcessWithoutConfirmation("OSIM");
		#}
	}	
}
sub restartAllWithoutConfirmation {
	stopAllWithoutConfirmation($task);
	startAllWithoutConfirmation($task);
}

sub stopAll {
	if(confirmAction ("Stop All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			stopProcess($task);
		}
	}	
}

sub stopAllWithoutConfirmation {
	if(confirmAction ("Stop All Process ?") eq "yes"){
	
		foreach my $task (@TaskList){
			stopProcessWithoutConfirmation($task);
		}
		suppContextFileTDL();
		suppContextFileTLC();
	}
		
}

sub updateStatusAll {
	isMIDSPresent();
	updateStatusMIDS();
	updateContextFile();
	print " MDIS present : $mids_db_present\n" if ($debug);
	print "updateWindowsProcessList\n"if( $debug);
	updateWindowsProcessList();
	print "updateLinuxProcessList\n";
	updateLinuxProcessList();
	print "update Tasks\n" if( $debug);
	foreach my $task (@TaskList){
		print "updateStatusProcess $task\n";
		updateStatusProcess($task);
	} 
	print "updateConnexionList\n" if($debug);
	updateConnexionList();
	updateCnxMIDS();
	updateCnxJREP();
	updateCnxDLP();
	updateCnxHOST();
	# Gestion de la connexion au terminal MIDS
	# Si le MIDS est présent et que la connexion au terminal est OFF et le MIDS est utilisé et le TDL router tourne
	# on relance le TDL_touter sans confirmation
	print " mids present = $mids_db_present
	mids cnx = $mids_db_connected
	tdl_restarted = $tdl_restarted\n" if( $debug == 2);
	
	#if( ( isMIDSConnected() == 0 ) 
	#	&& ! $tdl_restarted  
	#	&& $useMIDS && isLinuxProcessRunning( "TDL_ROUTER" )
	#	&& confirmAction( "MIDS deconnected, restart TDL ROUTER ? ") eq "yes" )  {
	#		stopProcessWithoutConfirmation("TDL_ROUTER");		
	#		stopProcessWithoutConfirmation("TOPLINKCOM");
	#		sleep 10;
	#		startProcess("TDL_ROUTER");
	#		$tdl_restarted = 1;
	#}
}

sub startProcess {
	my $task = shift;
	print "start $task\n";
	if($$task->{'OPERATING_SYST'} eq "LINUX"){
		if( ! isLinuxProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){
			if($task eq "TDL_ROUTER"){
				#stopProcessWithoutConfirmation("TOPLINKCOM");
				#checkMIDS();
				startProcessWithoutConfirmation("TOPLINKCOM");				
			}
			if($task eq "JREP"){
				startProcessWithoutConfirmation("JREM");				
			}
			if($task eq "DLIP"){
				startProcessWithoutConfirmation("OSIM");				
			}
			startLinuxProcess ($task); 
			sleep 1;
			updateLinuxProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		if( ! isWindowsProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){
			startWindowsProcess($task);
			sleep 5 if($task eq "JREM" || $task eq "OSIM" || $task eq "TOPLINKCOM");
			updateWindowsProcessList();
		}
	}
	updateStatusProcess($task);
}

sub startProcessWithoutConfirmation {
	my $task = shift;
	print "start $task\n";
	if($$task->{'OPERATING_SYST'} eq "LINUX"){
		if( ! isLinuxProcessRunning ($task) ){
			if($task eq "TDL_ROUTER"){
				#stopProcessWithoutConfirmation("TOPLINKCOM");
				#checkMIDS();
				#startProcessWithoutConfirmation("TOPLINKCOM");				
			}
			if($task eq "JREP"){
				#startProcessWithoutConfirmation("JREM");				
			}
			if($task eq "DLIP"){
				#startProcessWithoutConfirmation("OSIM");				
			}
			startLinuxProcess ($task); 
			#sleep 1;
			updateLinuxProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		if( ! isWindowsProcessRunning ($task)){
			startWindowsProcess( $task);
			sleep 5 if($task eq "JREM" || $task eq "OSIM" || $task eq "TOPLINKCOM");
			updateWindowsProcessList();
		}
	}
	#updateStatusProcess ($task);
}

sub startStopProcess {
	my $task = shift;
	# my $image = $startStopButton[$$task->{'NUM'}]->cget('-image');
	my $color = $startStopButton[$$task->{'NUM'}]->cget('-background');
	if($color eq 'green'){
		print "stop $task\n";
		stopProcess($task);
	}
	if($color eq 'red'){
		print "start $task\n";
		startProcess($task);
	}
}

sub startStopProcessWithoutConfirmation {
	my $task = shift;
	# my $image = $startStopButton[$$task->{'NUM'}]->cget('-image');
	my $color = $startStopButton[$$task->{'NUM'}]->cget('-background');
	if($color eq 'green'){
		print "stop $task\n";
		stopProcessWithoutConfirmation($task)
	}
	if($color eq 'red'){
		print "start $task\n";
		startProcessWithoutConfirmation($task);
	}
}

sub stopProcess {
	my $task = shift;
	print "stop $task \n";
	if($$task->{'OPERATING_SYST'} eq "LINUX"){
		if(isLinuxProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			stopLinuxProcess ($task);
			updateLinuxProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		#acquittementAction( "Sorry ! WINDOWS process must be stopped using HMI.");
	}
	print " update $task\n";
	#updateStatusProcess($task) ;
}

sub stopProcessWithoutConfirmation {
	my $task = shift;
	print "stop $task\n";
	if($$task->{'OPERATING_SYST'} eq "LINUX"){
		stopLinuxProcess ($task) if( isLinuxProcessRunning ($task));
		updateLinuxProcessList();
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){		
		stopWindowsProcess($task) if( isWindowsProcessRunning ($task));	
		sleep 1;
		updateWindowsProcessList();
	}
	print " update $task\n";
}

sub updateStatusProcess {
	my $task = shift;
	if($$task->{'OPERATING_SYST'}eq "LINUX" ) {
		if ( isLinuxProcessRunning($task)) {
				$startStopButton[$$task->{'NUM'}]->configure(-background => 'green');
		}
		else {
			$startStopButton[$$task->{'NUM'}]->configure(-background => 'red');
		}
	}
	if ($$task->{'OPERATING_SYST'}eq "WINDOWS" ) {
		if ( isWindowsProcessRunning ($task)){
			$startStopButton[$$task->{'NUM'}]->configure(-background => 'green');
		}
		else {
			$startStopButton[$$task->{'NUM'}]->configure(-background => 'red');
		}
	}
}

sub updateStatusMIDS {	
	if( $useMIDS ) {	
		#isMIDSConnected() if ( $mids_db_present);
		if( $mids_db_present ) {
			$startStopButton[$MIDS_CNX_NUM]->configure(-background => 'green');
		}
		else {
			$startStopButton[$MIDS_CNX_NUM]->configure(-background => 'red');
		}
	}
	else {
		$startStopButton[$MIDS_CNX_NUM]->configure(-background => 'grey');
	}
}	

sub updateLinuxProcessList{
	my $process_list = `plink $putty_session ps U $user`;
	(@linux_process_list) = split("\n", $process_list);
	print $process_list;
	return 0;
}

sub isLinuxProcessRunning {
	my $task = shift;
	my $process_name = $$task->{'EXE'};
	my $PID = 0;
	print "process : $process_name\n" if($debug);
	foreach my $current_process (@linux_process_list){
		print "$current_process\n" if($debug);
		if ($current_process =~/$process_name/){
			print "here it is !\n" if($debug);
			(my @PID) = split(" ", $current_process);
			$PID = $PID[1];
			print "$PID\n" if( $debug);
			last;
		}
	}
	return $PID;
}
		
sub startLinuxProcess {
	my $task = shift;
	my $process_cmd = $$task->{'START'};
	print "$process_cmd\n";
	return system ("plink $putty_session \"$process_cmd\"");
}

sub stopLinuxProcess {
	my $task = shift;
	my $process_cmd = $$task->{'STOP'};
	return system ("plink $putty_session \"$process_cmd\"");
}	

sub updateWindowsProcessList {
	my $process_list = `tasklist.exe \/V`;
	(@windows_process_list) = split("\n", $process_list);
	return 0;
}

sub isWindowsProcessRunning {
	my $task = shift;
	print "$task\n";
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

sub updateConnexionList {
	(@jre_gateway_connexion_list) = `plink $putty_session netstat -plant `;
	if( $debug) {
		foreach my $cnx (@jre_gateway_connexion_list){
			print "cnx :$cnx\n";
		}
	}
	#print "$jre_gateway_connexion_list";
}

sub updateCnxDLP {
	if( isDLPConnected() ) {
		$DLP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_OK');
	}
	else { 
		$DLP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_KO');
	}
}

sub updateCnxJREP {
	
	if( isJREPConnected() ) {
		$JREP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_OK');
	}
	else { 
		$JREP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_KO');
	}
}

sub updateCnxHOST {
	if( isHOSTConnected() ) {
		$HOST_CNX_LABEL->configure(-image => 'trait_simple_horizontal_OK');
	}
	else { 
		$HOST_CNX_LABEL->configure(-image => 'trait_simple_horizontal_KO');
	}
}

sub updateCnxMIDS {
	if( $useMIDS ) {
		my $cnx = isMIDSConnected();
		if( $cnx == 1 ) {
			$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_OK');
			# re initialisation de  l info sur le resemarrage du tdl router
			$tdl_restarted = 0;
		}
		# obsolete
		if( $cnx == 2 ) {
			$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_OO');
			# re initialisation de  l info sur le resemarrage du tdl router
			$tdl_restarted = 0;
		}
		if( $cnx == 0 ) { 
			$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_KO');
		}
	}
	else {
		$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical');
	}
	return 0;
}

sub isMIDSPresent{
	$mids_db_present = 0;
	print "Wait for MIDS ping response ...\n" if( $debug == 2 );
	my $cmd = "ping $mids_db -c 1 ";
	my $result = `plink $putty_session $cmd `;
	print "result = $resutlt" if ( $debug == 2 );
	$mids_db_present = 1 if( $result !~ /0 received/);	
	print "MIDS present  : $result : $mids_db_present\n" if($debug == 2);
	return 	$mids_db_present;
}

sub isMIDSConnected {
	$mids_db_connected = 0 ;
	foreach my $cnx (@jre_gateway_connexion_list){
		#print "MIDS $cnx" if( $debug == 2);
		if ( $cnx =~ /:$mids_db_port/ && $cnx =~ /ESTABLISHED/ && $cnx =~ /tdl_router/ ){
			#print "MIDS $cnx" if( $debug == 2);
			$mids_db_connected = 1;
		}
	}
	print "etat connection MIDS = $mids_db_connected \n" if( $debug == 2);
	return $mids_db_connected;
}

sub isDLPConnected {
	my $dlp_connected = 0;
	foreach my $cnx (@jre_gateway_connexion_list){
		if ( $cnx =~ /:$dlp_port_num\s+ESTABLISHED/){
			$dlp_connected = 1;
			#last;	
		}
	}
	return $dlp_connected;
}

sub isJREPConnected {
	my $jrep_connected = 0;
	foreach my $cnx (@jre_gateway_connexion_list){
		if ( $cnx =~ /:$jrep_port_num/ && $cnx =~ /ESTABLISHED/){
			$jrep_connected = 1;
			#last;	
		}
	}
	return $jrep_connected;
}

sub isHOSTConnected {
	my $host_connected = 0;
	foreach my $cnx (@jre_gateway_connexion_list){
		if ( $cnx =~ /:$host_port_num/ && $cnx =~ /ESTABLISHED/){
			$host_connected = 1;
			#last;	
		}
	}
	print "result host cnx : $host_connected\n" if($debug == 2);
	return $host_connected;
}

sub retrieveConfiguration {
	if(confirmAction("Retrieve configuration ? ") eq "yes" ){
		mkdir($CONFIG_DIR) if( ! -d $CONFIG_DIR);
		if (-d  "$CONFIG_DIR"){
			foreach my $task (@TaskList) {
				if($$task->{'OPERATING_SYST'} eq "LINUX"){
					mkdir("$CONFIG_DIR\\$task") if( ! -d "$CONFIG_DIR\\$task"); 
					my $remote_config_dir = $$task->{"CONFIG_DIR"};				
					# retrieve DLIP config
					if ( $task eq "DLIP"){
					
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/mct_main.cfg $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/mct_main.trc $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/MP.Param $CONFIG_DIR\\$task") ;
					}
					if ( $task eq "TDL_ROUTER"){
					
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/tdl_router_main.cfg $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/tdl_router_main.trc $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/L16_user.Param $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/L16_master.Param $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/standalone_user.xml $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/standalone_master.xml $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/midsRegistration.xml $CONFIG_DIR\\$task") ;
						#system("pscp jfacc_op\@$putty_session:$remote_config_dir\/MP.Param $CONFIG_DIR\\$task") ;
					}
					if ( $task eq "JREP"){
					
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/jre_config.xsd $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/parameters.txt $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/conf_jrep.xml $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/jre_param.xsd $CONFIG_DIR\\$task") ;
						system("pscp jfacc_op\@$putty_session:$remote_config_dir\/param_jrep.xml $CONFIG_DIR\\$task") ;
					}
				}
			}
		}
		acquittementAction("Configuration retrieved !");
	}
}

sub updateConfiguration {
	if(confirmAction("Update configuration ? ") eq "yes" ){
		#stopAll();
		foreach my $task (@TaskList) {
			if($$task->{'OPERATING_SYST'} eq "LINUX"){
					my $remote_config_dir = $$task->{"CONFIG_DIR"};				
					# retrieve DLIP config
					if ( $task eq "DLIP" && confirmAction("Update DLIP configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\mct_main.cfg jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\mct_main.trc jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\MP.Param jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
					}
					if ( $task eq "TDL_ROUTER"  && confirmAction("Update TDL ROUTER configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\tdl_router_main.cfg jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\tdl_router_main.trc jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\L16_user.Param jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\L16_master.Param jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\standalone_user.xml jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\standalone_master.xml jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\midsRegistration.xml jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						#system("pscp $CONFIG_DIR\\$task\\MP.Param jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
					}
					if ( $task eq "JREP" && confirmAction("Update JRE configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\jre_config.xsd jfacc_op\@$putty_session:$remote_config_dir\/") ;
						system("pscp $CONFIG_DIR\\$task\\parameters.txt jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\conf_jrep.xml jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\jre_param.xsd jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\param_jrep.xml jfacc_op\@$putty_session:$remote_config_dir\/ ") ;
					}
			}
		}
		acquittementAction("Configuration updated !");
	}
}

sub saveRecording {
#	if(confirmAction("Save Reoording File ? It will stop all applications !") eq "yes" ){
	if(confirmAction("Save Recording File ?") eq "yes" ){
#		stopAllWithoutConfirmation();
		mkdir($RECORDING_DIR) if( ! -d $RECORDING_DIR);
		if (-d  "$RECORDING_DIR"){
			my $sec,$min,$hour,$md,$mon,$year,$wd,$yd,$isdst;
			($sec,$min,$hour,$md,$mon,$year,$wd,$yd,$isdst) = localtime () ;
			my $jc_year = $year + 1900;
			my $normal_mon = $mon + 1 ;
			my $DATE_DIR = "$jc_year\_$normal_mon\_$md\_$hour\_$min\_$sec" ;
			mkdir("$RECORDING_DIR\\$DATE_DIR") ;
			#my $remote_recording_dir = "$HOME_DIR/Ops/TDL_ROUTER";				
			my $remote_recording_dir = "/jfacclog/TDL_ROUTER";				
			# retrieve recording TDL ROUTER
			print "pscp jfacc_op\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR\n" if( $debug != 0 ) ;
			system("pscp jfacc_op\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR") ;
			#$remote_recording_dir = "$HOME_DIR/Ops/JREP/trace";				
			my $remote_recording_dir = "/jfacclog/JREP";
			# retrieve recording JREP
			print "pscp jfacc_op\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR\n" if( $debug != 0 ) ;
			system("pscp jfacc_op\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR") ;
		}
		clearRecording();
	}
}

sub clearRecording() {
}

sub saveLog {
#	if(confirmAction("Save Log File ? It will stop all applications !") eq "yes" ){
	if(confirmAction("Save Log File ?") eq "yes" ){
#		stopAllWithoutConfirmation();
		mkdir($LOG_DIR) if( ! -d $LOG_DIR);
		if (-d  "$LOG_DIR"){
			chdir($LOG_DIR);
			foreach my $task (@TaskList) {
				if($$task->{'OPERATING_SYST'} eq "LINUX" && confirmAction("Save $task log ?") eq "yes" ){
					mkdir($task) if( ! -d $task); 
					chdir($task);
					my $remote_log_dir = $$task->{"LOG_DIR"};				
					# retrieve DLIP log
					print "pscp jfacc_op\@$putty_session:$remote_log_dir\/\*.log $LOG_DIR\\$task\n" if( $debug != 0 ) ;
					system("pscp jfacc_op\@$putty_session:$remote_log_dir\/\*.log $LOG_DIR\\$task") ;
					chdir ("..");
				}
			}
		}
		clearLog();
	}
}

sub clearLog{
	my $clear_cmd = $TDL_ROUTER->{'CLEAR_LOG'};
	if(confirmAction("Clear TDL router Log File ?") eq "yes" ){
		system("plink $putty_session $clear_cmd") ;
	}
	$clear_cmd = $JREP->{'CLEAR_LOG'};
	system("plink $putty_session $clear_cmd") if(confirmAction("Clear JRE Log File ?") eq "yes" );
	$clear_cmd = $DLIP->{'CLEAR_LOG'};
	system("plink $putty_session $clear_cmd") if(confirmAction("Clear DLIP Log File ?") eq "yes" );
	acquittementAction("That's all folks !");
	# suppression des log du TOPLINKCOM
	system("del /Q $HOME_DIR\\TOPLINKCOM\\log\\*");
	# suppression des log du JREM
	system("del /Q $HOME_DIR\\JREM\\log\\*");
}

sub suppContextFileTDL(){
	my $cmd = "rm -fr $TDL_ROUTER->{'CONFIG_DIR'}/$contextFileTDL";
	print "$cmd\n";
	system ( "plink $putty_session rm -fr $cmd");
}

sub suppContextFileTLC(){
	my $cmd = "$TOPLINKCOM->{'RUN_DIR'}\\properties\\$contextFileTLC";
	print "$cmd\n";
	system ( "del /Q $cmd");
}	

sub exitJREStarter {
	stopAllWithoutConfirmation();
	$mw->g_destroy();
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

sub checkMIDS{
	if (confirmAction("Use MIDS terminal ?") eq "yes") {
		$useMIDS =1;
		$useMIDSLabel = "MIDS";
		#$mids_db = $mids_db_mids;
		#acquittementAction("TDL router shall be restarted !");
	}
	else{
		$useMIDS = 0;
		$useMIDSLabel = "MIDS not used";
		print "$useMIDSLabel\n" if($debug);
		#$mids_db = $mids_db_local;
	}
	# mise à jour de la commande du TDL ROUTER fonction du MIDS
	$TDL_ROUTER->{'START'} = "cd $HOME_DIR/Scripts; ./start_TDL_ROUTER $useMIDS";
	return 0;
}

sub updateContextFile {
	print "pscp jfacc_op\@$putty_session:$HOME_DIR/Ops/TDL_ROUTER/$contextFileTDL $HOME_WIN_DIR\\TOPLINKCOM\\properties\\$contextFileTLC \n" if( $debug);
	system("pscp jfacc_op\@$putty_session:$HOME_DIR/Ops/TDL_ROUTER/$contextFileTDL $HOME_WIN_DIR\\TOPLINKCOM\\properties\\$contextFileTLC");
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
      my $repeat_id = Tkx::after($ms, $repeater);

      return $repeat_id;
 }

sub null{
 	return 0;
 }
 