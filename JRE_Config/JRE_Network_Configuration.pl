#!/usr/bin/perl -w

use Tkx;
use File::Basename;
use JREPframe;
use Linksframe;
use DataStructureXML;
use DataStructureLink;

#use strict;
my $i =0;

my $JRE_Network_Configuration;
my $jrep_tab;
my $ref_links_tab;
my $mw;

my $jrep_config;
my $jrep_internal_config;
my $SecTN_Nber = 16;
my $JRE_Network_Configuration_File = "JreNetworkConfFile_Init.xml";
#print "$JRE_Network_Configuration_File";
my $fileName = fileparse($JRE_Network_Configuration_File);

$JRE_Network_Configuration = DataStructureXML::readConfigFile($JRE_Network_Configuration_File);
$jrep_tab = $JRE_Network_Configuration->{'config_jrep'};

# Initialisation du tableau des links
# chaque link ID est dfini par 2 jrep designator et un link ID
$ref_links_tab = DataStructureLink::initializeLinksTab($jrep_tab);	
  
# Main window Tak$e top and the bottom - now implicit top is in the middle
$mw = Tkx::widget->new(".");
$mw->g_wm_title("JRE Network Configuration : $fileName" );
$notebookJREP = $mw->new_ttk__notebook();

my $JREPframe = JREPframe::new($mw, $notebookJREP, $JRE_Network_Configuration);
my $LinksFrame = Linksframe::new($notebookJREP);

JREPframe::displayNotebookJREP();
Linksframe::displayNotebookLinks($ref_links_tab);

$notebookJREP->g_grid(-columnspan => 6, -rowspan => 6);
  
Tkx::MainLoop();




