package aladdin_AHD121;

my $test = 0;

my $AHD121_v2 = "00:00:00.000 0000001B 00000079 0000 0000 0079 0100 0000 0000 0000 0000 0001 0000 0000 00";
my $AHD121_v6 = "00:00:00.000 00000071 00000065 0000 0000 0065 0600 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 00FF FFFF 01FF 01FF 01FF FF00 3F64 0000 0000 0000 0000 00";
my $AHD121_ref;

my $timetag_msg_offset = 64;
my $timetag_data_offset = 152;
my $timetag_effective_offset = 184;
my $timetag_length = 32;

my $sysTN_offset = 128;
my $sysTN_length = 16;

sub new {
	$r_AHD121 = shift;
	$AHD121_ref = $$r_AHD121;
	bless \$AHD121_ref;
	return \$AHD121_ref;
}

sub format_AHD121{
	my $r_AHD121 = shift;
	if($$r_AHD121 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/(\S{4})/$1 /g;
		$$r_AHD121 = "$time $length $msg_ID $msg_data";
	}
}

sub get_AHD121{
	my $r_AHD121 = shift;
	if($$r_AHD121 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/(\S{4})/$1 /g;
		$$r_AHD121 = "$time $length $msg_ID $msg_data";
		 "$$r_AHD121\n";
		return $$r_AHD121;
	}
	else{
		return -1;
	}
}


sub setSysTN {
	my $r_AHD121 = shift;
	my $sysTN = shift;
	$sysTN = uc(Conversion::toHexaString($sysTN, 4));
	return -1 if(!defined($r_AHD121));
	if($$r_AHD121 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		 "$sysTN, $$r_AHD121\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		 "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $sysTN_offset/4, ($sysTN_length)/4) = $sysTN;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD121 = "$time $length $msg_ID $msg_data";
		format_AHD121($r_AHD121);
		 # print "$$r_AHD121 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}



sub addTime(){
	my $r_AHD121 = shift;
	my $time = shift;
	$$r_AHD121 =~ s/^(\d{2}:\d{2}:\d{2}\.\d{3})/$time/;
	#print "+time $$r_AHD121\n";
}

if($test == 1){
	my $AHD121;

}

1