# 

use strict;
use Tkx;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(../lib);
use Conversion;
use J_Msg;
use Time_conversion;
use File::Basename;
#use xMessageFilter;

getopts("h");

my $LogDir = "F:\\MARTHA_MCO\\ESSAI_MASSY_07_09_16\\4_ème_essai";
my $inputLogFile = "DLIP";
my $LogExt = "extract";
my $OutputDir = ".\\";

my %researchString = (	'warning' => "\\*\\s",
						'error' => "\\*\\*",
						'constraint_error' => "\\*\\*\\*\\s",
					  'fatal_error' => "\\*\\*\\*\\*\\s",
						'state' => "_Mgr"
					 );
my $key = "extract";
my $string1 = "J7.4";
my $string2 = "GF_NOT_DEFINED_FOR_THIS_MESSAGE";
my $string3 = "DEM_EMI_JFT";
my $string4 = "to search";
my $string5 = "to search";
my $string6 = "to search";
my $string7 = "to search";
my $string8 = "to search";

my $notString1 = "not to search";
my $notString2 = "not to search";
my $notString3 = "not to search";

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

my $row = 1;

my $Vframe1 = $mw->new_ttk__frame->g_grid(-column => 2, -row => 0, -sticky => "w");

my $labelKey = $mw->new_ttk__label(-text => "File Extension :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entryKey = $mw->new_ttk__entry(-state => 'active', -textvariable => \$key, -width => 12)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;	
my $labelstring = $mw->new_ttk__label(-text => "String 1 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string1, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;
my $labelstring2 = $mw->new_ttk__label(-text => "ou String 2 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring2 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string2, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;	
my $labelstring3 = $mw->new_ttk__label(-text => "ou String 3 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring3 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string3, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;	
my $labelstring4 = $mw->new_ttk__label(-text => "ou String 4 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring4 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string4, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;
my $labelstring5 = $mw->new_ttk__label(-text => "ou String 5 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring5 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string5, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;	
my $labelstring6 = $mw->new_ttk__label(-text => "ou String 6 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring6 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string6, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;
my $labelstring7 = $mw->new_ttk__label(-text => "ou String 7 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring7 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string7, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
	$row += 1;
my $labelstring8 = $mw->new_ttk__label(-text => "ou String 8 :", -state => 'active', -width => 15)
	->g_grid(-column => 1, -row => $row, -sticky => "w");

my $entrystring8 = $mw->new_ttk__entry(-state => 'active', -textvariable => \$string8, -width => 30)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
$row += 1;	

my $buttonOpen = $mw->new_ttk__button(-text => "Open", -state => 'active', -command => \&openFile, -width => 12)
	->g_grid(-column => 2, -row => $row, -sticky => "w");
	
my $buttonProceed = $mw->new_ttk__button(-text => "Proceed", -state => 'active', -command => \&proceedFile, -width => 12)
	->g_grid(-column => 3, -row => $row, -sticky => "w");
	
Tkx::MainLoop();

sub proceedFile {
	chdir($LogDir);
	open Fin, "<$inputLogFile" or die "$inputLogFile no exist in $LogDir\n";
	my $Line1="";
	my $LineNber = 1;
	my $question = "search string $string1 ou $string2 ?";
	confirmAction ($question);
	open Fout, ">$inputLogFile.$key" or die "not possible to open $inputLogFile.$key";
	print "open $inputLogFile.$key\n";
	chdir($LogDir);
	open Fin, "<$inputLogFile" or die "$inputLogFile no exist in $LogDir\n";
	my $Line1="";
	my $Line2=""; 
	my $Line3="";
	my $LineNber = 1;
	my $string1lc = $string1;
	my $string2lc = $string2;
	my $string3lc = $string3;
	my $nbreLineAfter = 1;
	my $status = 0;
	while(<Fin>){
		$Line1 = $_;
			if ($Line1 =~ /$string1/ 
				|| $Line1 =~/$string2/ 
				|| $Line1 =~/$string3/ 
				|| $Line1 =~ /$string4/ 
				|| $Line1 =~/$string5/ 
				|| $Line1 =~/$string6/
				|| $Line1 =~/$string7/
				|| $Line1 =~/$string8/
				|| $Line1 =~/$researchString{'warning'}/
				|| $Line1 =~/$researchString{'error'}/
				|| $Line1 =~/$researchString{'contraint_error'}/
				|| $Line1 =~/$researchString{'fatal_error'}/
				){
			
			print "$LineNber:\t$Line1";
			<>;
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
	my $openFile = Tkx::tk___getOpenFile( -initialdir => $LogDir);
	($inputLogFile, $LogDir) = fileparse($openFile);
	print "$inputLogFile, $LogDir\n";
	#$OutputDir = $LogDir;
}

