#!/usr/bin/perl -w
# Lancement demo marine de façon graphique
#
#  par S. Mouchot

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use Net::Ping;

#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $putty_session = "JRE-Gateway";

my @HostList = ("JRE-Gateway"); 

local $JRE_Gateway = {
		'ADDRESS_IP' => "192.168.0.66",
		'PING_STATE' => "OFF",
		'NTP_SERVER' => "$NTP_SERVER_NAME",
		'NTP_STATE' => 	"OFF",
		'OPERATING_SYST'	=> "SOLARIS"
};



# Process Lynx
my $DLIP_C3M_NUM = 0;
local $DLIP_C3M = {	'NUM'	=> $DLIP_C3M_NUM, 
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
				'START' 	=> "cd /export/home/thales/scripts; ulimit -s unlimited; export TZ=GMT; ./start_JREP >& /dev/null &",
				'STOP' 		=> "cd /export/home/thales/scripts; ./stop_JREP >& /dev/null &",
				'CMD' 		=> "cd /export/home/thales/scripts; ulimit -s unlimited; export TZ=GMT; ./jre_main >& /dev/null &",
				'LOG' 		=> "jre.log",
				'LOG_DIR' 	=> "/export/home/thales/DLIP",
				'CLEAR_LOG' 	=> "cd /export/home/thales/scripts; ./clear_JREP_log",
				'OPERATING_SYST'	=> "SOLARIS"
};




my	@startButton;
my	@stopButton;
my $widthLabel;
my @Hframe;
my @photo;
my $startActivePhoto;
my $stopActivePhoto;
my $startInactivePhoto;
my $stopInactivePhoto;
my $blankPhoto;	

my $i;

my $mw;

# print $ENV{PWD};
if ($opt_h) { 
	print  "Supervision des machines(présence, synchronisation,...)\n";
	exit(0);
}

if(! $opt_h) {

	$mw = Tkx::widget->new(".", -background => 'grey');
	$mw->g_wm_title( "THALES : System Supervision" );
		
	$widthLabel = 15;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	
	#waiting for SUN synchronization
	my $SUN_SYNCHRO_STATE = 0;
	my $LYNX_SYNCHRO_STATE = 0;
	my $line = 0;
	my $col = 0;
	for my $machine (@hostList)){
		my $p = Net::Ping->new();
		if($p->ping($machine) or $p->ping($$machine->{'ADDRESS_IP'})) {
			print "$machine is alive\n";
			$$machine->{'STATE'} = "ON";
		}
		else {
			print "no answer from $machine\n";
			$$machine->{'STATE'} = "OFF";
		}
		# Affichage du caractère 
		$Hframe[$line] = $mw->new_ttk__frame();
		$photo[$col] = Tkx::image_create_photo( "image$i", -file => "Images/$character.gif");		
		$Hframe[$i]->new_ttk__label( -image => $photo[$i], -width => $widthLabel, -background => 'grey', -anchor => 'w')->g_grid(-column => 0, -row => $i);
		$Hframe[$i]->g_grid(-column => 0, -row => $i, -sticky => 'w');
		if (defined($task)){
			print "init start stop button $$task->{'NUM'}\n";
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
	print "bouton $j $task\n";

	my $exe = $$task->{'EXE'};
	$initialStartPhoto = "startPhoto";
	$initialStopPhoto = "stopInactivePhoto";	
	$Hframe[$j]->new_ttk__label(-text  => "$task : ", -width => $widthLabel,-anchor => 'e')->g_grid(-column => 2, -row => $j, -sticky => 'w');
	$stopButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&stopProcess, $task],
								-image => $initialStopPhoto);
	#$stopButton[$j]->configure( -borderwidth => 15);
	$stopButton[$j]->g_grid(-column => 3, -row => $j, -sticky => 'w');
	$startButton[$j] = $Hframe[$j]->new_ttk__button(-command => [\&startProcess, $task],
								-image => $initialStartPhoto);
	$startButton[$j]->g_grid(-column => 4, -row => $j, -sticky => 'w');
}

sub startAll {
	foreach my $task (@TaskList){
		startProcess($task);
		#sleep 1;
		updateStatusProcess($task);
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
	print "$task\n";
	my $image = $startButton[$$task->{'NUM'}]->cget('-image');
	
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		startLynxProcess($$task->{'START'}) if($image eq "startInactivePhoto" && ! isLynxProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "yes");
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		startSolarisProcess ($$task->{'START'}) if($image eq "startInactivePhoto" && ! isSolarisProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "yes");
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($$task->{'START'}) if($image eq "startInactivePhoto" && ! isWindowsProcessRunning ($$task->{'EXE'}) && confirmAction ("Start $task ?") eq "yes");
	}
}

sub stopProcess {
	my $task = shift;
	my $image = $stopButton[$$task->{'NUM'}]->cget('-image');
	print "$task\n";
	if($$task->{'OPERATING_SYST'} eq "LYNX"){
		stopLynxProcess($$task->{'STOP'}) if($image eq "stopInactivePhoto" && isLynxProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "yes");
	}
	if($$task->{'OPERATING_SYST'} eq "SOLARIS"){
		stopSolarisProcess ($$task->{'STOP'}) if($image eq "stopInactivePhoto" && isSolarisProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "yes");
	}
	if($$task->{'OPERATING_SYST'} eq "WINDOWS"){
		startWindowsProcess($$task->{'Stop'}) if($image eq "stopInactivePhoto" && isWindowsProcessRunning ($$task->{'EXE'}) && confirmAction ("Stop $task ?") eq "yes");
	}
}





sub stopEXCELProcess {
	my $PID = isWindowsProcessRunning("EXCEL.EXE");
	while ($PID){
		stopWindowsProcess("EXCEL.EXE");
		$PID = isWindowsProcessRunning("EXCEL.EXE");
	}
}

sub updateSpyLinksState {
		if (isWindowsProcessRunning ($SPY->{'WIN_NAME'}) ){
		$stopButton[$SPY->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$SPY->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$SPY->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$SPY->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DLVM->{'WIN_NAME'}) ){
		$stopButton[$DLVM->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$DLVM->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DLVM->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$DLVM->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	if (isWindowsProcessRunning ($DATASERVER->{'WIN_NAME'}) ){
		$stopButton[$DATASERVER->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$DATASERVER->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$DATASERVER->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$DATASERVER->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
}			

sub updateStatusProcess {
	my $task = shift;
	if($$task->{'OPERATING_SYST'}eq "SOLARIS" && isSolarisProcessRunning($$task->{'EXE'})) {
		#$stopButton[$$task->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		#$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
		$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	else {
		$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	if($$task->{'OPERATING_SYST'}eq "LYNX" && isLynxProcessRunning($$task->{'EXE'})) {
		$stopButton[$stask->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
	}
	if ($$task->{'OPERATING_SYST'}eq "WINDOWS" && isWindowsProcessRunning ($$task->{'EXE'})){
		$stopButton[$$task->{'NUM'}]->configure(-image => 'stopInactivePhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startPhoto');
	}
	else {
		$stopButton[$$task->{'NUM'}]->configure(-image => 'stopPhoto');
		$startButton[$$task->{'NUM'}]->configure(-image => 'startInactivePhoto');
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
	my $PID = -1;
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


