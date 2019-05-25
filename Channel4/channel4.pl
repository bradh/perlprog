 #!/usr/bin/perl -w
#---------------------------------------------------------------
# GR Perl Mongers
# Jeff Williams
# 11/23/1999
# Sockets: Simple UDP Server
#---------------------------------------------------------------
use lib qw(c:/perlprog/lib;.);
#-- Use the socket module - wrapper for C programs of same type

use IO::Socket;
use Message;
use AHD441_block2;
use AHD400;
use AHD116; 
use ADH441_block3;
use Conversion;

use strict;

my $debug =1;

#-- Default some variables
my($datagram, $MAX_TO_READ, $server_port, $server, $oldmsg, $hishost);

#-- Define the port to listen on
$server_port = 10100;

#-- Maximum message size of datagram
$MAX_TO_READ = 1024;

#-- Open a socket
$server = IO::Socket::INET->new(LocalPort => $server_port,
                                Proto     => "udp")
       or die "Couldn't be a udp server on port $server_port : $@\n";

print "Waiting for message of port $server_port...\n";

#-- Now go into a loop receiving messages:
$server->recv($datagram, $MAX_TO_READ);

#-- Here we lookup the client's address
my ($port, $ipaddr) = sockaddr_in($server->peername);
$hishost = gethostbyaddr($ipaddr, AF_INET);

#-- This handles the problem of using the loopback address
if (not defined($hishost)){
        $hishost = "127.0.0.1";
    }

	my ($synchro, $msgLength,$spare, $msgID, $blocks) = Message::decodeMsgHeader($datagram);

	(my $seqNumber, $msgID, my $versionNumber, my $sessionID, my $timeTageMsg, my $msgPriority, $blocks) = Message::decodeDataHeader($blocks);
#	(my $NbOfAppID, $blocks )= Message::decodeADH442Fields($blocks);
	
    #-- Print the results so we can see it    
    print "Datagram received from client $hishost\n";
    #-- Send THD441
    my $appName = "FreeText";
    my $appLogicalID = "100";
    my $protocol = "1";
    my $THD441 = AHD441_block2::getNewMessage($appName, 100, 1);
    print "$THD441 \n";
    $datagram = pack("H*", $THD441);
    $server->send($datagram);
    $msgID = 0;
    while($msgID != 441){
    	$server->recv($datagram, $MAX_TO_READ);
    	($synchro, $msgLength,$spare, $msgID, $blocks) = Message::decodeMsgHeader($datagram);
    	$msgID = hex($msgID);
    }
    my ($ipaddrDLIP, $portDLIP );
	($seqNumber, $msgID, $versionNumber, $sessionID, $timeTageMsg, $msgPriority, $blocks) = Message::decodeDataHeader($blocks);
	if(ADH441_block3::isADH441_block3($blocks)){
		($ipaddrDLIP, $portDLIP )= ADH441_block3::decodeMessage($blocks);	
	}
	my $host = shift || 'localhost';
	$portDLIP = hex($portDLIP);
	print "DLIP port = $portDLIP \n";
	#$ipaddrDLIP = hex($ipaddrDLIP);
	print "$portDLIP, $ipaddrDLIP\n";
	$ipaddrDLIP = Conversion::hexaString2addressIP($ipaddrDLIP);
	# create the socket, connect to the port
	#!/usr/bin/perl -w # biclient - bidirectional forking client use strict; use IO::Socket; 
	my ($kidpid, $handle, $line); 
	$handle = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $ipaddrDLIP, PeerPort => $portDLIP) or die "can't connect to port $portDLIP on $ipaddrDLIP: $!"; 
	#$handle->autoflush(1); # so output gets there right away 
	print STDERR "[Connected to $ipaddrDLIP:$portDLIP]\n"; # split the program into two processes, identical twins 
	die "can't fork: $!" unless defined($kidpid = fork()); 
	my $AHD400 = AHD400::getNewMessage();
    $datagram = pack("H*", $AHD400);
    $handle->send($datagram);
    sleep 5;
    my $AHD116 = AHD116::getNewMessage();
    $datagram = pack("H*", $AHD116);
    print "$datagram\n";
    $handle->send($datagram);
		while (1) { 
			$handle->recv($datagram, $MAX_TO_READ);
    		($synchro, $msgLength,$spare, $msgID, $blocks) = Message::decodeMsgHeader($datagram);
    		#print "byte received = $byteReceived\n msgLength = $msgLength\n";		
		}


	#socket(SOCKET,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2])   or die "Can't create a socket $!\n";
	#connect( SOCKET, pack( 'Sn4x8', AF_INET, $portDLIP, $serverDLIP ))       or die "Can't connect to portDLIP $port! \n";
	#my $line;while ($line = <SOCKET>) {	print "$line\n";}close SOCKET or die "close: $!";	
	print "Server terminated.\n";
exit 0;





