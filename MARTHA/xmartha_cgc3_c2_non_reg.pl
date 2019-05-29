#!/usr/bin/perl
# V1.1
# modif. S. Mouchot
# ajout d'un message de vie pour tenir éveiller la carte réseau
# modification de la fenêtre d'affichage et de sa taille
# ajout d'un menu file pour choisir le fichier de non reg
# le script xmartha_c2_non_reg.pl
# Identifie la version courante de binaire dlip
# liste la version courante de binaire jrep
# permet Ã  l'utilisateur de selectionner les versions de dlip , de jrep parmi ma liste des versions disponibles
# permet Ã  l'utilisateur de lancer les tests de non regression
# affiche les rÃ©sultats test par test dans une listbox
# affiche le status de faÃ§on graphique ( voyant vert ou rouge)

use strict;
use lib qw(D:\Users\t0028369\perlprog\lib);
use Tkx;
use Threads;
use File::Basename;

my $puttySession = "martha_cgc3_c2_non_reg";

my $ROOT_DIR       = "/h7_usr/sil2_usr/marthivq/MARTHA_CGC3";
my $TEST_DIR       = "$ROOT_DIR/C2/TESTS_CGC3_PEU/build2";
my $SCRIPTS_DIR    = "$ROOT_DIR/Scripts";
my $TEST_LIST_DIR = "$ROOT_DIR/configuration_files/non_reg";
my $WIN_TEST_LIST_DIR = "\\\\dataunix.clb.tcfr.thales\\cifs02\\sil2_usr\\marthivq\\MARTHA_CGC3\\configuration_files\\non_reg";
my $TEST_LIST_FILE = "$TEST_LIST_DIR/test_list.txt";
my $TEST_NAME;
my $DURATION_TEST;
my $TYPE_TEST;
my $TEST_RESULT;
my $testResult = "not running !";
my $result;

my $REMOTE_ENV =
  " export PATH=\$PATH:/h7_usr/sil2_usr/marthivq/MARTHA_CGC3/Scripts:.";

my $nonRegResult;

my @TEST_LIST;
my $testParam = {
	'Name'     => "",
	'Duration' => "",
	'Type'     => "",
	'Result'   => ""
};
my $networkServerDlip =
  "\\\\dataunix.clb.tcfr.thales\\cifs02\\dlip_ref\\dlip_doc\\Affaire";
my $dlipVersionDir =
"$networkServerDlip\\MARTHA_CGC3\\07-GestionConfiguration\\06-Livraisons\\Binaires\\C2";
my $jrepVersionDir =
  "\\\\dataunix\\cifs01\\dlip_ref\\Integ_JRE\\Livraisons_Internes";
my @dlipVersionList;
my $currentDlipVersion = "";
my $selectedDlipVersion;
my $dlipVersionSelectRank;
my @jrepVersionList;
my $currentJrepVersion = "";
my $selectedJrepVersion;
my $jrepVersionSelectRank;
my @availableDlipVersion;
my @availableJrepVersion;

my $processRun = 1;
my $processCheck = 1;
my $processSave = 1;

my $menu;
my $lb;

my $testWarning = "Hello World !";

my $startPhoto =
  Tkx::image_create_photo( "startPhoto", -file => "Images/Start_actif.gif" );
my $stopPhoto =
  Tkx::image_create_photo( "stopPhoto", -file => "Images/Stop_actif.gif" );
my $startInactivePhoto = Tkx::image_create_photo( "startInactivePhoto",
	-file => "Images/Start_inactif.gif" );
my $stopInactivePhoto = Tkx::image_create_photo( "stopInactivePhoto",
	-file => "Images/Stop_inactif.gif" );

my $i = 0;

# init dlip version list
getDlipVersionList();

#init jrep version list
getJrepVersionList();

$currentDlipVersion = getCurrentDlipVersion();
$currentJrepVersion = getCurrentJrepVersion();

my $mw = Tkx::widget->new(".");
$mw->g_wm_title("MARTHA CGC3 C2 non regression tests");

initMenu();

my $frame1 = $mw->new_ttk__frame();
$frame1->g_grid( -column => 0, -row => 0 );
my $frame2 = $mw->new_ttk__frame();
$frame2->g_grid( -column => 0, -row => 1 );
my $frame3 = $mw->new_ttk__frame();
$frame3->g_grid( -column => 0, -row => 2 );

# frame1 : display current version

(
	$frame1->new_ttk__label(
		-text   => "installed DLIP version : ",
		-width  => 20,
		-anchor => 'center'
	)
)->g_grid( -column => 0, -row => 0, -sticky => "nwes" );
(
	$frame1->new_ttk__entry(
		-textvariable => \$currentDlipVersion,
		-width        => 20,
		-state        => 'readonly'
	)
)->g_grid( -column => 1, -row => 0, -sticky => "nwes" );
my $ButtonUpdateDlip = $frame1->new_ttk__button(
	-text    => 'Update DLIP Version',
	-state   => 'active',
	-command => \&updateDlipVersion,
	-width   => 12
);
$ButtonUpdateDlip->g_grid( -column => 2, -row => 0, -sticky => "nwes" );
(
	$frame1->new_ttk__label(
		-text   => "installed JREP version : ",
		-width  => 20,
		-anchor => 'center'
	)
)->g_grid( -column => 0, -row => 1, -sticky => "nwes" );
(
	$frame1->new_ttk__entry(
		-textvariable => \$currentJrepVersion,
		-width        => 20,
		-state        => 'readonly'
	)
)->g_grid( -column => 1, -row => 1, -sticky => "nwes" );
my $ButtonUpdateJrep = $frame1->new_ttk__button(
	-text    => 'Update JREP Version',
	-state   => 'active',
	-command => \&updateJrepVersion,
	-width   => 20
);
$ButtonUpdateJrep->g_grid( -column => 2, -row => 1, -sticky => "nwes" );


my $OKButton = $frame2->new_ttk__button(
	-command => \&null,
	-image   => $startInactivePhoto,
	-width   => 50
);
$OKButton->g_grid( -column => 0, -row => 0, -sticky => 'e' );

my $KOButton = $frame2->new_ttk__button(
	-command => \&startNonReg,
	-image   => $stopInactivePhoto,
	-width   => 50
);
$KOButton->g_grid( -column => 1, -row => 0, -sticky => 'w' );

my $ButtonStart = $frame2->new_ttk__button(
	-text    => 'Start Non Reg',
	-state   => 'active',
	-command => \&startNonReg,
	-width   => 20
)->g_grid( -column => 2, -row => 0, -sticky => "we" );

($frame2->new_ttk__checkbutton( -text => "to Run", -variable => \$processRun, -onvalue => 1 , -offvalue => 0, -width => 15 ))
		->g_grid(-column => 0, -row => 1, -sticky => "e");
($frame2->new_ttk__checkbutton( -text => "to Check", -variable => \$processCheck, -onvalue => 1 , -offvalue => 0, -width => 15 ))
		->g_grid(-column => 1, -row => 1, -sticky => "e");
($frame2->new_ttk__checkbutton( -text => "to Save", -variable => \$processSave, -onvalue => 1 , -offvalue => 0, -width => 15 ))
		->g_grid(-column => 2, -row => 1, -sticky => "e");


# Frame #3

 ( $lb = $frame3->new_tk__text( -height => 30, -width => 100, -wrap =>'word' ) )
  ->g_grid( -column => 0, -row => 0, -sticky => "nwes" );
(
	my $s = $frame3->new_ttk__scrollbar(
		-command => [ $lb, "yview" ],
		-orient  => "vertical"
	)
)->g_grid( -column => 1, -row => 0, -sticky => "ns" );
$lb->configure( -yscrollcommand => [ $s, "set" ] );

(
	$frame3->new_ttk__label(
		-text   => $testWarning,
		-anchor => "w"
	)
)->g_grid( -column => 0, -row => 1, -sticky => "we" );
( $frame3->new_ttk__sizegrip )
  ->g_grid( -column => 1, -row => 1, -sticky => "se" );
$frame3->g_grid_columnconfigure( 0, -weight => 1 );
$frame3->g_grid_rowconfigure( 0, -weight => 1 );


my $timer = threads->create(\&timer, \&keepAlive, 300, 1000);


Tkx::MainLoop();

sub initMenu {
	$menu    = $mw->new_menu();
	my $fileMenu = $menu->new_menu(
		-tearoff    => 0,
		-background => 'lightgrey'
	);
	
	$fileMenu->add_command(
	      		-label => "Open",
	      		-underline => 0,
	      		-command => \&getTestListFile
	      );	  
	
	$menu->add_cascade(
		-label => "File",
		-menu  => $fileMenu
	);
	
	my $version = $menu->new_menu(
		-tearoff    => 0,
		-background => 'lightgrey'
	);
	
	my $dlip = $version->new_menu(
		-tearoff    => 0,
		-background => 'lightgrey',
	);
	
	$menu->add_cascade(
		-label => "DLIP",
		-menu  => $dlip
	);
	
	foreach my $i ( 0 .. $#dlipVersionList ) {
		my $rank = $#dlipVersionList - $i;
		$dlip->add_radiobutton(
			-label    => $dlipVersionList[$rank],
			-variable => \$dlipVersionSelectRank,
			-value    => $rank,
			-command  => \&selectDlipVersion
		);
	}
	
	my $jrep = $version->new_menu(
		-tearoff    => 0,
		-background => 'lightgrey',
	);
	
	$menu->add_cascade(
		-label => "JREP",
		-menu  => $jrep
	);
	
	foreach my $i ( 0 .. $#jrepVersionList ) {
		my $rank = $#jrepVersionList - $i;
		$jrep->add_radiobutton(
			-label    => $jrepVersionList[$rank],
			-variable => \$jrepVersionSelectRank,
			-value    => $rank,
			-command  => \&selectJrepVersion
		);
	}
	
	$mw->configure( -menu => $menu );
	
}

sub selectDlipVersion {
	$selectedDlipVersion = $dlipVersionList[$dlipVersionSelectRank];

	#print "current version $currentDlipVersion\n";
}

sub updateDlipVersion {
	my $localdir = system(
"plink $puttySession ~/MARTHA_CGC3/Scripts/martha_upgrade_dlip_version.sh $selectedDlipVersion"
	);
	print "result_test : $localdir\n";
	$currentDlipVersion = getCurrentDlipVersion();
}

sub selectJrepVersion {
	$selectedJrepVersion = $jrepVersionList[$jrepVersionSelectRank];
	print "current version $currentJrepVersion\n";
}

sub updateJrepVersion {
	my $localdir = system(
"plink $puttySession ~/MARTHA_CGC3/Scripts/martha_upgrade_jrep_version.sh $selectedJrepVersion"
	);
	$currentJrepVersion = getCurrentJrepVersion();
}

sub startNonReg {
	$nonRegResult = "OK";
	setLightResultOK();
		  
	foreach my $r_test (@TEST_LIST) {
		my $testName = $r_test->{'Name'};
		my $run_dir  = "$TEST_DIR/$testName";
		my $duration = $r_test->{'Duration'};
		my $type     = $r_test->{'Type'};		
		print "end", "\nrunning test $testName, waiting for $duration s ... " ;
		my $result = `plink $puttySession $REMOTE_ENV ; cd $run_dir; martha_run_test.sh $duration` if ( $processRun );
		$result = system("plink $puttySession $REMOTE_ENV; cd $run_dir; martha_check_test.sh") if ( $processCheck );
		
		#$result = system("plink $puttySession $REMOTE_ENV; cd $run_dir; martha_check_.sh") if ( $type =~ /P/ && $processCheck);
		print "$result\n";
		$testResult = "$testName : OK";
		if ( $result == 0 ) {
			#setLightResultOK();
		}
		else {
			$testResult = "$testName : KO";
			$nonRegResult = "KO";
			setLightResultKO();
		}
		#$lb->delete(1);
		resetListBox();
		my $message = "\n" . $r_test->{'Name'} . " -> " . $testResult ."\n" ;
		print "$message \n";
		insertListBox( $message );
		system(	"plink $puttySession $REMOTE_ENV; cd $run_dir; martha_save_test.sh"	)if( $processSave );
		#last;
	}
	#$lb->delete(0);
	#$lb->insert( "end", "\nNon reg  MARTHA CGC3 C2 terminate !"	);
	insertListBox("*******************\n");
	insertListBox("MARTHA CGC3 NON REG $nonRegResult !\n");
	insertListBox("*******************\n");
}

# init dlip version list
sub getDlipVersionList {
	opendir( DIR, "$dlipVersionDir" ) or die "imposible ouvrir $dlipVersionDir";
	while ( readdir DIR ) {
		my $dir = $_;
		push @dlipVersionList, ($dir);

		#print "$dir\n";
	}
	close DIR;
}

#init jrep version list
sub getJrepVersionList {
	opendir( DIR, "$jrepVersionDir" ) or die "imposible ouvrir $jrepVersionDir";
	while ( readdir DIR ) {
		my $dir = $_;
		push @jrepVersionList, ($dir);
		print "$dir\n";
	}
	close DIR;
}

sub getTestList() {
	my $testList = `plink martha_cgc3_c2_non_reg cat $TEST_LIST_FILE`;
	
	my @line = split("\n",  $testList );
	@TEST_LIST = ();
	foreach my $test ( @line) {
		my ( $test, $duration, $type ) = split( ":", $test );
		print "$test, $duration\n";
		push @TEST_LIST,
		  {
			'Name'     => $test,
			'Duration' => $duration,
			'Type'     => $type
		  };
	}
	resetListBox();
	my $message ="MARTHA CGC3 non reg  \nDLIP : "
		  . $currentDlipVersion
		  . " \nJREP : "
		  . $currentJrepVersion ;
	insertListBox($message);
	foreach my $r_test (@TEST_LIST) {
		$message = "\n$r_test->{'Name'} duration : $r_test->{'Duration'} s ";
		insertListBox($message);
		#print "$r_test->{'Name'} ? $r_test->{'Duration'}\n";
	}
}

sub resetListBox {
	$lb->delete("0.0", "end");
	print "deleted\n";
}

sub insertListBox {
	my $message = shift;
	$lb->insert("end", "$message");
}

sub setLightResultOK {
	$OKButton->configure( -image => $startPhoto );
	$KOButton->configure( -image => $stopInactivePhoto );
}

sub setLightResultKO {
	$OKButton->configure( -image => $startInactivePhoto );
	$KOButton->configure( -image => $stopPhoto );
}

sub getCurrentDlipVersion {
	my $currentDlipVersion = `plink martha_cgc3_c2_non_reg ls -l $ROOT_DIR/executable/martha_main`;
	my @line = split ' ', $currentDlipVersion;
	$currentDlipVersion = $line[10];
	print "$currentDlipVersion";
	$currentDlipVersion =~ s/.\.\/\.\.\/EXECUTABLES\/C2\/(V.*)\/.*/$1/  or $currentDlipVersion = "ERROR";
	return $currentDlipVersion;
}

sub getCurrentJrepVersion {
	my $currentJrepVersion = `plink martha_cgc3_c2_non_reg ls -l $ROOT_DIR/executable/jre_main`;
	my @line = split ' ', $currentJrepVersion;
	$currentJrepVersion = $line[10];
	print "$currentJrepVersion";
	$currentJrepVersion =~ s/.\.\/\.\.\/EXECUTABLES\/JREP\/(V.*)\/.*/$1/  or $currentJrepVersion = "ERROR";
	return $currentJrepVersion;
}

sub getTestListFile(){
	print "$TEST_LIST_DIR\n";
	#my $filename = Tkx::tk___getOpenFile( -initialdir => "\\\\dataunix.clb.tcfr.thales\\cifs02\\sil2_usr\\marthivq\\MARTHA_CGC3\\configuration_files\\non_reg" );
	#my $filename = Tkx::tk___getOpenFile( -initialdir => "/h7_usr/sil2_usr/marthivq/MARTHA_CGC3/configuration_files/non_reg");
	my $filename = Tkx::tk___getOpenFile( -initialdir => "$TEST_LIST_DIR");
	($filename) = fileparse($filename);
	print "$filename\n";
	$TEST_LIST_FILE = "$TEST_LIST_DIR/$filename";
	# init tests list
	getTestList();
}

sub update{
	$lb->insert( "end",
		    "\nupdate...$testResult" );
}

sub timer {
	my($subroutine, $interval, $max_iteration ) = @_;
	for (my $count = 1; $max_iteration == 0 || $count <= $max_iteration; 
	$count++) {
		sleep $interval;
		#$lb->insert(0, "Test insid $count : OK");
		print "count = $count\n";
		&$subroutine;
	}
}

sub keepAlive {
	#$lb->insert("end", "\nkeepAlive : OK");
	my $pwd = `plink martha_cgc3_c2_non_reg pwd`;
	print "still alive...\n $pwd";
}
