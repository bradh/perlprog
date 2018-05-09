package AHD116;

#!/usr/bin/perl -w

use lib qw(c:/perlprog/lib);

use Conversion;
use Message;

my $debug = 1;

my $msgID = 116;
my $seqNumber = 0;
my $msgVersion = 0;
my $sessionID = 0;
my $msgTimeTag = 0;
my $msgPriority =0;
my $msgLength = 74; # bytes

my $FTInd = 0;		# 1 bit position 1 
my $EMInd = 0;		# 1 bit position 2
my $C2Ind = 1;		# 1 bit position 3
my $NPSI = 1;		# 1 byte
my $TQ = 7; 		# 1 byte
my $PQ = 14; 		# 1 byte
my $strength = 1; 	# 1 byte
my $elevation = 0; 	# 4 bytes
my $missionCorrelation = 0; # 1 byte
my $EQ = 0;			# 1 bytes
my $latitude = 0;	# 4 bytes
my $longitude = 0; 	# 4 bytes

my $indPlatform = 0; # 5 bytes comprend le Voice Call Sign
my $platform = 3; 	# 1 byte
my $platformAct = 0;	# 1 byte
my $voiceChannel = 0;	# 2 byte
my $controlChannel = 0; # 1 byte
my $spare1 = 0; 			# 43 bytes
my $PG = 6;				# 2 bytes

sub getNewMessage {
	print "msgLength 118 : $msgLength\n" if($debug);
	my $msgHeader = Message::getMsgHeader($msgLength, $msgID);
	my $dataHeader = Message::getDataHeader($seqNumber, $msgID, $msgVersion, $sessionID, $msgTimeTag, $msgPriority);
	# including prévious field not used (kind_of_object,...)
   	print "platform $platform\n";
	my $ind = $C2Ind*2**3+$EMInd*2**2+$FTInd*2;
	my $msg = $msgHeader.$dataHeader.
	 sprintf("%02x", $ind).				# 1 bit position 3
	 sprintf("%02x", $NPSI).					# 1 byte
	 sprintf("%02x", $TQ). 					# 1 byte
	 sprintf("%02x", $PQ). 					# 1 byte
	  sprintf("%02x", $strength).			# 1 byte
	  sprintf("%08x", $elevation). 			# 4 bytes
	  sprintf("%02x", $missionCorrelation). # 1 byte
	  sprintf("%02x", $EQ).					# 1 bytes
	  sprintf("%08x", $latitude).			# 4 bytes
	  sprintf("%08x", $longitude). 			# 4 bytes
	  sprintf("%010x", $indPlatform). 		# 5 bytes comprend le Voice Call Sign
	  sprintf("%02x", $platform). 			# 1 byte
	  sprintf("%02x", $platformAct).		# 1 byte
	  sprintf("%04x", $voiceChannel).		# 2 byte
	  sprintf("%02x", $controlChannel). 	# 1 byte
	  sprintf("%086x", $spare1). 			# 43 bytes
	  sprintf("%04x", $PG);					# 2 bytes
   	print "msg $msg\n"if($debug);
   	return $msg;
}

1