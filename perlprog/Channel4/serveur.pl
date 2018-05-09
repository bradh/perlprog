#! /usr/bin/perl -w
# server0.pl
#--------------------

use strict;
use IO::Socket;
use threads;

# use port 7890 as default
my $port = 2000;

my $socket_C4_output : shared = IO::Socket::INET->new (
					
					LocalAddr => 'localhost',
					LocalPort => 2005,
					PeerAddr => 'localhost',
                                 	PeerPort => 2001,
                                 	Proto    => 'udp',
					Broadcast => 1);
my $socket_C4_input : shared = IO::Socket::INET->new (
					
					LocalAddr => 'localhost',
					LocalPort => 2003,
					PeerAddr => 'localhost',
					PeerPort => 2004,
                                 	Proto    => 'udp',
					Broadcast => 1);
				
my $transmit_thread = threads->new(\&transmit_thread, $socket_C4_output);
my $listen_thread = threads->new(\&listen_thread, $socket_C4_input);
$transmit_thread->join;
$listen_thread->join;

sub transmit_thread {
	while(1){
		my $message = chr(1).chr(2).chr(41);
		print "envoi TDH442...\n";
		print $message."\n";
		#print $socket_C4_output $message;
		print $socket_C4_output $message;
		#$socket_C4_output->autoflush();
		#my $line = <$socket_C4>;
		#print "$line";
		sleep 1;
	}
}

sub listen_thread {
	my $line;
	print "Attente THD441\n";
	while(<$socket_C4_input>){
		#print "reception sur $socket_C4\n";
		if($_ =~/THD441/){
			print "nouveau client\n";
			print $socket_C4_output "TDH441 OK\n";
			}
	}
}

close $socket_C4_input;
close $socket_C4_output;



   

