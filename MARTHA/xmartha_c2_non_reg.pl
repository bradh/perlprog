#!/usr/bin/perl
#
# le script xmartha_c2_non_reg.pl 
# Identifie la version courante de binaire dlip
# liste la version courante de binaire jrep
# permet à l'utilisateur de selectionner les versions de dlip , de jrep parmi ma liste des versions disponibles
# permet à l'utilisateur de lancer les tests de non regression
# affiche les résultats test par test dans une listbox
# affiche le status de façon graphique ( voyant vert ou rouge)

use strict;
use Tkx;
use threads;

my $puttySession  = "";

my $rootDir = "";
my $testDir = "";
my $nonregConfigDir = "";
my $nonregConfigFile = "";
#my %testParam = { 	'Name' => "",
#					'Duration' => "",
#					'Type' => "",
#					'Result' => ""
#};

my $dlipVersionDir = "DLIP";
my $jrepVersionDir = "JREP";

my $currentDlipVersion = "V0";
my $currentJrepVersion = "V0";

my @availableDlipVersion;
my @availableJrepVersion;

my	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
my	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
my	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
my	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");

my $i = 0;


my $mw = Tkx::widget->new(".");
$mw->g_wm_title( "MARTHA CGC3 C2 non regression tests");

my $menu = $mw->new_menu ();
my $version = $menu->new_menu(	-tearoff => 0,
					          		-background => 'lightgrey'
					      			);
$menu->add_cascade( -label => "Versions",
				          -underline => 0,
				          -menu => $version,
				      	);
$version->add_command(	-label => "DLIP",
					      		-underline => 0,
					      		-command => \&selectDlipVersion
					      );
$version->add_command(	-label => "JREP",
					      		-underline => 0,
					      		-command => \&selectJrepVersion
					      );
 					     
$mw->configure(-menu => $menu);



my $frame1 = $mw->new_ttk__frame(); $frame1->g_grid(-column => 0, -row => 0);
my $frame2 = $mw->new_ttk__frame(); $frame2->g_grid(-column => 0, -row => 1);
my $frame3 = $mw->new_ttk__frame(); $frame3->g_grid(-column => 0, -row => 2);

# frame1 : display current version

($frame1->new_ttk__label( -text => "DLIP version : ", -width => 10,  -anchor => 'center'))->g_grid(-column => 0, -row => 0, -sticky => "nwes");
($frame1->new_ttk__entry( -textvariable => \$currentDlipVersion, -width => 10, -state => 'readonly' ))->g_grid(-column => 1, -row => 0, -sticky => "nwes");
($frame1->new_ttk__label( -text => "JREP version : ", -width => 10, -anchor => 'center'))->g_grid(-column => 0, -row => 1, -sticky => "nwes");
($frame1->new_ttk__entry( -textvariable => \$currentJrepVersion, -width => 10, -state => 'readonly'))->g_grid(-column => 1, -row => 1, -sticky => "nwes");

my $ButtonStart=$frame2->new_ttk__button(-text=>'Start Non Reg', -state => 'active', -command => \&startNonReg, -width => 12)
		->g_grid(-column => 0, -row => 0, -sticky => "we");
my $OKButton = $frame2->new_ttk__button(-command => \&null,
								-image => $startInactivePhoto);
#$stopButton[$j]->configure( -borderwidth => 15);
$OKButton->g_grid(-column => 1, -row => 0, -sticky => 'w');

my $KOButton = $frame2->new_ttk__button(-command => \&startNonReg,
								-image => $stopInactivePhoto);
#$stopButton[$j]->configure( -borderwidth => 15);
$KOButton->g_grid(-column => 2, -row => 0, -sticky => 'w');


(my $lb = $frame3->new_tk__listbox(-height => 10, -width => 50))->g_grid(-column => 0, -row => 0, -sticky => "nwes");
(my $s = $frame3->new_ttk__scrollbar(-command => [$lb, "yview"], 
        -orient => "vertical"))->g_grid(-column =>1, -row => 0, -sticky => "ns");
$lb->configure(-yscrollcommand => [$s, "set"]);

($frame3->new_ttk__label(-text => "Wait for running non reg", 
        -anchor => "w"))->g_grid(-column => 0, -row => 1, -sticky => "we");
($frame3->new_ttk__sizegrip)->g_grid(-column => 1, -row => 1, -sticky => "se");
$frame3->g_grid_columnconfigure(0, -weight => 1); $frame3->g_grid_rowconfigure(0, -weight => 1);

Tkx::MainLoop();

sub selectDlipVersion {
	$currentDlipVersion = "V6E14E10";
}

sub selectJrepVersion {
	$currentJrepVersion = "V3R4E5";
}

sub startThread {
	my $th = threads->create(\&startNonReg);
}

sub startNonReg {
	my $i = 0;
	if($i < 10) {
		
		#$lb->insert(0, "Test $i : OK");
		$i += 1;
	}
	if($i == 10) {
		$lb->insert(0, "Non regresstion tests : OK");
		$OKButton->configure(-image => 'startPhoto');
		$KOButton->configure(-image => 'stopInactivePhoto');
	}
	return 0;
}