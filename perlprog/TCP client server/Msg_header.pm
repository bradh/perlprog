package Msg_header;
 
#SYNCH : 8+8
#LENGTH : 16 
#SPARE : 16 
#MESSAGE_ID : 16

#LENGTH, length in bytes of all the following fields including the first spare field {Spare+MESSAGE_ID + MESSAGE_DATA}.
#Spare 16 bits



use Octet_field; 
use Conversion;

my $msg_header_length = 128 /8;
my $debug = 0;


sub new {
	
	my $sync1 = shift;
	my $sync2 = shift;
	my $length = shift; # longueur du message suivant le header
	my $msgID = shift;
	my $spare2 = 0;
	my $network_byte = shift;
	#$sync1_field = Octet_field::new("sync1", 1, $sync1);
	#$sync2_field = Octet_field::new("sync2", 1, $sync2);
	#$length_field = Octet_field::new("length", 2, $length + 4);
	#$spare2_field = Octet_field::new("spare2", 2, 0);
	#$messageID_field = Octet_field::new("msgID", 2, $msgID);
	my $struct_msg = {
			"sync1" => $sync1,
			"sync2" => $sync2,
			"length" => $length,
			"spare2" => $spare2,
			"msgID" => $msgID};
	bless $struct_msg;
	return $struct_msg;
}
sub set_length {
	my $r_struct_msg = shift;
	$r_struct_msg->{"length"} = shift;
}

sub set_msgID {
	my $r_struct_msg = shift;
	$r_struct_msg->{"msgID"} = shift;
}

sub get_msg_header_length {
	return $msg_header_length;
}

sub get_hexa_string {
	my $r_struct_msg = shift;
	my $string = unpack("H2", $r_struct_msg->{'sync1'}).
		unpack("H2", $r_struct_msg->{'sync2'} ).
		Conversion::toHexaString( $r_struct_msg->{'length'}, 4 ).
		Conversion::toHexaString( $r_struct_msg->{'spare2'}, 4 ).
		Conversion::toHexaString( $r_struct_msg->{'msgID'}, 4 );
		return uc($string);
}
sub get_network_bytes {
	my $r_struct_msg = shift;
	my $network_byte = 	pack('A', 	$r_struct_msg->{'sync1'}).
						pack('A', $r_struct_msg->{'sync2'}).
						pack('n', 	$r_struct_msg->{'length'}).
						pack('n', 	$r_struct_msg->{'spare2'}).
						pack('n', 	$r_struct_msg->{"msgID"});
	return $network_byte;			
}

if($debug == 1){
	my $msg_header = new("H", "D", 10, 441);
	my $string = $msg_header->get_hexa_string();
	print "$string \n";
	
	my $network_bytes = $msg_header->get_network_bytes;
	$string = unpack("H*", $network_bytes);
	print "$string \n";
	exit 0;
}

1


