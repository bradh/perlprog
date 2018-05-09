
package ProcessConfig ;

my $HOME_DIR="/export/home/thales";
# ordre d'affichage des boutons
my $i = 1;
local $JRE_LABEL_NUM = $i;
$i++;
local $TDL_ROUTER_NUM = $i;
$i++;
local $DLIPCOM_NUM= $i;
$i++;
local $JREP_NUM = $i;
$i++;
local $JREM_NUM = $i;
$i++;
local $SPYLINKS_LABEL_NUM = $i;
$i++;
local $SPYLINKS_JRE_NUM = $i;
$i++;
local $TMCT_LABEL_NUM = $i;
$i++;
local $TMCT_NUM = $i;
$i++;
local $HOST_NUM = $i;
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
				'START' 	=> "rsh 24.1.1.4 -l dlip cd Ops;start",
				'STOP' 		=> "rsh 24.1.1.4 -l dlip cd Ops;stop",
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
				'START' 	=> "cd $HOME_DIR/Scripts; ./start_HOST_TD >& /dev/null &",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLIPmng_V1R1E5_NAWAS\\DLIPL16Mng-Delivery\\",
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
				'RUN_DIR' 	=> "E:\\THALES\\JREM_SAMPT\\bin",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLIPCOM_SAMPT\\",
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
				'RUN_DIR' 	=> "E:\\THALES\\ContextFileBuilder_SAMPT\\",
				'WIN_NAME'	=> "ContextFileBuilder",
				'START' 	=> "ContextFileBuilder.bat",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $SPYLINKS_L16 = {	'NUM'		=> $SPYLINKS_L16_NUM, 
				'EXE' 		=> "launch_spylinks.js",
				'RUN_DIR' 	=> "C:\\Program Files\\TCF\\SpyLinks",
				'WIN_NAME'	=> "DLEM",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "E:\\THALES\\Spylinks\\DLEM\\Software\\Logs",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DATASERVER = {	'NUM'		=> 0, 
				'EXE' 		=> "DataServerOnLine.exe",
				'RUN_DIR' 	=> "E:\\THALES\\SpyLinks\\DLVM\\DataServer",
				'WIN_NAME'	=> "DataServer",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLVM = {	'NUM'		=> "0", 
				'EXE' 		=> "DLVM.exe",
				'RUN_DIR' 	=> "E:\\THALES\\SpyLinks\\DLVM\\Software",
				'WIN_NAME'	=> "DLVM.exe",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $SPYLINKS_JRE = {	'NUM'		=> $SPYLINKS_JRE_NUM, 
				'EXE' 		=> "Spy-Links.exe",
				'RUN_DIR' 	=> "E:\\THALES\\Spy\-Links\\SPY\-LINKSV3",
				'WIN_NAME'	=> "Spy-Links v3.0",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "E:\\THALES\\Spylinks\\DLEM\\Software\\Logs",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $AIS = {	'NUM'		=> $AIS_NUM, 
				'EXE' 		=> "AIS.exe",
				'RUN_DIR' 	=> "E:\\THALES\\L16ES\\AIS\\",
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

local $OSIM = {	'NUM'		=> 0, 
				'EXE' 		=> "OSIM.EXE",
				'RUN_DIR' 	=> "E:\\THALES\\OSIM",
				'WIN_NAME'	=> "OSIM",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $MAPPOINT = {	'NUM'		=> 0, 
				'EXE' 		=> "MapPoint.exe",
				'RUN_DIR' 	=> "E:\\THALES\\OSIM",
				'WIN_NAME'	=> "MapPoint",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};

local $DLTE_TDL = {	'NUM'		=> 0, 
				'EXE' 		=> "launch_dltes16.bat",
				'RUN_DIR' 	=> "E:\\THALES\\DLTE_S16_SAMPT_JRE",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLTE_S16_C3M",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLTE_S16_SAMPT_JRE",
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
				'RUN_DIR' 	=> "E:\\THALES\\DLTE_S16_C3M",
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
				'RUN_DIR' 	=> "E:\\THALES\\TMCT\\bin\\",
				'WIN_NAME'	=> "tmct_mono",
				'START' 	=> "undefined",
				'STOP' 		=> "undefined",
				'CMD' 		=> "undefined",
				'LOG' 		=> "undefined",
				'LOG_DIR' 	=> "undefined",
				'CLEAR_LOG' 	=> "undefined",
				'OPERATING_SYST'	=> "WINDOWS"
};
my $toto = $TDL_ROUTER ->{'NUM'};
print "$toto\n";
1