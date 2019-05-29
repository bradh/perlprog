# 

use strict;
use Tkx;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(c:/perlprog/lib);
use Conversion;
use J_Msg;
use Time_conversion;
use File::Basename;
#use xMessageFilter;

getopts("h");

my $LogDir = ".\\";
my $LogFile = "DLIP";
my $LogExt = "log";
my $OutputDir = ".\\";

my %researchString = (	'warning' => "\\*\\s",
						'error' => "\\*\\*",
						'constraint_error' => "\\*\\*\\*\\s",
					  'fatal_error' => "\\*\\*\\*\\*\\s",
						'state' => "_Mgr"
					 );
my $key = "ext";
my $value1 = "to search";
my $value2 = "to search";
my $value3 = "to search";
my $value4 = "not to search";
my $value5 = "not to search";
my $value6 = "not to search";

# Initialisation des paramètres via le fichier de configuration tcpdump2Aladdin.cfg

if( my $opt_h){
	print "$0 [-h] [-c test configuration] [-v version] [-t test name]\n";
	print "analyse le fichier de...\n";
	exit -1;
}

#my $mw = MainWindow->new;
#$mw->title("$0");
my $mw = Tkx::widget->new(".");
$mw->g_wm_title("$0" );

my $Vframe1 = $mw->new_ttk__frame->g_grid(-column => 2, -row => 0, -sticky => "w");

my $labelKey = $mw->new_ttk__label(-text => "File Extension :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 1, -sticky => "w");

my $entryKey = $mw->new_ttk__entry(-state => 'active', -textvariable => \$key, -width => 12)
	->g_grid(-column => 2, -row => 1, -sticky => "w");
	
my $labelValue = $mw->new_ttk__label(-text => "String 1 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 2, -sticky => "w");

my $entryValue = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value1, -width => 30)
	->g_grid(-column => 2, -row => 2, -sticky => "w");

my $labelValue2 = $mw->new_ttk__label(-text => "ou String 2 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 3, -sticky => "w");

my $entryValue2 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value2, -width => 30)
	->g_grid(-column => 2, -row => 3, -sticky => "w");
	
my $labelValue3 = $mw->new_ttk__label(-text => "ou String 3 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 4, -sticky => "w");

my $entryValue3 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value3, -width => 30)
	->g_grid(-column => 2, -row => 4, -sticky => "w");

my $labelValue4 = $mw->new_ttk__label(-text => "but Not :", -state => 'active', -width => 15)
	->g_grid(-column => 2, -row => 5, -sticky => "w");
	
my $labelValue5 = $mw->new_ttk__label(-text => "ou String 4 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 6, -sticky => "w");

my $entryValue5 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value4, -width => 30)
	->g_grid(-column => 2, -row => 6, -sticky => "w");
	
my $labelValue6 = $mw->new_ttk__label(-text => "ou String 5 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 7, -sticky => "w");

my $entryValue6 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value5, -width => 30)
	->g_grid(-column => 2, -row => 7, -sticky => "w");

my $labelValue7 = $mw->new_ttk__label(-text => "ou String 6 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => 8, -sticky => "w");

my $entryValue7 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$value6, -width => 30)
	->g_grid(-column => 2, -row => 8, -sticky => "w");
	

my $buttonOpen = $mw->new_ttk__button(-text => "Open", -state => 'active', -command => \&openFile, -width => 12)
	->g_grid(-column => 2, -row => 9, -sticky => "w");
	
my $buttonProceed = $mw->new_ttk__button(-text => "Proceed", -state => 'active', -command => \&proceedFile, -width => 12)
	->g_grid(-column => 3, -row => 9, -sticky => "w");
	
Tkx::MainLoop();

sub proceedFile {
	chdir($LogDir);
	open Fin, "<$LogFile" or die "$LogFile no exist in $LogDir\n";
	my $Line1="";
	my $Line2=""; 
	my $Line3="";
	my $LineNber = 1;
	my $question = "search value $value1 ou $value2 ?";
	confirmAction ($question);
	open Fout, ">$LogFile.$key" or die "not possible to open $LogFile.$key";
	print "open $LogFile.$key\n";
	chdir($LogDir);
	open Fin, "<$LogFile" or die "$LogFile no exist in $LogDir\n";
	my $Line1="";
	my $Line2=""; 
	my $Line3="";
	my $LineNber = 1;
	my $value1lc = $value1;
	my $value2lc = $value2;
	my $value3lc = $value3;
	my $nbreLineAfter = 1;
	my $status = 0;
	while(<Fin>){
		$Line1 = $_;
		if ($status > 0){
			print "$LineNber:\t$Line1";
			print Fout "$LineNber:\t$Line1";
			$status = $status-1;
			next;
		}
		if (($Line1 =~ /$value1/ || $Line1 =~/$value2/ || $Line1 =~/$value3/) && ! ($Line1 =~ /$value4/ || $Line1 =~/$value5/ || $Line1 =~/$value6/)){
			#print "$LineNber:\t$Line1\n";
			$status = $nbreLineAfter;
			print "$LineNber:\t$Line1";
			print Fout "$LineNber:\t$Line1";
			#print "$LineNber:\t$Line2";
			#print Fout "$LineNber:\t$Line2";		
		}
		#$Line1 = $Line2;
		#$Line2 = $Line3;
		$LineNber++;
	}	
	close Fin;
	close Fout;	
	print "That's all folks !\n";

}

sub getResearchString {

	
}

sub confirmAction {
	my $question = shift;
	my $dialog = Tkx::tk___messageBox(
              -parent => $mw,
              -icon => "info",
              -title => "Tip of the Day",
              -message => "$question",
           );
	return 0;
}


sub openFile {
	print "open file...\n";
	my $openFile = Tkx::tk___getOpenFile();
	($LogFile, $LogDir) = fileparse($openFile);
	print "$LogFile, $LogDir\n";
	$OutputDir = $LogDir;
}

