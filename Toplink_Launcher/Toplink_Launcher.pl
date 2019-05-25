# Modif S. Mouchot le 20/09/11 version 5.1

use strict;
use Tkx;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(../lib);
use Conversion;
use BOM;
use SimpleMsg;
use J_Msg;
use Time_conversion;
use File::Basename;
#use xMessageFilter;

getopts("t:c:v:hf:");

my $debug = 8;

my $test_name = "new test";
my $duration = 60;
my $period = 0;
my $remain_time = $duration;
my $technical_init_duration = 30;
my $period_nber;

my $putty_session = "jre-gateway";

my $Config_File = "Test_Launcher.cfg";

if(my $opt_f){
  $Config_File = "$opt_f";
  print "Config file = $Config_File\n";
  exit;
}

$SIG{ALRM} = sub { die "timeout" };


# Initialisation des paramètres via le fichier de configuration tcpdump2Aladdin.cfg
if(-f "$Config_File"){
  
}

my $mw = Tkx::widget->new(".");
$mw->g_wm_title("$0");

my $Vframe1 = $mw->new_ttk__frame
	->g_grid(-column => 0, -row => 0, -sticky => "w");
$mw->new_ttk__label(-text => "Test Name : ",  -width => 10)
	->g_grid(-column => 1, -row => 1, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$test_name, -width => 30)
	->g_grid(-column => 2, -row => 1, -sticky => "w");
$mw->new_ttk__label(-text => "Duration : ",  -width => 10)
	->g_grid(-column => 1, -row => 2, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$duration, -width => 10)
	->g_grid(-column => 2, -row => 2, -sticky => "w");
$mw->new_ttk__label(-text => 'Period : ', -width => 10)
	->g_grid(-column => 1, -row => 3, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$period,-width => 10)
	->g_grid(-column => 2, -row => 3, -sticky => "w");
$mw->new_ttk__label(-text => 'Remain : ', -width => 10)
	->g_grid(-column => 1, -row => 4, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$remain_time,-width => 10)
	->g_grid(-column => 2, -row => 4, -sticky => "w");
#


my $Vframe2 = $mw->new_ttk__frame
	->g_grid(-column => 1, -row => 5, -sticky => "w");
my $buttonOpen = $mw->new_ttk__button(-text => "Play", -state => 'active', -command => \&play_test, -width => 12)
	->g_grid(-column => 1, -row => 5, -sticky => "w");
my $ButtonSave=$mw->new_ttk__button(-text=>'Stop', -state => 'active', -command => \&stop_test, -width => 12)
	->g_grid(-column => 2, -row => 5, -sticky => "w");
my $ButtonExtract=$mw->new_ttk__button(-text=>'Save Test', -state => 'active', -command => \&save_test, -width => 12)
	->g_grid(-column => 3, -row => 5, -sticky => "w");
my $ButtonFilter=$mw->new_ttk__button(-text=>'What Else ?', -state => 'active', -command => \&what_else, -width => 15)
	->g_grid(-column => 4, -row => 5, -sticky => "w");

	
Tkx::MainLoop();

sub play_test {
	$remain_time = $duration;
	
	if ($period) {
		# repetition de la tactique
		$period_nber = int(($duration - $technical_init_duration)/$period);
		system("plink $putty_session /toplink/Scripts/prepare_Test_2");
		system("plink $putty_session /toplink/Scripts/start_Toplink");
		sleep 3;
		# lancement de l init technique
		system("plink $putty_session /toplink/Scripts/start_ALL_TD technical");
		# attente fin init technique
		eval {
			alarm($technical_init_duration);		    
		    print "waiting $technical_init_duration s...\n";
		    while(1){
		    	sleep 1;
		    	$remain_time -= 1;
		    	print "remain time = $remain_time\n";
		    	#$mw->update();    	
		    }
		    alarm(0);
		};
		if ($@ =~ /timeout/) {
	    	print "fin du test\n";
	    	system("plink $putty_session /toplink/Scripts/stop_HOST_TD");
		}	     			                            # timed out; do what you will here
	    else {
	    	
	        alarm(0);           # clear the still-pending alarm
	        die;                # propagate unexpected exception
	    }
	    # run des pattern tactique
		while($period_nber){
			eval {
				alarm($period);		    
			    print "waiting $period s period number $period_nber...\n";
			    system("plink $putty_session /toplink/Scripts/start_HOST_TD tactical");
			    while(1){
			    	sleep 1;
			    	$remain_time -= 1;
			    	print "remain time = $remain_time\n";
			    	#$mw->update();    	
			    }
			    alarm(0);
			};
			if ($@ =~ /timeout/) {
		    	system("plink $putty_session /toplink/Scripts/stop_HOST_TD");
			}
		     			                            # timed out; do what you will here
		    else {
		    	
		        alarm(0);           # clear the still-pending alarm
		        die;                # propagate unexpected exception
		    } 
			#$mw->update();
			alarm(0);	
			$period_nber -= 1;    	
	    }
	    print "fin du test\n";
	    system("plink $putty_session /toplink/Scripts/stop_Toplink");
		system("plink $putty_session /toplink/Scripts/stop_ALL_TD");
		system("plink $putty_session /toplink/Scripts/postprocess_Test");
		
	}
	# si on la period est 0 , lancement d'un test "classique"
	else {
		system("plink $putty_session /toplink/Scripts/prepare_Test");
		system("plink $putty_session /toplink/Scripts/start_Toplink");
		sleep 3;
		system("plink $putty_session /toplink/Scripts/start_ALL_TD");	
		eval {
			alarm($duration);		    
		    print "waiting $duration s...\n";
		    while(1){
		    	sleep 1;
		    	$remain_time -= 1;
		    	print "remain time = $remain_time\n";
		    	#$mw->update();    	
		    }
		    alarm(0);
		};
		if ($@ =~ /timeout/) {
	    	print "fin du test\n";
	    	
			system("plink $putty_session /toplink/Scripts/stop_TDL_TD");
			system("plink $putty_session /toplink/Scripts/start_TDL_TD");
			sleep 30;
			system("plink $putty_session /toplink/Scripts/stop_Toplink");
			system("plink $putty_session /toplink/Scripts/stop_ALL_TD");
			system("plink $putty_session /toplink/Scripts/postprocess_Test");
		}	     			                            # timed out; do what you will here
	    else {
	    	
	        alarm(0);           # clear the still-pending alarm
	        die;                # propagate unexpected exception
	    }
	}
}

sub stop_test {
	print "Arret du test forcé \n";
	print "fin du test\n";
    system("plink $putty_session /toplink/Scripts/stop_Toplink");
	system("plink $putty_session /toplink/Scripts/stop_ALL_TD");
    	
	return 0;
}

sub save_test {
	return 0;
}

sub what_else {
	return 0;
}

sub got_int {
	print " I'm got interrupt, bye !\n";
	exit 0;
}

