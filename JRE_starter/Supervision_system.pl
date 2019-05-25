#!/usr/bin/perl -w
# Lancement demo marine de façon graphique
#
#  par S. Mouchot

use Getopt::Std;
#use strict;
use Tkx;
use Threads;
use threads::shared;
use Net::Ping;

#require Tk::MenuButton;
my $opt_h;
getopts("h");
my $countx  = 0;
my $a = 0;
my $mw;
my $Hframe1;


# print $ENV{PWD};
if ($opt_h) { 
	print  "Supervision des machines(présence, synchronisation,...)\n";
	exit(0);
}

if(! $opt_h) {

	$mw = Tkx::widget->new(".", -foreground => 'white');
	$mw->g_wm_title( "THALES : System Supervision" );
	$mw->g_wm_geometry( "600x600+600+600");
		
	$widthLabel = 15;
	$startPhoto= Tkx::image_create_photo("startPhoto", -file => "Images/Start_actif.gif");
	$stopPhoto= Tkx::image_create_photo("stopPhoto", -file => "Images/Stop_actif.gif");
	$startInactivePhoto= Tkx::image_create_photo("startInactivePhoto", -file => "Images/Start_inactif.gif");
	$stopInactivePhoto= Tkx::image_create_photo("stopInactivePhoto", -file => "Images/Stop_inactif.gif");
	$blankPhoto = Tkx::image_create_photo("blankPhoto", -file => "Images/Blank.gif");
	
		# Affichage du caractère 
		$Hframe1 = $mw->new_ttk__frame();
		$Hframe1->new_ttk__label(-text  => "JRE-Gateway", -width => 15, -anchor => 'center')
		->g_grid(-column => 1, -row => 1);
		$Hframe1->new_ttk__label(-text => "PC_EXPLOIT", -width => 15, -anchor => 'center')
		->g_grid(-column => 2, -row => 1);
		$Hframe1->new_ttk__label(-text => "LYNX_C3M", -width => 15, -anchor => 'center')
		->g_grid(-column => 3, -row => 1);
		$Hframe1->g_grid(-column => 1, -row => 1);
		my $label = $Hframe1->new_ttk__label( -text => "STATE : ", -width => $widthLabel, -background => 'grey', -anchor => 'center');
		$label->g_grid(-column => 0, -row => 2);
		my $voyant1 = $Hframe1->new_ttk__label( -image => $startPhoto, -width => $widthLabel, -background => 'white', -anchor => 'center');
		$voyant1->g_grid(-column => 1, -row => 2);
		my $voyant2 = $Hframe1->new_ttk__label( -image => $startPhoto, -width => $widthLabel, -background => 'white', -anchor => 'center');
		$voyant2->g_grid(-column => 2, -row => 2);
		my $voyant3 = $Hframe1->new_ttk__label( -image => $startPhoto, -width => $widthLabel, -background => 'white', -anchor => 'center');
		$voyant3->g_grid(-column => 3, -row => 2);
		$voyant3->configure(-image => $stopPhoto);
		
		my $label2 = $Hframe1->new_ttk__label( -text => "COUNT : ", -width => $widthLabel, -background => 'lightgrey');
		$label2->g_grid(-column => 0, -row => 3);
		my $count1 = $Hframe1->new_ttk__label( -text => "toto", -relief => 'solid', -width => $widthLabel, -background => 'white');
		$count1->g_grid(-column => 1, -row => 3);
		my $count2 = $Hframe1->new_ttk__entry( -textvariable => \$countx, -width => $widthLabel, -background => 'grey');
		$count2->g_grid(-column => 2, -row => 3);
		my $count3 = $Hframe1->new_ttk__entry( -textvariable => \$a, -width => $widthLabel, -background => 'grey');
		$count3->g_grid(-column => 3, -row => 3);
		$count3->configure( -state => "readonly");
		
		$count3 = $Hframe1->new_ttk__button( -text => "Start", -width => $widthLabel, -command =>  [\&timer]);
		$count3->g_grid(-column => 3, -row => 4);
		
		timer (\$count2,\$countx);
	#$mw->geometry("-200+10");
	#$mw->update;		
	#my $timer1 = threads->create(\&timer, \&date, 1, 20);
	#$timer1->detach();
		#sleep 2;
		#print "main: $countx $a\n";
		

	Tkx::MainLoop();
}



sub timer {
	my ($count2 , $countx) = @_;
	repeat (1000, sub {date($count2, $countx)});
}

sub date {
	my ($count2 , $countx) = @_;
	$$countx ++;
	print "$$countx";
	Tkx::update();
}	


sub confirmAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Confirmation",
             -message => $text,
             -type => 'yesno'
           );
    #print "response = $reponse";
	return $reponse;
}
sub acquittementAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Acquittement",
             -message => $text,
             -type => 'ok'
           );
    #print "response = $reponse";
	return $reponse;
}
  sub repeat{
      my $ms  = shift;
      my $sub = shift;
      my $repeater; # repeat wrapper
      $repeater = sub { $sub->(@_); Tkx::after($ms, $repeater);};
      my $repeat_id=Tkx::after($ms, $repeater);
      return $repeat_id;
  }

