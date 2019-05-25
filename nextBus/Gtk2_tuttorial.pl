# !/usr/bin/perl -w
use strict ;
use Gtk2 '-init' ;

use  constant TRUE => 1  ;
use constant FALSE => 0 ; 

my $window = Gtk2::Window->new('toplevel') ;

#$window->signal_connect( 'delete_event'  , \&Close_Window,'coucou'  ) ; 
$window->signal_connect( 'destroy'  , \&Destroy_Window ) ;
$window->set_border_width( 100  ) ; 
my  $button = Gtk2::Button->new('Hello World') ; 
$window->add($button ) ;
$button->show;
$window->show ;
Gtk2->main ; 
sub  Destroy_Window {
	Gtk2->main_quit ;
	return FALSE ;
}


