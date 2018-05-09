package AHD441_block2;

#!/usr/bin/perl -w

use lib qw(c:/perlprog/lib);

use Conversion;
use Message;

my $debug = 1;

my $msgID = 441;
my $msgVersion = 0;
my $sessionID = 0;
my $msgTimeTag = 0;
my $msgPriority =0;
# msgLength = 4 (header) + 16 (Data header) + msg length en octet
my $msgLength = 23;# block 1 + block 2
my $blockID = "003D";
my $dataBlockLength = "0017";
my $protocole = "01";
my $internetAddress = "00000000";
my $port = "10100";
my $hostIPAddress = "10.134.8.186";


sub getNewMessage {
	my ($appName, $appLogicalID, $seqNumber) = (@_);
	my $msgHeader = Message::getMsgHeader($msgLength, $msgID);
	my $dataHeader = Message::getDataHeader($seqNumber, $msgID, $msgVersion, $sessionID, $msgTimeTag, $msgPriority);
	my $block1 = $blockID.$dataBlockLength;
	$appName = unpack( 'H20', $appName );
	$appName = sprintf("%s", $appName);
	$appName = substr($appName."00000000000000000000", 0, 20);
   	print "appName : $appName\n" if($debug);
   	$appLogicalID = sprintf("%04x", $appLogicalID);
   	$internetAddress = Conversion::addressIP2hexaString($hostIPAddress);
   	$port = Conversion::port2hexaString($port);
   	print"$appLogicalID\n$protocole\n$internetAddress\n$port\n";
   	my $block2 = $appName.$appLogicalID.$protocole.$internetAddress.$port;
   	my $msg = $msgHeader.$dataHeader.$block1.$block2;
   	print "$msg\n"if($debug);
   	return $msg;
	
}

1