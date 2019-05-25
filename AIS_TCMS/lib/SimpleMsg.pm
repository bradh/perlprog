package SimpleMsg;

my @Entete;
my $Length;
my $Seq_number;
my $Source_node;
my $Source_sub_node;
my $Dest_node;
my $Dest_sub_node;
my $Packet_size;
my $Packet_type;
my $Transit_time;
my $Packet_header_data;
my $Msg_sub_type;
my $RC_flag;
my $Net_number;
my $Seq_slot_count_field_2;
my $NPG_number;
my $Seq_slot_count_field_1;
my $STN;
my $Word_count;
my $Loopback_id;
my $Msg_data;

sub new {
	my $r_SimpleMsg = shift;
	$$r_SimpleMsg =~ s/(..)/$1 /g;
	@Entete = split (" ",$$r_SimpleMsg);
	$Length = "$Entete[3]"."$Entete[2]";
	$Length = hex($Length);
	$Seq_number = "$Entete[5]"."$Entete[4]";
	$Seq_number = hex ($Seq_number);
	$Source_node = hex($Entete[6]);
	$Source_sub_node = hex($Entete[7]);
	$Dest_node = hex($Entete[8]);
	$Dest_sub_node = hex($Entete[9]);
	$Packet_size = hex($Entete[10]);	
	$Packet_type = hex($Entete[11]);
	$Transit_time = "$Entete[13]"."$Entete[12]";
	$Transit_time = hex($Transit_time);
	if($Packet_type == 1){
		$$r_SimpleMsg =~ s/\s*//g;
		$Packet_header_data = substr($$r_SimpleMsg, 28);
		$Msg_sub_type = hex(substr($Packet_header_data,0,2));
	  	$RC_flag = hex(substr($Packet_header_data,2,2));
	  	$Net_number = hex(substr($Packet_header_data,4,2));
	  	$Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
	  	$NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
	  	$Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
	  	$STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
	 	$Word_count = hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		$Loopback_id = hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		$Msg_data= substr($Packet_header_data,28);
		$Msg_data =~ s/(....)$//;
		if($Msg_sub_type == 2){
			return \$Msg_data;
		}
		else {
			return 0;
		}
	}
	else {
		return 0;
	}
}

sub printSimpleMsg {
	print "Sync : $Entete[0]$Entete[1]\n";
	print "Length = $Length\n";
	print "Seq_number = $Seq_number\n";
	print "Source node = $Source_node\n";
	print "Source subnode = $Source_sub_node\n";
	print "Dest node = $Dest_node\n";
	print "Dest_sub_node = $Dest_sub_node\n";
	print "Packet size = $Packet_size\n";
	print "Packet type = $Packet_type\n";
	print "Transmit time = $Transit_time\n";
	if($Packet_type == 1){
		print "$$r_SimpleMsg\n$Packet_header_data\n";
	  	print "\tMsg_sub_type = $Msg_sub_type\n";
	  	print "\tRC_flag = $RC_flag\n";
	  	print "\tNet_number= $Net_number\n";
	  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
	  	print "\tNPG_number = $NPG_number\n";
	  	print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
	  	print "\tSTN = $STN\n";
		print "\tWord_count = $Word_count\n";
		print "\tLoopback_id = $Loopback_id\n";
		print "\tMsg_data = $Msg_data\n";
	}
}

1
