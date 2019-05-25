#!/usr/bin/perl -w


use strict ; # une bonne idée pour tout script Perl non-trivial

# Charge le module Gtk2 et lance une procedure d'initialisation de
# la bibliothjque C
use Glib;
use Tk;
use Time::localtime;

 
      
my $time = 0;
my $operand1 = 1;
my $operand2 = 2;
my $result = 3;
my $goodResult = 0;
my $totalResult = 0;
my $resultTrue = 0;

my $mw = MainWindow->new;
$mw->title( "Addition" );
my $Vframe1=$mw->Frame->pack;
$Vframe1->Label(-text => 'Hola Nicolas , preparado ?')->pack(-side => 'top');

my $Vframe12=$mw->Frame->pack();

$Vframe12->Label(-text => " > ")->pack(-side => 'left');
$Vframe12->Entry(-textvariable => \$operand1,  -width => 2, -borderwidth => 2)->pack(-side =>'right',
	       						-padx => 1, 
							-anchor => 'n');
my $Vframe2=$mw->Frame->pack;						
$Vframe2->Label(-text => ' + ')->pack(-side => 'left');
$Vframe2->Entry(-textvariable => \$operand2,  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');

my $Vframe3=$mw->Frame->pack;
$Vframe3->Label(-text => ' = ')->pack(-side => 'left');
my $entryResult = $Vframe3->Entry(-textvariable => \$result,  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
my $Vframe4=$mw->Frame->pack;
my $buttonCheck = $Vframe4->Button(-text => 'Valide ton résultat',	-state => 'active',	
       							-command => \&check)->pack(-side => 'left');
my $Vframe5=$mw->Frame->pack;
$Vframe5->Label(-text => "Ton résultat : " )->pack(-side => 'left');
$Vframe5->Label(-textvariable => \$goodResult )->pack(-side => 'left');
$Vframe5->Label(-text => " / " )->pack(-side => 'left');

$Vframe5->Label(-textvariable => \$totalResult )->pack(-side => 'left');

MainLoop;

sub check {
	print "$operand1 + $operand2 = $result\n";
	if($resultTrue == 0) {
		if($result == $operand1 + $operand2){
			$entryResult->configure(-background => 'green');
			$goodResult += 1;
			$totalResult += 1;
		}
		else {
			$entryResult->configure(-background => 'red');
			$totalResult += 1;
		}
		#$resultTrue = 1;
		$buttonCheck->configure(-text => 'Nouvelle addition');
	}
	if($resultTrue == 1){
		$operand1 = int(rand 20)+1;
		$operand2 = int(rand 20)+1;
		$result = "";
		$entryResult->configure(-background => 'white');
		#$resultTrue = 0;
		$buttonCheck->configure(-text => 'vérifie ton résultat');
	}
	if ($resultTrue == 1){
		$resultTrue = 0;
	}
	else{
		$resultTrue = 1;
	}	
	return;
}
	
