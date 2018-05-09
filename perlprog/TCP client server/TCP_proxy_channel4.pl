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
use IO::Socket;
use strict;

my($sock, $server_host, $msg, $port, $ipaddr, $hishost, 
   $MAXLEN, $PORTNO, $TIMEOUT);

$MAXLEN  = 1;
my $HEADER_LEN = 8;
my $PORT_LOCAL = 50015;
my $PORT_REMOTE  = 50014;
$TIMEOUT = 20;

$server_host = "127.0.0.1";

$sock = IO::Socket::INET->new(Proto     => 'udp',
							  LocalPort => $PORT_LOCAL,
                              PeerPort  => $PORT_REMOTE,
                              PeerAddr  => $server_host)
    or die "Creating socket: $!\n";
#$sock->send($msg) or die "send: $!";
#sleep 12;
#eval {
	while (1){
		$sock->read($msg, $MAXLEN)      or die "recv: $!";
    	$msg = unpack("H2", $msg);
    	print "$msg\n";
		while($msg !~ /44/){
			print "waiting receiving sync 1...\n";
    		#local $SIG{ALRM} = sub { die "alarm time out" };
    		#alarm $TIMEOUT;
    		$sock->read($msg, 1)      or die "recv: $!";
    		$msg = unpack("H2", $msg);
    		print "$msg\n";
		}
		$sock->read($msg, 1)      or die "recv: $!";
    	$msg = unpack("H2", $msg);
    	print "$msg\n";
    	if($msg =~ /48/){
    		# Traitement d'un ADH)
    		#Lecture de l'entete
    		$sock->read($msg, $HEADER_LEN-2)      or die "recv: $!";
    		my ($length,$spare,$msgID)  = unpack("n2n2n2", $msg);
    		print "
    		length = $length
    		spare = $spare
    		msgID = $msgID\n";
    		$sock->read($msg, $length-4);
    		proceed_tdh442($msg) if($msgID =~ /442/); 
    	}
    	else {
    		next;
    	}
    	#alarm 0;
    1;  # return value from eval on normalcy
}
#} or die "recv from $server_host timed out after $TIMEOUT seconds.\n";

($port, $ipaddr) = sockaddr_in($sock->peername);
$hishost = gethostbyaddr($ipaddr, AF_INET);
print "Server $hishost responded ``$msg''\n";

my $msg_thd441 = Msg_THD441_Open::new("COM", 1002, 1, "192.168.0.50", 1024);;
my $string = $msg_thd441->get_hexa_string();
print "$string \n";

exit 0;

sub proceed_tdh442{
	print "it is a TDH442\n";
	return 0;
}