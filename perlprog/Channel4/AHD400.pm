package AHD400;

#!/usr/bin/perl -w

use lib qw(c:/perlprog/lib);

use Conversion;
use Message;

my $debug = 1;

my $msgID = 400;
my $seqNumber = 0;
my $msgVersion = 1;
my $sessionID = 0;
my $msgTimeTag = 0;
my $msgPriority =0;
my @msgList = (86, 69, 180);


sub getNewMessage {
	my $nbOfMessage = scalar @msgList;
	print "nber of message : $nbOfMessage\n" if($debug);
	# msgLength = 4 (header) + 16 (Data header) + msg length en octet
	my $msgLength = 4 + $nbOfMessage*2; # block 1 + block 2
	print "msgLength 400 : $msgLength\n" if($debug);
	my $msgHeader = Message::getMsgHeader($msgLength, $msgID);
	my $dataHeader = Message::getDataHeader($seqNumber, $msgID, $msgVersion, $sessionID, $msgTimeTag, $msgPriority);
	# including prévious field not used (kind_of_object,...)
   	$nbOfMessage = sprintf("%02x", $nbOfMessage);
   	$nbOfMessage = "010100".$nbOfMessage;
   	my $msgList = "";
   	foreach my $msgID (@msgList){
   	 	$msgList = $msgList.sprintf("%04x", $msgID);
   	}
   	print "msgList : $msgList \n" if($debug);
   	my $msg = $msgHeader.$dataHeader.$nbOfMessage.$msgList;
   	print "msg $msg\n"if($debug);
   	return $msg;
}

1