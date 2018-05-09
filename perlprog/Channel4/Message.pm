package Message;

my $FLOW_TRACER = 1;

use lib qw(c:/perlprog/lib);

use Conversion;

my $debug = 0;

my $sync = "4844"; 
my $overHead = 22;


sub decodeMsgHeader{
	my $datagram = shift;
	my ($synchro, $msgLength,$spare, $msgID, $blocks)= unpack("H4H4H4H4a*", $datagram);
	if ($FLOW_TRACER == 1){
		my $msgID2 = hex($msgID);
		if($synchro =~ /4844/){
			print "$msgID2 --> \n";
		}
		if($synchro =~ /4448/){
			print "\t <-- $msgID2\n";
		}
	}
	return ($synchro, $msgLength, $spare, $msgID, $blocks);
}
sub getMsgHeader{
	print "getMsgHeader\n" if($debug);
	my ($msgLength, $msgID)= (@_);
	print "$msgLength, $msgID \n " if($debug);
	$msgLength += $overHead;
	$msgLength = Conversion::toHexaString($msgLength, 4);
	$msgID = Conversion::toHexaString($msgID, 4);
	$msgHeader = $sync.$msgLength."0000".$msgID;
	print "$msgHeader\n" if($debug);
	return $msgHeader;
}
sub decodeDataHeader{
	my $datagram = shift;
	my ($seqNumber, $msgID, $versionNumber, $sessionID, $timeTageMsg, $msgPriority, $blocks)= unpack("H8H4H1H1H8H8a*", $datagram);
	if($debug){
			print "seqNumber : $seqNumber\n";
			print "msgID : $msgID\n";
			print "version : $versionNumber\n";
			print "sessionID : $sessionID\n";
			print "time tag : $timeTageMsg\n";
			print "msgPriority : $msgPriority\n";
	}
	return ($seqNumber, $msgID, $versionNumber, $sessionID, $timeTageMsg, $msgPriority, $blocks);
}
sub getDataHeader{
	my ($seqNumber, $msgID, $versionNumber, $sessionID, $timeTagMsg, $msgPriority) = (@_);
	$seqNumber = Conversion::toHexaString($seqNumber, 8);
	$msgID = Conversion::toHexaString($msgID, 4);
	$versionNumber = Conversion::toHexaString($versionNumber, 2);
	$sessionID = Conversion::toHexaString($sessionID, 2);
	$timeTagMsg = Conversion::toHexaString($timeTagMsg, 8);
	$msgPriority = Conversion::toHexaString($msgPriority, 8);
	my $msgHeader = $seqNumber.$msgID.$versionNumber.$sessionID.$timeTagMsg.$msgPriority;
	return $msgHeader;
}
1