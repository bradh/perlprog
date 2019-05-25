package Msg_THD441_Open;


use Msg_header;
use Octet_field; 
use Conversion;

my $msg_thd441_length;
my $debug = 0;


sub new {
	my $data_block_id = 2;
	my $data_block_length = 152/8;
	my $app_name = shift;
	#print $app_name;
	$app_name = substr($app_name.'               ', 0, 10);
	
	#print $app_name;
	#exit 0;
	my $app_id = shift;
	my $protocol = shift;
	my $ip_address = shift;
	my $port = shift;
	my $msg_header;
	
	if($data_block_id == 2){
		$msg_thd441_length = 184/8;
		
		$msg_header = Msg_header::new("H", "D", $msg_thd441_length, 441 );
		my $struct_msg = {
			"msg_header" => $msg_header,
			"app_name"	=>	$app_name,
			"app_id"	=>	$app_id,
			"protocol"	=>	$protocol,
			"ip_address" =>	$ip_address,
			"port"		=>	$port
		};
		bless $struct_msg;
		return $struct_msg;
	}
	else {
		return 0;
	}
}

sub get_hexa_string {
	my $r_struct_msg = shift;
	my @ip_address = split ('\.', $r_struct_msg->{"ip_address"});
	my $string = $r_struct_msg->{"msg_header"}->get_hexa_string(); # header
	
	$string = $string . unpack("H*", $r_struct_msg->{"app_name"}).
		Conversion::toHexaString( $r_struct_msg->{"app_id"}, 4 ).
		Conversion::toHexaString( $r_struct_msg->{"protocol"}, 2 ).
		Conversion::toHexaString( $ip_address[0], 2 ).
		Conversion::toHexaString( $ip_address[1], 2 ).
		Conversion::toHexaString( $ip_address[2], 2 ).
		Conversion::toHexaString( $ip_address[3], 2 ).
		Conversion::toHexaString( $r_struct_msg->{"port"}, 4 );
		return uc($string);
}

sub get_network_bytes {
	my $r_struct_msg = shift;
	my $network_bytes = $r_struct_msg->{"msg_header"}->get_network_bytes().
						pack('A10', $r_struct_msg->{"app_name"}).
						pack('n', 	$r_struct_msg->{"app_id"}).
						pack('C', 	$r_struct_msg->{"protocol"}).
						pack('C4',	split ('\.', $r_struct_msg->{"ip_address"})).
						pack('n', 	$r_struct_msg->{"port"});
	
	return $network_bytes;			
}

if($debug == 1){
	my $msg_thd441 = new("COM", 1002, 1, "192.168.0.50", 1024);
	my $string = $msg_thd441->get_hexa_string();
	print "THD441 $string \n";
	$network_bytes = $msg_thd441->get_network_bytes();
	($string1) =uc(unpack('H*', $network_bytes));

	print "THD441 $string1 \n";
	
}

1