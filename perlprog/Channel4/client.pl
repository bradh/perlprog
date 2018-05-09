#! /usr/bin/perl -w
# client1.pl - a simple client
#----------------

use strict;
use IO::Socket;
use threads;
use XML::Simple;

my $socket_C4_output = IO::Socket::INET->new( 	
					LocalAddr => 'localhost',
					LocalPort => 2004,
					PeerAddr => 'localhost',
					PeerPort => 2003,
                                 	Proto    => 'udp',
					Broadcast => 1) or die "impossible ouvrir socket n";
my $socket_C4_input = IO::Socket::INET->new( 	
					LocalAddr => 'localhost',
					LocalPort => 2001,
					PeerAddr => 'localhost',
					PeerPort => 2005,
                                 	Proto    => 'udp',
					Broadcast => 1) or die "impossible ouvrir socket n";
my $connection = 0;
my $line;
while (1){
print "Attente TDH442\n";
#binmode($socket_C4_input);
read($socket_C4_input, $line, 2);
#close $socket_C4_input or die "close: $!";
print "Receive $line";
sleep 1;
}

#sleep 10;
#$number = sysread($socket_C4_input, $line, 12);
#print "Receive $line";
while(0) {
	#$number = sysread($socket_C4_input, $line, 12);
	
	#print "Receive $line";
	if ($line =~ /TDH442/){
		if(!$connection){
			print "envoi THD441\n";
			print $socket_C4_output "THD441\n";
			#sleep 1;
			print "OK\n";	
		}
	}
	if($line =~ /TDH441/){
		# si OK
		$connection = 1; 
		print "$line\n";
		# creation d'un thread pour la connection
		print "Send THD400\n";  
		print $socket_C4_output "THD400\n";
	} 
}

close $socket_C4_input or die "close: $!"; 
close $socket_C4_output or die "close: $!";
exit 0;
