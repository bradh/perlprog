#!/usr/bin/perl
#
# le script xmartha_c2_non_reg.pl 
# Identifie la version courante de binaire dlip
# liste la version courante de binaire jrep
# permet à l'utilisateur de selectionner les versions de dlip , de jrep parmi ma liste des versions disponibles
# permet à l'utilisateur de lancer les tests de non regression
# affiche les résultats test par test dans une listbox
# affiche le status de façon graphique ( voyant vert ou rouge)

#use strict;
use Tkx;
use threads;

my $kidpid;

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

my $i = 0;

startThread();
my $j = 0;
while( $j < 10 ){
	print "main : $j\n";
	sleep 2;
	$j += 1;
}
exit 0;


sub selectDlipVersion {
	$currentDlipVersion = "V6E14E10";
}

sub selectJrepVersion {
	$currentJrepVersion = "V3R4E5";
}

sub startThread {
	my $th = threads->create(\&startNonReg);
	#my $toto = $th->join();
	
	$th->detach();
    #print("Thread returned $toto \n");
    return 0;
}

sub startNonReg {
	my $i = 0;
	while ($i < 10) {
		#$lb->insert(0, "Test $i : OK");
		sleep 1;
		print "hello world $i\n";
		$i += 1;
	}
	if($i == 10) {
		print "the end...\n";
		#$lb->insert(0, "Non regresstion tests : OK");
		#$OKButton->configure(-image => 'startPhoto');
		#$KOButton->configure(-image => 'stopInactivePhoto');
	}
	return "toto";
}

