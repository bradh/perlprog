package Data_header;
 
#DATA_HEADER
#SEQUENCE_NUMBER : 32
#MESSAGE_IDENTIFICATION : 16
#VERSION_NUMBER : 8
#SESSION_IDENTIFICATION : 8
#TIME_TAG_MESSAGE : 32
#MESSAGE_PRIORITY : 32



use Octet_field; 
use Conversion;

my $data_header_length = 128 /8;
my $debug = 1;


sub new {
	
	my $seq_number = shift;
	my $msgID = shift;
	my $version_number = shift; # longueur du message suivant le header
	my $session_identification = shift;
	my $time_tag = shift;
	my $priority = shift;
	
	my $struct_msg = {
			"seq" => $seq_number,
			"msgID" => $msgID,
			"version" => $version_number,
			"sessionID" => $session_identification,
			"time_tag" => $time_tag,
			"priority" => $priority};
	bless $struct_msg;
	return $struct_msg;
}

sub set_msgID {
	my $r_struct_msg = shift;
	$r_struct_msg->{"msgID"} = shift;
}

sub get_data_header_length {
	return $data_header_length;
}

sub get_hexa_string {
	my $r_struct_msg = shift;
	my $string = 
		Conversion::toHexaString( $r_struct_msg->{'seq'}, 8).
		Conversion::toHexaString( $r_struct_msg->{'msgID'}, 4 ).
		Conversion::toHexaString( $r_struct_msg->{'version'}, 2).
		Conversion::toHexaString( $r_struct_msg->{'sessionID'}, 2).
		Conversion::toHexaString( $r_struct_msg->{'time_tag'}, 8).
		Conversion::toHexaString( $r_struct_msg->{'priority'}, 8)
		;
		return uc($string);
}
sub get_network_bytes {
	my $r_struct_msg = shift;
	my $network_byte = 	pack('N', $r_struct_msg->{'seq'}).
						pack('n', $r_struct_msg->{'msgID'}).
						pack ('C',$r_struct_msg->{'version'}).
						pack('C', $r_struct_msg->{'sessionID'}).
						pack('N', 	$r_struct_msg->{"time_tag"}).
						pack('N', 	$r_struct_msg->{"priority"});
	return $network_byte;			
}

if($debug == 1){
	my $data_header = new(1, 442, 3, 4, 15223, 5);
	my $string = $data_header->get_hexa_string();
	print "$string \n";
	
	my $network_bytes = $data_header->get_network_bytes;
	$string = unpack("H*", $network_bytes);
	print "$string \n";
	exit 0;
}

1