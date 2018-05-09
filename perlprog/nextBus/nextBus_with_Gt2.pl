#!/usr/bin/perl -w


use strict ; # une bonne id-Aie pour tout script Perl non-trivial

# Charge le module Gtk2 et lance une procidure d$(B!G(Binitialisation de
# la bibliothjque C
use Glib;
use Gtk2 '-init';
use Time::localtime;

# Variables convenables pour vrai et faux
use constant TRUE => 1 ;
use constant FALSE => 0 ;

my $transit = 1; # nombre de minute nicessaire pour atteindre le bus
my @horaire;     # tableau des horaires
my $nom;

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
# Criation d$(B!G(Bune fejtre
my $window = Gtk2::Window->new('toplevel') ;
# Quand on attribue le signal $(B!I(Bdelete_event$(B!I`(B une fenjtre ( ce qui est
# attribui par le gestionnaire de fenjtre, soit par l$(B!G(Boption $(B!I(Bfermer$(B!I(B soit
# par la barre de titre), on demande ` celle-ci d$(B!G(Bappeler la fonction
# Close_Window difinie plus loin.
#$window->signal_connect( 'delete_event' , \&Close_Window,'coucou' ) ;
# Ici, on connecte l$(B!G(Bevenement $(B!I(Bdestroy$(B!I`(B un gestionnaire de signal.
# Cet evenement se produit quand on appelle la fonction Gtk2::widget_destroy
# sur la fenjtre ou si la fonction de rappel liie au $(B!I(Bdelete_event$(B!I(B retourne
# FALSE.
#$window->signal_connect( 'destroy' , \&Destroy_Window ) ;
# On diclare les attributs de la fenjtre. Il s$(B!G(Bagit ici d$(B!G(Bune bande de 15 pixels
# disposie sur le contour de la fenjtre afin que celle-ci ne soit pas trop
# $(B!I(Brabougrie$(B!I(B !
$window->set_border_width( 5 ) ;

$window->set_title( "Next Bus Departure") ;

my $hbox = Gtk2::HBox->new( FALSE, 5 ) ;
$window->add( $hbox ) ;

my $vbox1 = Gtk2::VBox->new( FALSE, 5 ) ;
$hbox->pack_start( $vbox1, FALSE, FALSE, 0 ) ;

my $label1 = Gtk2::Label->new( "00:00") ;
my $frame1 = Gtk2::Frame->new( "Next Departure") ;
$frame1->add( $label1 ) ;
$vbox1->pack_start( $frame1, FALSE, FALSE, 0 ) ;

my $label2 = Gtk2::Label->new( "00:00") ;
my $frame2 = Gtk2::Frame->new( "Current Time") ;
$frame2->add( $label2 ) ;
$vbox1->pack_start( $frame2, FALSE, FALSE, 0 ) ;

my  $button1 = Gtk2::Button->new("Schedule") ;
$button1->signal_connect(clicked =>\&Schedule ) ;
$vbox1->pack_start($button1, FALSE, FALSE, 0);

my $timeout = Glib::Timeout->add(1000, \&Compteur);

$window->show_all();

# Toute application en Gtk2-Perl doit possider la ligne suivante qui
# lance la boucle principale.
Gtk2->main ;

sub Compteur{
    # Calcul de l'heure courante
    my($widget,$donnee)=@_; 
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
	$label1->set_text("$departure_hour:$departure_minute");
    }
    $label1->set_text("Game Over") if( ! $test_result);
    $label2->set_text("$current_heure:$current_minute");
    sprintf ("\a");
    my $timeout = Glib::Timeout->add(1000, \&Compteur);
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
   my $dialog = Gtk2::Dialog->new ('Message' , $window,  
                                   'destroy-with-parent',  
                                   'gtk-ok' => 'none' );  
   my $label = Gtk2::Label->new($message);  
   $dialog->vbox->add($label);  
   ### Pour jtre s{r que la fenjtre de dialogue soit ditruite aprhs  
   ### le click de l'utilisateur  
 #  $dialog->signal_connect (response => sub {$_[0]->destroy;});  
 
 #  $dialog->show_all;  
    return;
}

### La fonction de rappel appelie par l$(B!G(Bevenement $(B!I(Bdelete_event$(B!I(B.
sub Close_Window {
# Si vous retournez FALSE dans le gestionnaire de l$(B!G(Bevenement
# $(B!I(Bdelete_event$(B!I(B, alors le signal $(B!I(Bdestroy$(B!I(B sera emis.
# Si vous retournez TRUE, c$(B!G(Best que vous ne voulez pas que la
# fenjtre soit ditruite.
# C$(B!G(Best utile si on veut demander une confirmation du style
# $(B!I(B voulez-vous vraiment quitter ?$(B!I(B dans une bonte de dialogue.
# Changez TRUE en FALSE et la fenjtre principale sera ditruite.
return FALSE ;
}

### La fonction de rappel pour fermer la fenjtre
sub Destroy_Window {
Gtk2->main_quit ;
return FALSE ;
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
