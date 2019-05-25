package Msg_THD441_Open;


use Msg_header;
use Octet_field; 
use Conversion;

my $THD441_Open_ref = "4844 002b 0000 01b9 00000000 01b9 00 00 6c00ad3d 00000000 003d 0017 43322020202020202020 0001 01 00000000 0000";
#                      4844 002b 0000 01b9 00000001 01b9 00 00 00000000 00000000 003e 0017 43322020202020202020 03ea 00 c0a80f7c 0400
#                      4844 002b 0000 01b9 00000001 01b9 00 02 00000000 00000000 003e 0017 43322020202020202020 03ea 00 c0a80f7c 0400
#					  "4844 002b 0000 01b9 00000001 01b9 00 01 00000000 00000002 0002 0017 43322020202020202020 0001 3e 03040506 c35e
#						4844 0027 0000 01b9 00000001 01b9 00 01 00000002          0002 0017 43322020202020202020 0001 02 03040506 c35e
#						4844 002e 0000 01b9 00000001 01b9 00 00 0001     00000002 0002 0017 43322020202020202020 0001 0002 0003000400050006 c35e
#    					4844 002e 0000 01b9 00000001 01b9 00 00 01000000 00020002 1700 4332202020202020202003ea0100c000a8000f007c00c35e
#                       4844 0026 0000 01b9 00000001 01b9 30 31 00000002 000232        4332202020202020202003ea3 1313 13 131         c35e
print length($THD441_Open_ref);
my $THD442 =          "4448 0015 000001ba 0000000401ba0000632637b30000000000";
# récupérer les octets et les transformer en byte



my $msg_thd441_length;
my $debug = 0;

#my $msg = new("C2", 1, 62, "3.4.5.6", 7);


sub new {

	my $app_name = shift;	
			$app_name = substr($app_name.'               ', 0, 10);
	my $app_logical_id = shift;
	my $protocol = shift;
	my $ip_address = shift;
	my @ip_address = split('\.', $ip_address);
	my $port = shift;
	
	my $msg_header; 
	
	my $seq_num = 1;
	my $msg_id = 441;
	my $version = 0;
	my $session_id = 0;
	my $msg_priority = 0;
	
	my $data_block_id = 61;
	my $data_block_length = 23;
	
	
	if($data_block_id == 61){
		$msg_thd441_length = 184/8;
		$msg_data = 					 pack ('n', 0)
										. pack('n', $msg_id)
										. pack('N', $seq_num) 
										. pack('n', $msg_id) 
										. pack('C', $version) 
										. pack('C', $session_id) 
										. pack ('N', 0)
										. pack('N', $msg_priority)
										. pack('n', $data_block_id)
										. pack('n', $data_block_length)
										. pack('A10', $app_name)
										. pack('n', $app_logical_id)
										. pack('C', $protocol)
										. pack ('C', $ip_address[0])
										. pack ('C', $ip_address[1])
										. pack ('C', $ip_address[2])
										. pack ('C', $ip_address[3])
										. pack ('n', $port);
										
		my $msg = pack('A2', 'HD').pack('n', length($msg_data)).$msg_data;
		    $length = length($msg);
		print "msg : $length \n";
		print "thd msg : $msg\n";
		
		my $msg_hexa = unpack('H*', $msg);
		
		print $msg_hexa . "\n";

		#296 - 128 (header)
		#seq num 32
		# pack('N', $seq_num);
		#Msg ID  16
		# pack('n', $msg_id);
		#Version 8
		# pack('s', $version);
		#sessionID 8
		# pack('s', $session_ID)
		#Time tag 32
		#Msg priority 32
		# pack('N', $msg_priority);
		#block2
		#Data block id 16 003D
		#pack('n', $data_block_id);
		#Data block length 16 23 0017
		# pack('s', $data_block_length);
		#APP Name 80
		# pack('A10', $app_name);
		#APP Logical id 16
		# pack('n', $app_logical_id);
		#Protoco 8
		# pack('s', $protocol);
		#Adress 32 
		# pack ('N', $address_32);
		#port 16 
		# pack ('n', $port);
		
		my $struct_msg = {
			"msg_header" => $msg_header,
			"app_name"	=>	$app_name,
			"app_id"	=>	$app_id,
			"protocol"	=>	$protocol,
			"ip_address" =>	$ip_address,
			"port"		=>	$port
		};
		bless $struct_msg;
		return $msg;
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
	my $network_bytes;
	# = pack('n4',  $r_struct_msg->{"msg_header"}).
	#					pack('A10', $r_struct_msg->{"app_name"}).
	#					pack('n', 	$r_struct_msg->{"app_id"}).
	#					pack('C', 	$r_struct_msg->{"protocol"}).
	#					pack('C4',	split ('\.', $r_struct_msg->{"ip_address"})).
	#					pack('n', 	$r_struct_msg->{"port"});
	$network_bytes = pack( 'H*', $THD441_Open_ref);
	
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