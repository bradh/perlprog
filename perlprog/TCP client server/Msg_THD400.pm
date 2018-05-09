package Msg_THD400;


use Msg_header;
use Octet_field; 
use Conversion;

my $THD400_ref = "4844 002b 0000 01b9 00000000 01b9 00 00 6c00ad3d 00000000 003d 0017 43322020202020202020 0001 01 00000000 0000";
#                 4844 0018 0000 0190 00000002 0190 00 02 00000000 00000000 0001 0045
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

	my $msg_header; 
	
	my $seq_num = 2;
	my $msg_id = 400;
	my $version = 1;
	my $session_id = 2;
	my $msg_priority = 0;
	
	my $nb_of_msg = 1;	
		
	$msg_data = 				pack ('n', 0)
								. pack('n', $msg_id)
								. pack('N', $seq_num) 
								. pack('n', $msg_id) 
								. pack('C', $version) 
								. pack('C', $session_id) 
								. pack ('N', 0)
								. pack('N', $msg_priority)
								. pack('C', 0)
								. pack('C', $nb_of_msg)
								. pack('n', 69);
									
	my $msg = pack('A2', 'HD').pack('n', length($msg_data)).$msg_data;

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
	return $msg;
}

1