package aladdin_FIM01_J7_0;

my $test = 0;

my $FIM01_J7_0 = "00:00:00.000 00000016 06000001 0000 0348 0000 0000 0000 0000 0007 0015 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000";
my $FIM01_J7_0_v6 = "00:00:00.000 00000071 00000065 0000 0000 0065 0600 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 00FF FFFF 01FF 01FF 01FF FF00 3F64 0000 0000 0000 0000 00";
my $FIM01_ref;

my $length_offset = 20;
my $length_length = 4;
my $PG_offset = 96;
my $PG_length = 8;			# attntion la longueur du champs dans aladdin est de 16 mais sul les 8 premier bit sont utilises
my $STN_offset = 112;
my $STN_length = 16;
my $LTN_offset = 147;
my $LTN_length = 19;

sub new {
	my $r_message = shift;
	
	if($$r_message =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\S{8}) (\S{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/\s?//g;
		my $r_FIM01_J7_0 = {
			'message' => $$r_message,
			'time'	=> $time,
			'length' => $length,
			'msg_id' => $msg_ID,
			'msg_data' => $msg_data
		};
		print "bless ref\n";
		bless $r_FIM01_J7_0;
		return $r_FIM01_J7_0;
	}
	else {
		print "erreur new J7 0\n";
		return -1;
	}
}

sub toBinaryDataMsg {
	my $r_message  = shift;
	my $msg_data = $r_message->{msg_data};
	$msg_data =~ s/\s?//g;
	my $bytes = pack('H*', $msg_data);
	my $msg_data_binary = unpack('B*', $bytes);
	print "$msg_data_binary\n";
	return $msg_data_binary;
}

sub binaryToHexaDataMsg {
	my $r_message  = shift;
	my $r_binary_message = shift;
	my $msg_data_binary = $$r_binary_message;
	my $bytes = pack('B*', $msg_data_binary);
	my $msg_data_hexa = unpack('H*', $bytes);
	print "$msg_data_hexa\n";
	$r_message->{'msg_data'} = $msg_data_hexa;
	return $msg_data_hexa;
}

sub format_FIM01_J7_0{
	my $r_FIM01_J7_0 = shift;
	if($$r_FIM01_J7_0 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/(\S{4})/$1 /g;
		$$r_FIM01_J7_0 = "$time $length $msg_ID $msg_data";
	}
}

sub get_FIM01_J7_0{
	my $r_FIM01_J7_0 = shift;
	my $message = "$r_FIM01_J7_0->{time} $r_FIM01_J7_0->{length} $r_FIM01_J7_0->{msg_id} $r_FIM01_J7_0->{msg_data}";
	print "$message\n";
	return $message;
}

sub setTimetag_Message{
	my $timetag_msg = shift;
	my $r_FIM01_J7_0 = shift;
	$timetag_msg = uc(Conversion::toHexaString($timetag_msg, 8));
	return -1 if(!defined($r_FIM01_J7_0));
	if($$r_FIM01_J7_0 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$timetag_msg, $$r_FIM01_J7_0\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $timetag_msg_offset/4, ($timetag_length)/4) = $timetag_msg;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_FIM01_J7_0 = "$time $length $msg_ID $msg_data";
		#print "$$r_FIM01_J7_0 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setTimetag_Data{
	my $timetag_data = shift;
	my $r_FIM01_J7_0 = shift;
	$timetag_data = uc(Conversion::toHexaString($timetag_data, 8));
	return -1 if(!defined($r_FIM01_J7_0));
	if($$r_FIM01_J7_0 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$STN, $$r_FIM01_J7_0\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $timetag_data_offset/4, ($timetag_length)/4) = $timetag_data;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_FIM01_J7_0 = "$time $length $msg_ID $msg_data";
		#print "$$r_FIM01_J7_0 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}
sub setTimetag_Effective{
	my $timetag_effective = shift;
	my $r_FIM01_J7_0 = shift;
	$timetag_effective = uc(Conversion::toHexaString($timetag_effective, 8));
	return -1 if(!defined($r_FIM01_J7_0));
	if($$r_FIM01_J7_0 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$sysTN, $$r_FIM01_J7_0\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s?//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $timetag_effective_offset/4, ($timetag_length)/4) = $timetag_effective;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_FIM01_J7_0 = "$time $length $msg_ID $msg_data";
		#print "$$r_FIM01_J7_0 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setSTN {
	my $r_FIM01_J7_0 = shift;
	my $STN = shift;
	# conversion du champs en string binaire
	my $STN_binary = sprintf("%0${STN_length}b", $STN);
	#print "$STN_binary\n";
	return -1 if(! defined($r_FIM01_J7_0));
	my $binary_msg = toBinaryDataMsg($r_FIM01_J7_0, $r_FIM01_J7_0->{'msg_data'});
	#print "$binary_msg\n";
	substr($binary_msg, $STN_offset, $STN_length, $STN_binary);
	#print "$binary_msg\n";
	my $hexa_msg = binaryToHexaDataMsg($r_FIM01_J7_0, \$binary_msg);
	#print "$hexa_msg\n";
	$hexa_msg =~ s/(\S{4})/$1 /g;
	$r_FIM01_J7_0->{'msg_data'} = $hexa_msg;
	#print "$hexa_msg\n";
	return $hexa_msg;
}

sub setLTN {
	my $r_FIM01_J7_0 = shift;
	my $LTN = shift;
	my @words;
	my @words_inv;
	# conversion du champs en string binaire
	my $LTN_binary = sprintf("%0${LTN_length}b", $LTN);
	#print "$LTN_binary\n";
	return -1 if(! defined($r_FIM01_J7_0));
	my $binary_msg = toBinaryDataMsg($r_FIM01_J7_0, $r_FIM01_J7_0->{'msg_data'});
	#print "$binary_msg\n";
	# inversion des mots de 16 bit
	while(my $word = substr($binary_msg,0, 16, "")){
		#print "$word\n";
		push @words, $word;		
	}
	#print "words @words\n";
	@words = reverse @words;
	#print "words@words\n";
	my $binary_msg_inverse = join("", @words);
	my $var = -($LTN_offset+ $LTN_length);
	my $var2 = length($binary_msg_inverse);
	print "$var2 $var $LTN_length\n";
	substr($binary_msg_inverse, -($LTN_offset+ $LTN_length), $LTN_length, $LTN_binary);
	# inversion des mots de 16 bit
	while(my $word = substr($binary_msg_inverse,0, 16, "")){
		#print "$word\n";
		push @words_inv, $word;		
	}
	#print "@words_inv\n";
	@words_inv = reverse @words_inv;
	#print "@words_inv\n";
	$binary_msg = join("", @words_inv);
	my $hexa_msg = binaryToHexaDataMsg($r_FIM01_J7_0, \$binary_msg);
	#print "$hexa_msg\n";
	$hexa_msg =~ s/(\S{4})/$1 /g;
	$r_FIM01_J7_0->{'msg_data'} = $hexa_msg;
	#print "$hexa_msg\n";
	return $hexa_msg;
}


sub addTime(){
	my $r_FIM01_J7_0 = shift;
	my $time = shift;
	$r_FIM01_J7_0->{time} =~ s/^(\d{2}:\d{2}:\d{2}\.\d{3})/$time/;
	#print "+time $$r_FIM01_J7_0\n";
}

if($test == 1){
	my $FIM01_J7_0;
	open Fout, ">test.xhd";
	for my $i (0..90){
		$FIM01_J7_0 = $FIM01_J7_0_ref;
		setLatitude(Conversion::latitude2BAM_32($i+0.5), \$FIM01_J7_0);
		setLongitude(Conversion::longitude2BAM_32($i+0.5), \$FIM01_J7_0);
		setCourse(Conversion::longitude2BAM_32($i+0.5), \$FIM01_J7_0);
		#print Fout "$FIM01_J7_0\n";		
	}
	for my $i (90..180){
		$FIM01_J7_0 = $FIM01_J7_0_ref;
		setLatitude(Conversion::latitude2BAM_32(90), \$FIM01_J7_0);
		setLongitude(Conversion::longitude2BAM_32($i+0.5), \$FIM01_J7_0);
		setCourse(Conversion::longitude2BAM_32($i+0.5), \$FIM01_J7_0);
		#print Fout "$FIM01_J7_0\n";		
	}
	for my $i (0..90){
		$FIM01_J7_0 = $FIM01_J7_0_ref;
		setLatitude(Conversion::latitude2BAM_32(-90+0.5), \$FIM01_J7_0);
		setLongitude(Conversion::longitude2BAM_32(-180+$i+0.5), \$FIM01_J7_0);
		setCourse(Conversion::longitude2BAM_32(-180+$i+0.5), \$FIM01_J7_0);
		#print Fout "$FIM01_J7_0\n";		
	}
	for my $i (90..180){
		$FIM01_J7_0 = $FIM01_J7_0_ref;
		setLatitude(Conversion::latitude2BAM_32(-90), \$FIM01_J7_0);
		setLongitude(Conversion::longitude2BAM_32(-180+$i+0.5), \$FIM01_J7_0);
		setCourse(Conversion::longitude2BAM_32(-180+$i+0.5), \$FIM01_J7_0);
		#print Fout "$FIM01_J7_0\n";		
	}
	close Fout;

	exit 0;
}

1