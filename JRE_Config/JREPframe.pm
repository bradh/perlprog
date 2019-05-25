package JREPframe;

use strict;
use Tkx;
use File::Basename;
use DataStructureXML;
use JrepInternalFile;

my $mw;
my $notebookJREP;
my $frameJREP;
my (@entryJREP, @labelJREP, @buttonJREP, $buttonInternal);
my ($buttonOpen, $buttonSave, $buttonAddJREP, $buttonDelJREP);

my $configurationFile = "JRE_Network_ConfFile_Init.xml";
my $JRE_Network_Configuration;
my $jrep_tab;
my $ref_links_tab;

sub new {
	$mw = shift;
	$notebookJREP = shift;
	$JRE_Network_Configuration = shift;
	$jrep_tab = $JRE_Network_Configuration->{'config_jrep'};
	$frameJREP = $notebookJREP->new_ttk__frame;
	$frameJREP->configure(-borderwidth => 5);
	$notebookJREP->add($frameJREP, -text => "JREP");
	return $frameJREP;
}

sub displayNotebookJREP {
	my $i=0;
	clearNotebookJREP();
	foreach my $jrep (@$jrep_tab){
		my $jrepName = \$jrep->{'jrep_designator'};
		my $jrepSenderID = \$jrep->{'jrep_sender_id'};
		$labelJREP[$i] = $frameJREP->new_ttk__label(-text =>"Designator : ",-anchor => 'e', -width => 15);
		$entryJREP[$i] = $frameJREP->new_ttk__entry(-textvariable => $jrepName, -width => 15);
		$entryJREP[$i]->g_bind("<FocusOut>", \&updateLinksFrame);	
		$labelJREP[$i+1] = $frameJREP->new_ttk__label(-text =>"Sender ID : ",-anchor => 'e', -width => 15);
		$entryJREP[$i+1] = $frameJREP->new_ttk__entry(-textvariable => $jrepSenderID, -width => 8);
		$entryJREP[$i+1]->g_bind("<FocusOut>", \&updateLinksFrame);	
		$buttonInternal = $frameJREP->new_ttk__button(-text => "Internal", -command => [\&newInternalFile, $jrep]);
		$buttonJREP[$i]= $frameJREP->new_ttk__button(-text => "Config.", -command => [\&displayJREPConfigWindow, $jrepName]);
		#$button[$i]->configure(-borderwidth => 5);
		$labelJREP[$i]->g_grid(-column => 0, -row => $i/2);
		$entryJREP[$i]->g_grid(-column => 1, -row => $i/2, -padx => 5, -pady => 5);
		$labelJREP[$i+1]->g_grid(-column => 2, -row => $i/2);
		$entryJREP[$i+1]->g_grid(-column => 3, -row => $i/2, -padx => 5, -pady => 5);
		$buttonInternal->g_grid(-column => 5, -row => $i/2, -padx => 5, -pady => 5);
		$buttonJREP[$i]->g_grid(-column => 6, -row => $i/2, -padx => 5, -pady => 5);
		print "$jrep->{'jrep_designator'}, $jrep->{'jrep_sender_id'}\n";
		$i += 2;
	}
	$buttonOpen = $frameJREP->new_ttk__button(-text => "Open", -command => \&openConfiguration);
	$buttonSave = $frameJREP->new_ttk__button(-text => "Save", -command => \&saveConfiguration);
	$buttonAddJREP = $frameJREP->new_ttk__button(-text => "Add JREP", -command => \&addJREP);
	$buttonDelJREP = $frameJREP->new_ttk__button(-text => "Del JREP", -command => \&delJREP);
	
	$buttonOpen->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$buttonSave->g_grid(-column => 2, -row => $i, -padx => 5, -pady => 5);
	$buttonAddJREP->g_grid(-column => 4, -row => $i, -padx => 5, -pady => 5);
	$buttonDelJREP->g_grid(-column => 5, -row => $i, -padx => 5, -pady => 5);
	$buttonDelJREP->state("disabled");
	return 0;
}

sub clearNotebookJREP {
	foreach my $i (0..scalar @labelJREP){
		#print "nettoyage ligne $i\n";
		if(defined $labelJREP[$i]){
			print "nettoyage ligne $i\n";
			$labelJREP[$i]->g_grid_remove();
			$entryJREP[$i]->g_grid_remove();
			$buttonJREP[$i]->g_grid_remove()if(defined($buttonJREP[$i]));
			#$buttonJREP[$i] = undef();
			#$entryJREP[$i] = undef();
			#$buttonJREP[$i] = undef();
		}		
	}
	
	$buttonOpen->g_grid_remove()if(defined $buttonOpen);
	$buttonSave->g_grid_remove()if(defined $buttonSave);
	$buttonAddJREP->g_grid_remove()if(defined $buttonAddJREP);
	$buttonDelJREP->g_grid_remove()if(defined $buttonDelJREP);
}

sub openConfiguration {
	$configurationFile = Tkx::tk___getOpenFile();
	my $fileName = fileparse($configurationFile);
	$JRE_Network_Configuration = DataStructureXML::readConfigFile($configurationFile);
	$jrep_tab = $JRE_Network_Configuration->{'config_jrep'};
	displayNotebookJREP();
	updateLinksFrame();
	$mw->g_wm_title("JRE Network Configuration : $fileName" );
}

sub getConfigurationfile {
	return $configurationFile;
}

sub addJREP {
	DataStructureXML::addNewJREP();
	#$frameJREP->g_destroy;
	#clearNotebookJREP();
	updateLinksFrame();
	displayNotebookJREP($jrep_tab);
	#$notebookJREP->g_update();
	return 0;
}

sub saveConfiguration {
	
	my $filename = Tkx::tk___getSaveFile();
	DataStructureXML::writeConfigFile($filename);
	return 0;
}
sub displayJREPConfigWindow {
	my $jreName = shift;
	my (@labelTN, @entryTN, $r_secondaryTN_tab);
	my $mw = Tkx::widget->new(".");
	#$mw->g_wm_title("JREP Configuration" );
	my $configJREWindow = $mw->new_toplevel();
	$configJREWindow->g_wm_title("JREP Configuration" );
	my $newFrame = $configJREWindow->new_ttk__frame();
	my $label_0 = $newFrame->new_ttk__label( -text =>'Designator : ', -anchor => 'e',-width => 15);
	my $entry_0 = $newFrame->new_ttk__entry( -textvariable => $jreName, -state => 'readonly',-width => 8);
	my $label_1 = $newFrame->new_ttk__label( -text =>'Sender ID : ', -anchor => 'e', -width => 15);
	my $entry_1 = $newFrame->new_ttk__entry( -textvariable => DataStructureXML::getJREPsenderIDbyName($$jreName), -state => 'readonly', -width => 8);
	my $label_2 = $newFrame->new_ttk__label( -text =>'Startup Mode : ',-anchor => 'e', -width => 15);
	my $entry_2 = $newFrame->new_ttk__entry( -textvariable => DataStructureXML::getJREPstartupMode($jrep_tab, $$jreName), -width => 8);
	my $label_3 = $newFrame->new_ttk__label( -text =>'DLIP Link ID : ',-anchor => 'e', -width => 15);
	my $entry_3 = $newFrame->new_ttk__entry( -textvariable => DataStructureXML::getJREPdlipLink($jrep_tab, $$jreName), -width => 8);
	
	$r_secondaryTN_tab= DataStructureXML::getJREPsecondaryTNlist($jrep_tab, $$jreName);
	#print "$r_secondaryTN_tab->[0]";exit 0;
	my $nberOfTN = scalar (@$r_secondaryTN_tab);
	for my $i (0..$nberOfTN-1){
		print "toto :$r_secondaryTN_tab->[$i]\n";
		$labelTN[$i] = $newFrame->new_ttk__label( -text => "secondary TN #$i",-anchor => 'e', -width => 15);
		$entryTN[$i] = $newFrame->new_ttk__entry( -textvariable => \$r_secondaryTN_tab->[$i], -width => 8);
	}
	my $buttonJREP_1 = $newFrame->new_ttk__button(-text => "OK", -command => [\&closeWindow, $configJREWindow]);
	my $buttonJREP_2 = $newFrame->new_ttk__button(-text => "Add STN", -command => [\&addSTN, $jreName, $configJREWindow]);
	my $buttonJREP_3 = $newFrame->new_ttk__button(-text => "Del STN", -command => [\&delSTN, $jreName]);
	
	
	#DataStructureXML::getJREPsenderID($jrep_tab, $$jreName);
	print " $$jreName, DataStructureXML::getJREPsenderIDbyName($$jreName)\n";
	$label_0->g_grid(-column => 1, -row => 1, -padx => 5, -pady => 5, -sticky => 'e');
	$entry_0->g_grid(-column => 2, -row => 1,  -padx => 5, -pady => 5);
	$label_1->g_grid(-column => 1, -row => 2, -sticky => 'e');
	$entry_1->g_grid(-column => 2, -row => 2,  -padx => 5, -pady => 5);
	$label_2->g_grid(-column => 1, -row => 3, -sticky => 'e');
	$entry_2->g_grid(-column => 2, -row => 3,  -padx => 5, -pady => 5);
	$label_3->g_grid(-column => 1, -row => 4, -sticky => 'e');
	$entry_3->g_grid(-column => 2, -row => 4,  -padx => 5, -pady => 5);
	
	for my $i (0..$nberOfTN-1){
		$labelTN[$i]->g_grid(-column => 3, -row => $i+1, -sticky => 'e');
		$entryTN[$i]->g_grid(-column => 4, -row => $i+1,  -padx => 5, -pady => 5);
	}
	
	$buttonJREP_1->g_grid(-column => 2, -row => $nberOfTN + 5);
	$buttonJREP_2->g_grid(-column => 3, -row => $nberOfTN + 5);
	$buttonJREP_3->g_grid(-column => 4, -row => $nberOfTN + 5);
	#$buttonJREP_3->state("disable");
	$newFrame->g_grid(-columnspan => 6, -rowspan => 13, -padx => 5, -pady => 5);
	return 0;
}

sub save {
	return 0;
}

sub updateLinksFrame{
	print "focus out\n";
	$ref_links_tab = DataStructureLink::initializeLinksTab($jrep_tab);
	Linksframe::clearNotebookLinks();
	Linksframe::displayNotebookLinks($ref_links_tab);
}

sub addSTN {
	my $jreName = shift;
	my $mw = shift;
	#print "$jreName";exit;
	DataStructureXML::addNewSTN($jreName, '00001');
	# Supprimer la fenêtre mère
	$mw->g_destroy;
	displayJREPConfigWindow($jreName);
	
	return 0;
}
sub closeWindow {
	my $mw = shift;
	$mw->g_destroy;
}

sub newInternalFile {
	my $jrep = shift;
	JrepInternalFile::new($jrep);
}

sub delJREP {
	
}

sub delSTN {
	
}

1