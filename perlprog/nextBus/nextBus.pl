#!/usr/bin/perl -w


use strict ; # une bonne idée pour tout script Perl non-trivial

# Charge le module Gtk2 et lance une procedure d'initialisation de
# la bibliothjque C
#use Glib;
use Tk;
use Time::localtime;

# Variables convenables pour vrai et faux
use constant TRUE => 1 ;
use constant FALSE => 0 ;

my $transit = 1; # nombre de minute nicessaire pour atteindre le bus
my @horaire;     # tableau des horaires
my $nom;
my $startTime = "00:00";
my $currentTime = "00:00";

# Lecture du fichier nextBus.cfg
open Fin, "<./nextBus.cfg" or die "Impossible de trouver nextBus.cfg !\n";	
my $i = FALSE;
while(<Fin>) {
    chomp;
    my $line = $_;
    print "$line\n";
    if($line =~/^Transit/){
	(my $toto, $transit) = split (":", $_);
	print "$toto = $transit\n";
    }
    if($line =~/Horaire/){
	$i = TRUE;
    }
    if($line !~ /Horaire/ && $i) {
	#print "line : $line\n";
	(my $heure, my $minute) =  split(":", $line);
	#print "$heure, $minute\n";
	my $chrono = time2Chrono($heure, $minute, "0");
	push @horaire, $chrono;
	#print "$chrono\n";
    }
}
close Fin;

# Tri du tableau 
 # my @horaire_sort = sort  
      
my $time = 0;
my $mw = MainWindow->new;
#print "titi\n";
$mw->title( "Next Bus Departure" );
my $Vframe1=$mw->Frame->pack;
$Vframe1->Label(-text => 'Next Departure')->pack(-side => 'top');	
$Vframe1->Entry(-textvariable => \$startTime,  -width => 6, -borderwidth => 2)->pack(-side =>'top',
	       						-padx => 1, 
							-anchor => 'n');
my $Vframe2=$mw->Frame->pack;
$Vframe2->Label(-text => 'Current Time')->pack(-side => 'top');	
$Vframe2->Entry(-textvariable => \$currentTime,  -width => 6, -borderwidth => 2)->pack(-side =>'top',
	       						-padx => 1, 
							-anchor => 'n');
$mw->Button(
        -text => 'Refresh',
        -command => \&Compteur
    )->pack;
    
Compteur();					
MainLoop;


sub Compteur{
	# Calcul de l'heure courante
    my($widget,$donnee)=@_; 
    #print "titi\n";
    my $current_heure = localtime->hour();
    $current_heure = sprintf("%02d", $current_heure );
    my $current_minute = localtime->min();
    $current_minute = sprintf("%02d", $current_minute );
    my $current_chrono = time2Chrono($current_heure, $current_minute, "0");
    # Ajout du temps de transit
    $current_chrono = $current_chrono + $transit*60;
    # Calcul du prochain dipart
    my $test_result = FALSE;
    my $nextDeparture;
    foreach (@horaire){
	if ($_ > $current_chrono && ! $test_result){
	    $test_result = TRUE;
	    $nextDeparture = $_;
	    last;
	}
   }
    
    # Codage de l'heure de dipart
    if($test_result){
	(my $departure_hour, my $departure_minute) = (chrono2Time($nextDeparture));
	$startTime = "$departure_hour:$departure_minute";
	print "$startTime\n";
    }
    print "Game Over\n" if( ! $test_result);
    $currentTime = "$current_heure:$current_minute";
    #sprintf ("\a");
    #sleep 1;
    #   my $timeout = Glib::Timeout->add(1000, \&Compteur);
    return;
}

sub Schedule {
   	my $message = "Schedule :\n";
   	# Recherche des horaires et formattage
   	foreach (@horaire){
       		my $chrono = $_;
       		#print "$chrono";
       		(my $heure, my $minute, my $seconde) = (chrono2Time($chrono));
       		$message = "$message"."$heure:$minute\n";
    	}
   	$message = "$message"."Game Over\n";
	#my $dialog = Gtk2::Dialog->new ('Message' , $window,  
	#                          'destroy-with-parent',  
	#                          'gtk-ok' => 'none' );  
	#my $label = Gtk2::Label->new($message);  
	#$dialog->vbox->add($label);  
	return;
}

# convertit un chrono en nombre d'heure de minute et de seconde
sub chrono2Time {
    my $chrono = shift;
    my $heure = int ($chrono/3600) ;
    my $minute = int (($chrono - ($heure*3600))/60);
    my $seconde = $chrono - ($heure*3600) - ($minute *60);
    #print " sec = $seconde\n";
    my $milliSeconde;
    $heure = sprintf("%02d", $heure);
    #print "heure = $heure\n";
    $minute = sprintf("%02d", $minute);
    #print "minute = $minute\n";
    $seconde = sprintf ("%02.3f", $seconde);
    $seconde =~ s/,/\./;
    #print "seconde = $seconde\n";
    my @heure = ($heure,$minute,$seconde);
    return (@heure);
}

# convertit une heure au format hh:mm:ss.sss en chrono (secondes)
sub time2Chrono {
    (my $heure, my $minute, my $seconde) = (@_);
    my $chrono = $heure*3600 + $minute*60 + $seconde;
    return $chrono;
}
