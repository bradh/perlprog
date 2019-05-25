package JrepInternalFile;

use Tkx;
use DataStructureXML;
use File::Basename;
use XML::Simple;
use Data::Dumper;
use DataStructureInternalParam;

my $dataInternalConfig;
my $jrep;

my ($mw, $tl);
my ($buttonOpen, $buttonSave);


sub new {
	$jrep = shift;
	$mw = Tkx::widget->new(".");
	$tl = $mw->new_toplevel();
	$mw->g_wm_title("JREP Internal File : ");
	my $fameInternal = $mw->new_ttk__frame();
	#$notebookJREP = $mw->new_ttk__notebook();
	
	$dataInternalconfig = DataStructureInternalParam::new();
	
	$buttonOpen = $frameInternal->new_ttk__button(-text => "Open", -command => \&openConfiguration);
	$buttonSave = $frameInternal->new_ttk__button(-text => "Save", -command => \&saveConfiguration);
		
	$buttonOpen->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$buttonSave->g_grid(-column => 2, -row => $i, -padx => 5, -pady => 5);
	$frameInternal->g_grid();

}

1


