#!/usr/bin/perl -w
# proxy channel4 permet de connecter plusieurs applications TCP à un DLIP via son interface channel 4
# on ouvre une socket en mode UDP tx / rx
# on reçoit un THD442
# on attend la connexion d'un client
# on fait une demande de connexion via le THD441
# on ouvre une connexion TCP client vers le DLIP 
# on connecte le client au DLIP

use Msg_header;
use Msg_THD441_Open;
use Msg_THD400;
use IO::Socket;
use strict;

my($sock, $server_host, $msg, $port, $ipaddr, $hishost, 
   $MAXLEN, $PORTNO, $TIMEOUT);

$MAXLEN  = 1;
my $HEADER_LEN = 8;
my $PORT_LOCAL = 50015;
my $ADDR_LOCAL = "192.168.15.255";
my $PORT_REMOTE  = 50014;
$TIMEOUT = 20;

$server_host = "192.168.15.124";

$sock = IO::Socket::INET->new(Proto     => 'udp',
							  LocalPort => $PORT_LOCAL,
							  LocalAddr => $ADDR_LOCAL,
                              PeerPort  => $PORT_REMOTE,
                              PeerAddr  => $server_host,
                              Broadcast => 0
                              )
    or die "Creating socket: $!\n";
    
print "read msg\n";
$sock->sysread( $msg, 1000)      or die "recv: $!";
my $msg_hexa = unpack("H*", $msg);
print "read $msg_hexa\n";
if($msg_hexa =~ /4448/){
    # Traitement d'un ADH)
    my ($entete, $length,$spare,$msgID)  = unpack("n2n2n2n2", $msg);
    print "
    	length = $length
    	spare = $spare
    	msgID = $msgID\n";
 	#proceed_tdh442($msg) if($msgID =~ /442/); 
 	
    my $msg_thd441 = Msg_THD441_Open::new("C2", 1002, 1, "192.168.15.124", 1024);
    $sock->syswrite($msg_thd441);
    
	my $msg_hexa = unpack('H*', $msg_thd441);
	print "THD441 $msg_hexa \n";
	
}
sleep 1;
# ouverture de la connexion avec le DLP
my $client_DLP;
my $host_DLP = "192.168.15.124";
my $port_DLP = 1031;

#while(1){
 	print "trying to connect to server $host_DLP sur port $port_DLP\n";
 	eval {
 		$client_DLP = IO::Socket::INET->new(Proto => "tcp",
                                 			PeerAddr  => $host_DLP,
                                 			PeerPort  => $port_DLP)
               || die "can't connect to port $port_DLP on $host_DLP: $!";
 	};
 	if($@ =~ /can't connect/){
 		next;
 	}
 	sleep  1;
 	my $thd400 = Msg_THD400::new();
 	
 	$client_DLP->syswrite($thd400);
 	
 	my $msg_hexa = unpack('H*', $thd400);
	print "thd400 $msg_hexa \n";

#}





sleep 30;






exit 0;
1;  # return value from eval on normalcy


sub proceed_tdh442{
	print "it is a TDH442\n";
	return 0;
}