package ADH441_block3;

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
my $msgLength = 23;# block 1 + block 2
my $blockID = "003D";
my $protocole = "00";
my $internetAddress = "00000000";
my $port = "10100";
my $hostIPAddress = "10.134.8.186";

sub isADH441_block3 {
	my $block = shift;
	my ($connectionReport, $dataBlockIdentification, $dataBlockLength) = unpack("H2H4H4", $block);
	$connectionReport = hex($connectionReport);
	$dataBlockIdentification = hex($dataBlockIdentification);
	print "$connectionReport, $dataBlockIdentification, $dataBlockLength\n" if($debug);
	if($dataBlockIdentification == 64 && $connectionReport == 4){
		return 1;
	}
	else {
		return 0;
	}
}

sub decodeMessage {
	my $block = shift;
	my ($connectionReport, $dataBlockIdentification, $dataBlockLength, $appName, $appLogicalName, $protocol, $ipAddrs, $port)= unpack("H2H4H4H20H4H2H8H4", $block);
	if(isADH441_block3($block)){
		($connectionReport, $dataBlockIdentification, $dataBlockLength, $appName, $appLogicalName, $protocol, $ipAddrs, $port)= unpack("H2H4H4H20H4H2H8H4", $block);
		if($debug){
			print "$appName, $appLogicalName, $protocol, $ipAddrs, $port\n";
		}
	}
	else {
		return -1;
	}
	return ($ipAddrs, $port);
}	

1