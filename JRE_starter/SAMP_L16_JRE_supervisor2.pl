 #!/usr/bin/perl -w
# Lancement CWIX 2012 de façon graphique
# Augmentation de la tempo pour les process Windows
# Arrêt et redémarrage du Host TD avec le TDL router
# V3 le 20/1/2013
# Updae suppression Spylinks L16
# Démarrage auto des IHM associé au JREP et TDL
# Arrêt au démarrage du DLIP C3M
# Utilisation de répertoire standart pour les applis JREM DLIPCOM,...
# Step 2 : ajout de la supervisio du JREP Name
# ajout de la configuration des tag des routes pour le DLIPCOM
# ajout de la sélection du mode useMIDS
# modifié pour ETO JREAP V3R1E0
#  par S. Mouchot le  28/08/13

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use JreProcessorsConfiguration;
use DlipComOperationalConfiguration;
Tkx::package_require("style");
Tkx::style__use("as", -priority => 70);
#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $HOME_DIR="/export/home/thales";
my $LOG_DIR = "E:\\SAMP_L16_JRE\\LOG";
my $RECORDING_DIR = "E:\\SAMP_L16_JRE\\RECORDING";
my $CONFIG_DIR = "E:\\SAMP_L16_JRE\\CONFIGURATION";
my $putty_session = "JRE-Gateway";
my $rack_Lynx_IP = "24.1.1.1";
my $tdl_ip = "172.16.244.104";
my $jrepName;
# Supervision MIDS
my $mids_db = "MIDS_DB";
my $mids_db_local = "localhost";
my $jrepName = "SAMP";
my $mids_db_present = 0;
my $mids_db_connected = 0;
my $mids_status_label = "not present";
my $useMIDS = 0;
my $useMIDSLabel = "MIDS";
my $first_ping_mids = 0;
my $first_disconnection_mids = 0;
my $systemStart =1;

# Supervision cnx DLP
my $dlp_port_num = '1024';
my $dlp_connected = 0;

# Supervision cnx JREP
my $jrep_port_num = '50091';
my $jrep_connected = 0;

my $synchro_lynx_ok = 1;
my $synchro_sun_ok = 1;


my @TaskList = ("JREM", "JREP",   
				 "TDL_ROUTER");

my @solaris_process_list;
my @windows_process_list;

# ordre d'affichage des boutons
my $i = 0;
my $STATUS_NUM = $i;
$i++;
my $JREP_NAME_NUM = $i;
$i++;
my $JREP_CNX_NUM = $i;
$i++;
my $DLP_CNX_NUM = $i;
$i++;
my $MIDS_CNX_NUM = $i;
$i++;
my $CONFIG_LABEL_NUM = $i;
$i++;
my $USE_MIDS_NUM = $i;
$i++;
my $ROUTE_ID_NUM = $i;
$i++;
my $EXE_LABEL_NUM = $i;
$i++;
my $JREM_NUM = $i;
$i++;
my $JREP_NUM = $i;
$i++;
my $DLIPCOM_NUM= $i;
$i++;
my $TDL_ROUTER_NUM = $i;
$i++;
my $TOPLINKSPY_LABEL_NUM = $i;
$i++;
my $TOPLINKSPY_NUM = $i;
$i++;
my $TMCT_LABEL_NUM = $i;
$i++;
my $TMCT_NUM = $i;
$i++;

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
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_HOST_TD $useMIDS >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_HOST_TD >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "host_driver_test.log",
				'LOG_DIR' 	=> "$HOME_DIR/HOST_TD",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_HOST_TD_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

local $L16_TD = {	'NUM'		=> $L16_TD_NUM, 
				'EXE' 		=> "./l16_test_driver",
				'RUN_DIR' 	=> "$HOME_DIR/Scripts",
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_L16_TD >& /dev/null &",
				'STOP' 		=> "cd $HOME_DIR/Scripts; ./stop_L16_TD >& /dev/null &",
				'CMD' 		=> "undefined",
				'LOG' 		=> "l16_driver_test.log",
				'LOG_DIR' 	=> "$HOME_DIR/L16_TD",
				'CLEAR_LOG' 	=> "cd $HOME_DIR/Scripts; ./clear_L16_TD_log",
				'OPERATING_SYST'	=> "SOLARIS"
};

# Process Windows

local $JREM = {	'NUM'		=> $JREM_NUM, 
				'EXE' 		=> "launch.bat",
				'RUN_DIR' 	=> "E:\\SAMP_L16_JRE\\JREM\\bin",
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
				'RUN_DIR' 	=> "E:\\SAMP_L16_JRE\\DLIPCOM\\",
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
				'RUN_DIR' 	=> "E:\\SAMP_L16_JRE\\ContextFileBuilder\\",
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
				'RUN_DIR' 	=> "E:\\SAMP_L16_JRE\\TOPLINKSPY\\TopLink\-Spy",
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
				'RUN_DIR' 	=> "E:\\SAMP_L16_JRE\\DLTE_S16_TDL",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLTE_S16_TDL",
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
				'RUN_DIR' 	=> "E:\\THALES\\TMCT\\bin\\",
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

my $HframeSchemaMain;
my @HframeSchema;
my @VframeSchema;

if ($opt_h) { 
	print  "Lancement station JRE L16 de façon graphique\n";
	exit(0);
}
  
if(! $opt_h) {
	my $ref = JreProcessorsConfiguration::readConfigFile();
	#print "$ref\n";
	$jrepName = JreProcessorsConfiguration::getJrepName();
	$mw = Tkx::widget->new(".");
	$mw->g_wm_title( "TOPLINK Supervisor" );
	$mw->configure(-menu => mk_menu($mw));	
	$jrepName = JreProcessorsConfiguration::getJrepName();
	print "$jrepName\n";
	$HframeSchemaMain = $mw->new_ttk__frame();
	initSchemaButton();
	$HframeSchemaMain->g_grid();
	$mw->g_wm_geometry("+10+10");
	# Attente synchro SUN
	my $SUN_SYNCHRO_STATE = 0;
	while ( ! $SUN_SYNCHRO_STATE){
		my $NTP_CMD = `plink $putty_session \"ntpq -p\"`;
		print "wait for SUN synchro...";
		$SUN_SYNCHRO_STATE = 1 if($NTP_CMD =~ /\*TIME_SERVER/ || $synchro_sun_ok);
		sleep 1;
	}
	print "SUN Synchro ok !\n";
	# Choix du terminal MIDS
	#checkMIDS();
	updateStatusAll();
	startAll();	
	timer(3000);
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
      		-command => \&restartAll
      );
      $process->add_command(
      		-label => "Stop All",
      		-underline => 0,
      		-command => \&stopAll
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
	my ($width1, $width2, $width3) = (15, 4, 2);
	my ($height1, $height2, $height3) = (4, 2, 1);
	print "$width1, $width2\n";

	$traitMultipleVerticalPhoto = Tkx::image_create_photo("trait_multiple_vertical", -file =>  "Images/trait_multiple_vertical.gif");
	$traitSimpleVerticalPhoto = Tkx::image_create_photo("trait_simple_vertical", -file => "Images/trait_simple_vertical.gif");
	$traitSimpleVerticalOKPhoto= Tkx::image_create_photo("trait_simple_vertical_OK", -file => "Images/trait_simple_vertical_OK.gif");
	$traitSimpleVerticalKOPhoto= Tkx::image_create_photo("trait_simple_vertical_KO", -file => "Images/trait_simple_vertical_KO.gif");
	$traitSimpleHorizontalPhoto= Tkx::image_create_photo("trait_simple_horizontal", -file => "Images/trait_simple_horizontal.gif");
	$traitSimpleHorizontalOKPhoto= Tkx::image_create_photo("trait_simple_horizontal_OK", -file => "Images/trait_simple_horizontal_OK.gif");
	$traitSimpleHorizontalKOPhoto= Tkx::image_create_photo("trait_simple_horizontal_KO", -file => "Images/trait_simple_horizontal_KO.gif");
	
	$HframeSchemaMain = $mw->new_frame(-background => 'white');
	foreach my $i (0..6){
		foreach my $j (0..8){
			#print "$j, $i\n";
			$HframeSchema[$j*10+$i] = $HframeSchemaMain->new_ttk__frame();
			$HframeSchema[$j*10+$i]-> g_grid(-row => $j, -column => $i);
		}
	}
	# Row 0
	$HframeSchema[0]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 0, -column => 0);
	$HframeSchema[1]->new_label( -width => $width1, -anchor => 'w',  -background => 'white', -height => $height3) ->g_grid(-row => 0, -column => 1);
	$HframeSchema[2]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 0, -column => 2);
	$HframeSchema[3]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 0, -column => 3);
	$HframeSchema[4]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 0, -column => 4);
	$HframeSchema[5]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 0, -column => 5);
	$HframeSchema[6]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 0, -column => 6);
	# Row 1
	$HframeSchema[10]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 1, -column => 0);	
	$HframeSchema[11]->new_label( -text => "TOPLINK CORE : ",-width => $width1, 
								 -anchor => 'w',  -background => 'white', -height => $height1) ->g_grid(-row => 1, -column => 1);
	$HframeSchema[12]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height1) ->g_grid(-row => 1, -column => 2);
	# Bouton DLIPCOM
	$startStopButton[$DLIPCOM_NUM] = $HframeSchema[13]->new_button( -command => [\&startStopProcess, "DLIPCOM"],
								 -text => "DLIPCOM", -width => $width1, -background => 'grey', -height => $height1);
	$startStopButton[$DLIPCOM_NUM]->g_grid(-row => 1, -column => 3);
	$HframeSchema[14]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height1, -anchor => 'center') ->g_grid(-row => 1, -column => 4);
	# Bouton JREM
	$startStopButton[$JREM_NUM] = $HframeSchema[15]->new_button( -command => [\&startStopProcess, "JREM"],
								 -text => "JREM", -width => $width1, -background => 'grey', -height => $height1);
	$startStopButton[$JREM_NUM]->g_grid(-row => 1, -column => 5);
	$HframeSchema[16]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 1, -column => 6);
	# Row 2
	$HframeSchema[20]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 2, -column => 0);	
	$HframeSchema[21]->new_label( -width => $width1, 
								 -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 2, -column => 1);
	$HframeSchema[22]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 2, -column => 2);
	# Connexion DLIPCOM
	$DLIPCOM_CNX_LABEL = $HframeSchema[23]->new_label( -image => $traitSimpleVerticalPhoto,  -borderwidth => 0);
	$DLIPCOM_CNX_LABEL->g_grid(-row => 0, -column => 0);
	$HframeSchema[23]->g_grid(-row => 2, -column => 3);
	
	$HframeSchema[24]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 2, -column => 4);
	$HframeSchema[25]->new_label( -image => $traitSimpleVerticalPhoto,  -borderwidth => 0)->g_grid(-row => 2, -column => 5);
	$HframeSchema[26]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 2, -column => 6);
	# Row 3	
	$HframeSchema[30]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 3, -column => 0);
	# Bouton Host platform
	$startStopButton[0] =$HframeSchema[31]->new_label( -text => "$jrepName", -width => $width1, 
								 -anchor => 'e',  -background => 'grey', -height => $height1, -anchor => 'center');
	$startStopButton[0]->g_grid(-row => 3, -column => 1);
	$DLP_CNX_LABEL = $HframeSchema[32]->new_label( -image => $traitSimpleHorizontalKOPhoto,  -borderwidth => 0);
	$DLP_CNX_LABEL->g_grid(-row => 0, -column => 0);
	$HframeSchema[32]->g_grid(-row => 3, -column => 2);
	# Bouton TDL router
	$startStopButton[$TDL_ROUTER_NUM] = $HframeSchema[33]->new_button( -command => [\&startStopProcess, "TDL_ROUTER"],
								 -text => "TDL Router", -width => $width1, -background => 'grey', -height => $height1);
	$startStopButton[$TDL_ROUTER_NUM]->g_grid(-row => 3, -column => 3);
	# Connexion JREP
	$JREP_CNX_LABEL = $HframeSchema[34]->new_label( -image => $traitSimpleHorizontalKOPhoto,  -borderwidth => 0);
	$JREP_CNX_LABEL->g_grid(-row => 0, -column => 0);
	$HframeSchema[34]->g_grid(-row => 3, -column => 4);
	# Bouton JREP
	$startStopButton[$JREP_NUM] = $HframeSchema[35]->new_button( -command => [\&startStopProcess, "JREP"],
								 -text => "JRE Processor", -width => $width1, -background => 'grey', -height => $height1);
	$startStopButton[$JREP_NUM]->g_grid(-row => 3, -column => 5);
	$HframeSchema[36]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 3, -column => 6);
	# Row 4		
	$HframeSchema[40]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 4, -column => 0);
	$HframeSchema[41]->new_label( -width => $width1, -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 4, -column => 1);
	$HframeSchema[42]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 4, -column => 2);
	# MIDS Connexion
	$MIDS_CNX_LABEL = $HframeSchema[43]->new_label( -image => $traitSimpleVerticalKOPhoto,  -borderwidth => 0);
	$MIDS_CNX_LABEL->g_grid(-row => 0, -column => 0);
	$HframeSchema[43]->g_grid(-row => 4, -column => 3);
	
	$HframeSchema[44]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 4, -column => 4);
	my $label = $HframeSchema[45]->new_label( -image =>$traitMultipleVerticalPhoto,  -borderwidth => 0);
	$label->g_grid(-row => 0, -column => 0);
	$HframeSchema[45]->g_grid(-row => 4, -column => 5);
	$HframeSchema[46]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 4, -column => 6);
	# Row 5		
	$HframeSchema[50]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 5, -column => 0);
	$HframeSchema[51]->new_label( -width => $width1, -anchor => 'e',  -background => 'white', -height => $height1, -anchor => 'center') ->g_grid(-row => 5, -column => 1);
	$HframeSchema[52]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height1, -anchor => 'center') ->g_grid(-row => 5, -column => 2);
	# Bouton MIDS
	$startStopButton[$MIDS_CNX_NUM] = $HframeSchema[53]->new_label( -textvariable => \$useMIDSLabel, -width => $width1, -background => 'grey', -height => $height1);
	$startStopButton[$MIDS_CNX_NUM]->g_grid(-row => 5, -column => 3);
	$HframeSchema[54]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height1, -anchor => 'center') ->g_grid(-row => 5, -column => 4);
	$HframeSchema[55]->new_label( -width => $width1, -background => 'white', -height => $height1)->g_grid(-row => 5, -column => 5);
	$HframeSchema[56]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 5, -column => 6);
	# Row 6		
	$HframeSchema[60]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 6, -column => 0);
	$HframeSchema[61]->new_label( -width => $width1, -anchor => 'w',  -background => 'white', -height => $height3) ->g_grid(-row => 6, -column => 1);
	$HframeSchema[62]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 6, -column => 2);
	$HframeSchema[63]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 6, -column => 6);
	$HframeSchema[64]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 6, -column => 4);
	$HframeSchema[65]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 6, -column => 5);
	$HframeSchema[66]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 6, -column => 6);
	# Row 7	
	$HframeSchema[70]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 7, -column => 0);
	$HframeSchema[71]->new_label( -text => "TOOLS :", -width => $width1, 
								 -anchor => 'w',  -background => 'white', -height => $height2 ) ->g_grid(-row => 7, -column => 1);
	$HframeSchema[72]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 7, -column => 2);
	# Bouton TMCT
	$startStopButton[$TMCT_NUM] = $HframeSchema[73]->new_button( -command => [\&startStopProcess, "TMCT"],
								 -text => "TMCT", -width => $width1, -background => 'grey', -height => $height2);
	$startStopButton[$TMCT_NUM]->g_grid(-row => 7, -column => 3);
	
	$HframeSchema[74]->new_label( -width => $width2, 
								 -anchor => 'e',  -background => 'white', -height => $height2, -anchor => 'center') ->g_grid(-row => 7, -column => 4);
	# Bouton Toplinksspy
	$startStopButton[$TOPLINKSPY_NUM] = $HframeSchema[75]->new_button( -command => [\&startStopProcess, "TOPLINKSPY"],
								 -text => "Toplink Spy", -width => $width1, -background => 'grey', -height => $height2);
	$startStopButton[$TOPLINKSPY_NUM]->g_grid(-row => 7, -column => 5);
	
	$HframeSchema[76]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 7, -column => 6);
	# Row 8	
	$HframeSchema[80]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 8, -column => 0);
	$HframeSchema[81]->new_label( -width => $width1, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 8, -column => 1);
	$HframeSchema[82]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 8, -column => 2);
	$HframeSchema[83]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 8, -column => 6);
	$HframeSchema[84]->new_label( -width => $width2, -anchor => 'e',  -background => 'white', -height => $height3, -anchor => 'center') ->g_grid(-row => 8, -column => 4);
	$HframeSchema[85]->new_label( -width => $width1, -background => 'white', -height => $height3)->g_grid(-row => 8, -column => 5);
	$HframeSchema[86]->new_label( -width => $width3, -background => 'white', -height => $height3)->g_grid(-row => 8, -column => 6);
	
	
	
}

sub restartAll {
	if(confirmAction ("Start All Process ?") eq "yes"){
		foreach my $task (@TaskList){
			if(($task ne "JREP") && ($task ne "TDL_ROUTER") && ($task ne "DLIP_C3M")){
				stopProcess($task);
			}
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
			#startProcessWithoutConfirmation("TOPLINKCOM");						
			#startProcessWithoutConfirmation("DLIP");
			#startProcessWithoutConfirmation("SLP");
		#}
	}	
}

sub restartAllWithoutConfirmation {
	foreach my $task (@TaskList){



		print "stop $task ...\n";
		stopProcessWithoutConfirmation($task);
		
	}
	foreach my $task (@TaskList){
		print "stop $task ...\n";
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




















	if(confirmAction ("Stop All Process ?") eq "yes"){
	
		foreach my $task (@TaskList){
			print "stop $task ...\n";
			stopProcessWithoutConfirmation($task);
		}
	}

		







}

sub updateStatusAll {
	updateStatusMIDS();
	updateStatusDLP();
	updateStatusJREP();
	updateWindowsProcessList();
	updateSolarisProcessList();
	foreach my $task (@TaskList){
		updateStatusProcess($task);
	} 
}
		
sub startProcess {
	my $task = shift;
	print "start $task\n";
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if( ! isSolarisProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){
			if($task eq "TDL_ROUTER"){
				checkMIDS();
				#startProcessWithoutConfirmation("TOPLINKCOM");				
			}
			if($task eq "JREP"){
				#startProcessWithoutConfirmation("JREM");				
			}
			if($task eq "DLIP"){
				#startProcessWithoutConfirmation("TI");				
			}
			startSolarisProcess ($task); 
			sleep 1;
			updateSolarisProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		if( ! isWindowsProcessRunning ($task) && confirmAction ("Start $task ?") eq "yes"){









			startWindowsProcess($task);
			sleep 5 if($task eq "JREM" || $task eq "TI" || $task eq "TOPLINKCOM");

			updateWindowsProcessList();
		}
	}
	updateStatusProcess($task);
}

sub startProcessWithoutConfirmation {
	my $task = shift;
	print "start $task\n";
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if( ! isSolarisProcessRunning ($task) ){
			if($task eq "TDL_ROUTER"){
				checkMIDS();
				#stopProcessWithoutConfirmation("TOPLINKCOM");
				#checkMIDS();
				#startProcessWithoutConfirmation("TOPLINKCOM");				
			}
			if($task eq "JREP"){
				#startProcessWithoutConfirmation("JREM");				
			}
			if($task eq "DLIP"){
				#startProcessWithoutConfirmation("TI");				
			}
			startSolarisProcess ($task); 
			#sleep 1;
			updateSolarisProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		if( ! isWindowsProcessRunning ($task)){
			startWindowsProcess( $task);
			sleep 5 if($task eq "JREM" || $task eq "TI" || $task eq "TOPLINKCOM");

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






	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		if(isSolarisProcessRunning ($task) && confirmAction ("Stop $task ?") eq "yes"){
			stopSolarisProcess ($task);








			updateSolarisProcessList();
		}
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){



		#acquittementAction( "Sorry ! WINDOWS process must be stopped using HMI.");
		if ( $task eq "SLP" && confirmAction ("Stop $task ?") eq "yes"){
			stopWindowsProcess($task);












		}		
	}
	print " update $task\n";
	#updateStatusProcess($task) ;
}

sub updateStatusProcess {
	my $task = shift;
	if($$task->{'OPERATING_SYST'}eq "SOLARIS" ) {
		if ( isSolarisProcessRunning($task)) {
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
			foreach my $task (@TaskList) {
				mkdir($task);
				chdir($task);
				my $log_dir = $$task->{"LOG_DIR"};	
				if($$task->{"OPERATING_SYST"} eq "LYNX" && confirmAction("Save $task log ?")) {
					#system("rcp -b DLIP_C3M.dlip:$log_dir\/\*.log .") if ( confirmAction("Save C3M log ?"));
				}
			# retrieve DLIP log
				if($$task->{"OPERATING_SYST"} eq "SOLARIS" && confirmAction("Save $task log ?")) {
					#print "pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir\\$task\n";
					system("pscp thales\@$putty_session:$log_dir\/\*.log $LOG_DIR\\$newDir\\$task") ;
					system("pscp thales\@$putty_session:$log_dir\/\*.xdh $LOG_DIR\\$newDir\\$task");
					system("pscp thales\@$putty_session:$log_dir\/\*.fim $LOG_DIR\\$newDir\\$task");
					
				}
				chdir ("..");
			}
		}
	}
}

sub clearLog{
	my $clear_cmd = $TDL_ROUTER->{'CLEAR_LOG'};
	if(confirmAction("Clear TDL router Log File ?")){
		system("plink $putty_session $clear_cmd") ;
		#$clear_cmd = $HOST->{'CLEAR_LOG'};
		#system("plink $putty_session $clear_cmd");
		#$clear_cmd = $L16_TD->{'CLEAR_LOG'};
		#system("plink $putty_session $clear_cmd");
	}
	$clear_cmd = $JREP->{'CLEAR_LOG'};
	system("plink $putty_session $clear_cmd") if(confirmAction("Clear JRE Log File ?"));
	acquittementAction("That's all folk !");
	# suppression des log du DLIPCOM
	system("del /Q E:\\SAMP_L16_JRE\\DLIPCOM\\log\\*");
	# suppression des log du JREM
	system("del /Q E:\\SAMP_L16_JRE\\JREM\\log\\*");
}

sub exitJREStarter {
	stopAllWithoutConfirmation();
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

sub updateConnexionList {
	my $port_Alliance = 50001;
	my $connexion_list = `plink $putty_session netstat -a `;
	print "$connexion_list";
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

sub updateStatusDLP {
	isDLPConnected();
	if($dlp_connected ) {
		$DLP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_OK');
	}
	else { 
		$DLP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_KO');
	}
}

sub updateStatusJREP {
	isJREPConnected();
	if($jrep_connected ) {
		$JREP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_OK');
	}
	else { 
		$JREP_CNX_LABEL->configure(-image => 'trait_simple_horizontal_KO');
	}
}

sub updateStatusMIDS {
	if($useMIDS){
	isMIDSPresent();
	isMIDSConnected();
	# le système tourne déjà
	if($mids_db_present){
			if($mids_db_connected ) {
				$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_OK');
				$mids_status_label = "Connected";
			}
			else { 
				$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_KO');
				$mids_status_label = "Present";
			}
			$startStopButton[$MIDS_CNX_NUM]->configure(-background => 'green');
	}
	else{
			$mids_status_label = "not Present";
			$startStopButton[$MIDS_CNX_NUM]->configure(-background => 'red');
			$MIDS_CNX_LABEL->configure(-image => 'trait_simple_vertical_KO');
	}
	print "update mids_db_present = $mids_db_present \n";
	}
	return 0;
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
	print "etat connection MIDS = $mids_db_connected \n";
	my $result = `plink $putty_session \"netstat -a | grep .1024  | grep -i MIDS_DB \"`;
	if($result =~ /ESTABLISHED/){
		$mids_db_connected = 1 ;	
		print "$result : $mids_db_connected\n";
	}
	else {
		$mids_db_connected = 0 ;
	}
	
	return $mids_db_connected;
}

sub isDLPConnected {
	$dlp_connected = 0;
	my $result = `plink $putty_session \"netstat -a | grep .$dlp_port_num  | grep -i $tdl_ip \"`;
	$dlp_connected = 1 if($result =~ /ESTABLISHED/);
	print "result : $dlp_connected\n";
	return $dlp_connected;
}

sub isJREPConnected {
	$jrep_connected = 0;
	my $result = `plink $putty_session \"netstat -a | grep .$jrep_port_num \"`;
	$jrep_connected = 1 if($result =~ /ESTABLISHED/);
	print "result : $jrep_connected\n";
	return $jrep_connected;
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
		#acquittementAction("TDL router shall be restarted !");
	}
	else{
		$useMIDS = 0;
		$useMIDSLabel = "MIDS not used";
		print "$useMIDSLabel\n";
		$mids_db = $mids_db_local;
	}
	# mise à jour de la commande HOST TD en fonction du MIDS
	#$HOST->{'START'} = "cd $HOME_DIR/Scripts; ./start_HOST_TD $useMIDS >& /dev/null &";
	return 0;
}

sub retrieveConfiguration {
	if(confirmAction("Retrieve configuration ? ") eq "yes" ){
		mkdir($CONFIG_DIR) if( ! -d $CONFIG_DIR);
		if (-d  "$CONFIG_DIR"){
			foreach my $task (@TaskList) {
				if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
					mkdir("$CONFIG_DIR\\$task") if( ! -d "$CONFIG_DIR\\$task"); 
					my $remote_config_dir = $$task->{"CONFIG_DIR"};				
					# retrieve DLIP config
					print "copie de $remote_config_dir vers $CONFIG_DIR\\$task \n" if($debug == 2);
					if ( $task eq "DLIP"){
						system("pscp $user\@$putty_session:$remote_config_dir\/martha_main.cfg $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/martha_main.trc $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/MP.Param $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/C2_AT.cfg $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/C2_NATO.cfg $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/SNCP.xml $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/fichier_init_MIDS.min $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/init_GF $CONFIG_DIR\\$task") ;
					}
					if ( $task eq "TDL_ROUTER"){					
						system("pscp $user\@$putty_session:$remote_config_dir\/tdl_router_main.cfg $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/tdl_router_main.trc $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/L16_user.Param $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/L16_master.Param $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/standalone_user.xml $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/standalone_master.xml $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/midsRegistration.xml $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/SIMPLE_IF.xml $CONFIG_DIR\\$task") ;
					}
					if ( $task eq "JREP"){				
						system("pscp $user\@$putty_session:$remote_config_dir\/jre_config.xsd $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/parameters.txt $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/conf_jrep.xml $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/jre_param.xsd $CONFIG_DIR\\$task") ;
						system("pscp $user\@$putty_session:$remote_config_dir\/param_jrep.xml $CONFIG_DIR\\$task") ;
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
					print "copie de $CONFIG_DIR\\$task vers $remote_config_dir \n" if( $debug == 2);
					if ( $task eq "DLIP" && confirmAction("Update DLIP configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\mct_main.cfg $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\mct_main.trc $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\MP.Param $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\C2_AT.cfg $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\C2_NATO.cfg $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\SNCP.xml $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\fichier_init_MIDS.min $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\init_GF $user\@$putty_session:$remote_config_dir\/ ") ;
					}
					if ( $task eq "TDL_ROUTER"  && confirmAction("Update TDL ROUTER configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\tdl_router_main.cfg $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\tdl_router_main.trc $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\L16_user.Param $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\L16_master.Param $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\standalone_user.xml $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\standalone_master.xml $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\midsRegistration.xml $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\SIMPLE_IF.xml $user\@$putty_session:$remote_config_dir\/ ") ;
					}
					if ( $task eq "JREP" && confirmAction("Update JRE configuration Files ?") eq "yes" ){					
						system("pscp $CONFIG_DIR\\$task\\jre_config.xsd $user\@$putty_session:$remote_config_dir\/") ;
						system("pscp $CONFIG_DIR\\$task\\parameters.txt $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\conf_jrep.xml $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\jre_param.xsd $user\@$putty_session:$remote_config_dir\/ ") ;
						system("pscp $CONFIG_DIR\\$task\\param_jrep.xml $user\@$putty_session:$remote_config_dir\/ ") ;
					}
			}
		}
		acquittementAction("Configuration updated !");
	}
}

sub saveRecording {
	if(confirmAction("Save Reoording File ? It will stop all applications !") eq "yes" ){
		stopAllWithoutConfirmation();
		mkdir($RECORDING_DIR) if( ! -d $RECORDING_DIR);
		if (-d  "$RECORDING_DIR"){
			my $sec,$min,$hour,$md,$mon,$year,$wd,$yd,$isdst;
			($sec,$min,$hour,$md,$mon,$year,$wd,$yd,$isdst) = localtime () ;
			my $jc_year = $year + 1900;
			my $normal_mon = $mon + 1 ;
			my $DATE_DIR = "$jc_year\_$normal_mon\_$md\_$hour\_$min\_$sec" ;
			mkdir("$RECORDING_DIR\\$DATE_DIR") ;
			my $remote_recording_dir = "$HOME_DIR/TDL_ROUTER";				
			# retrieve recording TDL ROUTER
			print "pscp $user\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR\n" if( $debug != 0 ) ;
			system("pscp $user\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR") ;
			$remote_recording_dir = "$HOME_DIR/JREP/trace";				
			# retrieve recording JREP
			print "pscp $user\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR\n" if( $debug != 0 ) ;
			system("pscp $user\@$putty_session:$remote_recording_dir\/\*.rcd $RECORDING_DIR\\$DATE_DIR") ;
		}
		clearRecording();
	}
}

sub clearRecording() {
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