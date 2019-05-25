#!/usr/bin/perl -w
# Lancement demo marine de facon graphique
#
#  par S. Mouchot

use Getopt::Std;
use strict;
use Tkx;
use threads;

#require Tk::MenuButton;
my $opt_h;
getopts("h");

my $putty_session = "SUN_CDCD_JRE";

my $LOG_DIR = "C:\\LOG";

my @EXE_List;

my $DLIP_NAME = "DLIP JRE";
my $DLIP_EXE = "altbmd1c_main";
my $DLIP_RUN_DIR = "/export/home/thales/DLIP";
my $DLIP_CMD = "cd $DLIP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; export Startup_Mode=SY_LIVE; export Startup_State=Active; ./$DLIP_EXE >& /dev/null &";
my $DLIP_LOG = "altbmd1c_main.log";
my $DLIP_LOG_DIR ="$DLIP_RUN_DIR";

my $JREP_NAME = "JREP";
my $JREP_EXE = "jre_main";
my $JREP_RUN_DIR = "/export/home/thales/JREP/exe";
my $JREP_CMD = "cd $JREP_RUN_DIR; ulimit -s unlimited; export TZ=GMT; ./$JREP_EXE >& /dev/null &";
my @JREP_LOG = ("jre.log", "jre-1.log");
my $JRE_LOG_DIR = "/export/home/thales/JREP/trace";

my $DLIPMng_NAME = "DLIP Mng";
my $DLIPMng_EXE = "launcher.bat";
my $DLIPMng_WIN_NAME = "launcher.bat";
my $DLIPMng_RUN_DIR = "E:\\THALES\\DLIPmng_V1R1E5_Nobel_Ardent\\DLIPL16Mng-Delivery";

my $JREM_NAME = "JREM";
my $JREM_EXE = "launch.bat";
my $JREM_WIN_NAME = "JRE Management";
my $JREM_RUN_DIR = "E:\\THALES\\JREM_V14R0_Noble_Ardent\\bin";

my $SPY_NAME ="SPYLINKS";
my $SPY_EXE = "launch_spylinks.js";
my $SPY_WIN_NAME = "DLEM";
my $SPY_RUN_DIR = "E:\\THALES\\SpyLinks";

my $DATASERVER_NAME = "DATASERVER";
my $DATASERVER_EXE = "";
my $DATASERVER_WIN_NAME = "DataServer";
my $DATASERVER_RUN_DIR = "";

my $DLVM_NAME = "DLVM";
my $DLVM_EXE = "launch_dlvm.js";
my $DLVM_WIN_NAME = "DLVM";
my $DLVM_RUN_DIR = "E:\\THALES\\SpyLinks";

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
	print  "Lancement station JRE L16 de facon graphique\n";
	exit(0);
}

if(! $opt_h) {
	
	$mw = Tkx::widget->new(".", -background => 'grey');
	$mw->g_wm_title( "THALES : JRE Starter" );
	
	
	$widthLabel = 10;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	
	my $string = "JRE Starter ";
	
#	for $i (0 .. (length($string)-1)){
	for $i (0.. 2){
		my $character = substr($string, $i, 1);
		print "$character\n";
		 if($character =~ /\s/){
		 	$character = "Blank";
		 }
		 else {
		 	$character = uc $character;
		 }
		# Affichage du caractere 
		$Hframe[$i] = $mw->new_ttk__frame();
		$photo[$i] = Tkx::image_create_photo( "image$i", -file => "Images/$character.gif");		
		$Hframe[$i]->new_ttk__label( -image => $photo[$i], -width => $widthLabel, -background => 'grey', -anchor => 'w')->g_grid(-column => 0, -row => $i);
		
		$Hframe[$i]->g_grid(-column => 0, -row => $i);
		if ($i == 0){
			#$Hframe[$i]->new_ttk__label(-text  => "EXE : ", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			#$Hframe[$i]->new_ttk__label(-text => "Stop", -width => 5)->g_grid(-column => 2, -row => $i);
			#$Hframe[$i]->new_ttk__label(-text => "Start", -width => 5)->g_grid(-column => 3, -row => $i);
			
		}
		elsif ($i == 1){
			displayEXEline($DLIP_EXE, $DLIP_NAME, $i);
		}

		elsif ($i == 2){
			displayEXEline($JREP_EXE, $JREP_NAME, $i);
		}
		elsif ($i == 3){
			my $initialStartPhoto, my $initialStopPhoto;

				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			
			$Hframe[$i]->new_ttk__label(-text  => "DLIP Mng:", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopDLIPMng,
								-image => $initialStopPhoto)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startDLIPMng,
								-image => $initialStartPhoto)->g_grid(-column => 1, -row => $i);
		}
		elsif ($i == 4){
			my $initialStartPhoto, my $initialStopPhoto;

				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			
			$Hframe[$i]->new_ttk__label(-text  => "JREP Mng :",  -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopJREM,
								-image => $initialStopPhoto)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startJREM,
								-image => $initialStartPhoto)->g_grid(-column => 1, -row => $i);
		}
		elsif ($i == 5){
			my $initialStartPhoto, my $initialStopPhoto;
	
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			
			$Hframe[$i]->new_ttk__label(-text  => "SpyLinks :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopSpyLinks,
								-image => $initialStopPhoto)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startSpyLinks,
								-image => $initialStartPhoto)->g_grid(-column => 1, -row => $i);
		}
		elsif ($i == 6){
			my $initialStartPhoto, my $initialStopPhoto;

				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			
			$Hframe[$i]->new_ttk__label(-text  => "Tactical Visu :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopVisu,
								-image => $initialStopPhoto)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startVisu,
								-image => $initialStartPhoto)->g_grid(-column => 1, -row => $i);
		}
		
		elsif ($i == 7){
			my $initialStartPhoto, my $initialStopPhoto;
	
				$initialStartPhoto = "startInactivePhoto";
				$initialStopPhoto = "stopPhoto";
			
			$Hframe[$i]->new_ttk__label(-text  => "Data Server :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopDataServer,
								-image => $initialStopPhoto, )->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startDataServer,
								-image => $initialStartPhoto)->g_grid(-column => 1, -row => $i);
		}		
		elsif ($i == 8){
			$Hframe[$i]->new_ttk__label(-text  => "TMCT :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
			$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopTMCT,
								-image => "stopPhoto", )->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startTMCT,
								-image => "startInactivePhoto")->g_grid(-column => 1, -row => $i);
		}
		elsif ($i == 9){
			$Hframe[$i]->new_ttk__label(-text  => "DLIP state :", -width => $widthLabel)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&showDLIPState,
								-text => "Show", -width => 10, )->g_grid(-column => 1, -row => 1);		
		}
		elsif ($i == 10){
			$Hframe[$i]->new_ttk__label(-text  => "Log :", -width => $widthLabel)->g_grid(-column => 1, -row => $i);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&saveLog,
								-text => "Save", -width => 10, )->g_grid(-column => 1, -row => 1);		
		}
		elsif ($i == 11){
			$Hframe[$i]->new_ttk__label(-text  => "JRE Stater :", -width => $widthLabel)->g_grid(-column => 1, -row => 1);
			$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&exitJREStarter,
								-text => "Exit", -width => 10, )->g_grid(-column => 1, -row => 1);		
		}
		else {
			$Hframe[$i]->new_ttk__label(-text  => "", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => 1);
			$stopButton[$i] = $Hframe[$i]->new_ttk__label(-image => "blankPhoto")->g_grid(-column => 1, -row => 1);
			$startButton[$i] = $Hframe[$i]->new_ttk__label(-image => "blankPhoto")->g_grid(-column => 1, -row => 1);
			
		}
		$i +=  1;
	}
#	$mw->geometry("-40+10");
#	$mw->update;
	my $timer1 = threads->create(\&timer, \&timer_test, 1, 0);
	#$timer1->join();
	Tkx::MainLoop();
}

sub timer {
my($subroutine, $interval, $max_iteration) = @_;
for (my $count = 1; $max_iteration == 0 || $count <= $max_iteration; 
$count++) {
sleep $interval;
print "count = $count\n";
&$subroutine;
}
}

sub timer_test {
print "Testing...\n"
}


sub startDLIP {
	my $image = $startButton[1]->cget('-image');
	print "$image\n";
	;
	if( $image eq "startInactivePhoto" && ! isSolarisProcessRunning ($DLIP_EXE) && confirmAction ("Start DLIP ?") eq "Yes") {
		#print "$image\n";
		startSolarisProcess ($DLIP_CMD);
	}
	else {
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
		stopSolarisProcess ($DLIP_EXE);
	}
	else {
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
		startSolarisProcess ($JREP_CMD);
	}
	else {
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
		stopSolarisProcess ($JREP_EXE);
	}
	else {
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
		print "Operation not permitted !\n";		
	}
	sleep 3;
	updateSpyLinksState();
}

sub stopVisu {
	my $image = $stopButton[5]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DLVM_WIN_NAME) && confirmAction ("Stop Tactical Visu ?") eq "Yes") {
		#print "$image\n";
		#stopWindowsProcess ($SPY_WIN_NAME);
		stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
	}
	else {
		print "Operation not permitted !\n";		
	}
	updateSpyLinksState();
}

sub startDataServer {
	updateSpyLinksState();
}

sub stopDataServer {
	my $image = $stopButton[5]->cget('-image');
	#print "$image\n";
	if( $image eq "stopInactivePhoto" && isWindowsProcessRunning ($DATASERVER_WIN_NAME) && confirmAction ("Stop Data Server ?") eq "Yes") {
		#print "$image\n";
		#stopWindowsProcess ($SPY_WIN_NAME);
		#stopWindowsProcess ($DLVM_WIN_NAME);
		stopWindowsProcess ($DATASERVER_WIN_NAME);
	}
	else {
		print "Operation not permitted !\n";		
	}
	updateSpyLinksState();
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

sub startTMCT {
	$stopButton[6]->configure(-image => 'stopInactivePhoto');
	$startButton[6]->configure(-image => 'startPhoto');
}

sub stopTMCT {
	$stopButton[6]->configure(-image => 'stopPhoto');
	$startButton[6]->configure(-image => 'startInactivePhoto');
}

sub saveLog {
	if(confirmAction("Save Log File ? Better to stop all applications !")){
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
			system("mkdir $LOG_DIR\\$newDir");
		}
		if (-d  "$LOG_DIR\\$newDir"){
			print "create dir\n";
		}
	}		
}

sub exitJREStarter {
	exit 0 if(confirmAction("Exit JRE starter ?"));
}

sub isSolarisProcessRunning {
	my $process_name = shift;
	my $PID = 0;
	print "process : $process_name\n";
	#my $process_list = `plink $putty_session ps -edf`;
	my $process_list;
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
	print "$process_cmd\n";
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
	my $response = $dialog->Show();
	return $response;
}

sub displayEXEline {
	my $EXE = shift;
	my $EXE_NAME = shift;
	my $i = shift;
	my $initialStartPhoto, my $initialStopPhoto;
	#if(isSolarisProcessRunning($EXE)){
	$initialStartPhoto = "startPhoto";
	$initialStopPhoto = "stopInactivePhoto";
		
	$Hframe[$i]->new_ttk__label(-text  => "$EXE_NAME :", -width => $widthLabel, -anchor => 'e')->g_grid(-column => 1, -row => $i);
	$stopButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&stopDLIP,
								-image => $initialStopPhoto, -width => 5)->g_grid(-column => 2, -row => $i);
	$startButton[$i] = $Hframe[$i]->new_ttk__button(-command => \&startDLIP,
								-image => $initialStartPhoto)->g_grid(-column => 3, -row => $i);
}
