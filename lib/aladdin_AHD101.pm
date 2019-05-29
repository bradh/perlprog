package aladdin_AHD101;

my $test = 0;

my $AHD101_v2 = "00:00:00.000 00000061 00000065 0000 0000 0065 0200 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 FFFF FF01 FF01 FF01 FFFF 003F 64";
my $AHD101_v6 = "00:00:00.000 00000071 00000065 0000 0000 0065 0600 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 00FF FFFF 01FF 01FF 01FF FF00 3F64 0000 0000 0000 0000 00";
my $AHD101_ref;

my $timetag_msg_offset = 64;
my $timetag_data_offset = 152;
my $timetag_effective_offset = 184;
my $timetag_length = 32;

my $sysTN_offset = 128;
my $sysTN_length = 16;
my $LTCI_offset = 144;
my $LTCI_length = 8;
my $latitude_offset = 232;
my $latitude_length = 32;
my $longitude_offset = 264;
my $longitude_length = 32;
my $course_offset = 296;
my $course_length = 32;
my $speed_offset = 328;
my $speed_length = 16;
my $tq_offset = 344;
my $tq_length = 8;
my $platform_offset = 416;
my $platform_length = 8;
my $specific_type_offset = 432;
my $specific_type_length = 16;

sub new {
	$r_AHD101 = shift;
	$AHD101_ref = $$r_AHD101;
	bless \$AHD101_ref;
	return \$AHD101_ref;
}

sub format_AHD101{
	my $r_AHD101 = shift;
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/(\S{4})/$1 /g;
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
	}
}

sub get_AHD101{
	my $r_AHD101 = shift;
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;
		$msg_data =~ s/(\S{4})/$1 /g;
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		#print "$$r_AHD101\n";
		return $$r_AHD101;
	}
	else{
		return -1;
	}
}

sub setTimetag_Message{
	my $timetag_msg = shift;
	my $r_AHD101 = shift;
	$timetag_msg = uc(Conversion::toHexaString($timetag_msg, 8));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$timetag_msg, $$r_AHD101\n";
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
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		#print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setTimetag_Data{
	my $timetag_data = shift;
	my $r_AHD101 = shift;
	$timetag_data = uc(Conversion::toHexaString($timetag_data, 8));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$sysTN, $$r_AHD101\n";
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
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		#print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}
sub setTimetag_Effective{
	my $timetag_effective = shift;
	my $r_AHD101 = shift;
	$timetag_effective = uc(Conversion::toHexaString($timetag_effective, 8));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$sysTN, $$r_AHD101\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $timetag_effective_offset/4, ($timetag_length)/4) = $timetag_effective;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		#print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setSysTN {
	my $r_AHD101 = shift;
	my $sysTN = shift;
	$sysTN = uc(Conversion::toHexaString($sysTN, 4));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$sysTN, $$r_AHD101\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $sysTN_offset/4, ($sysTN_length)/4) = $sysTN;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		format_AHD101($r_AHD101);
		#print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setLTCI {
	my $LTCI = shift;
	my $r_AHD101 = shift;
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$LTCI, $$r_AHD101\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		#print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $LTCI_offset/4, ($LTCI_length)/4) = "80" if($LTCI == 1);
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setLatitude {
	my $latitude = shift;
	my $r_AHD101 = shift;
	$latitude = uc(Conversion::latitude2BAM_32($latitude));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		#print "$latitude, $$r_AHD101\n";
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		print "$time $length $msg_ID $msg_data\n";
		#print "$msg_data\n";
		substr($msg_data, $latitude_offset/4, ($latitude_length)/4) = $latitude;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		print "$$r_AHD101 after\n";
		return 0;		
	}
	else{
		return -1;
	}
}
sub setLongitude {
	my $longitude = shift;
	my $r_AHD101 = shift;
	$longitude = uc(Conversion::longitude2BAM_32($longitude));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		
		#print "$msg_data\n";
		substr($msg_data, $longitude_offset/4, $longitude_length/4) = $longitude;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		return 0;		
	}
	else{
		return -1;
	}
}
sub setCourse {
	my $course = shift;
	my $r_AHD101 = shift;
	$course = uc(Conversion::longitude2BAM_32($course));
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		
		#print "$msg_data\n";
		substr($msg_data, $course_offset/4, $course_length/4) = $course;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setSpeed {
	my $speed = shift;
	$speed = uc(Conversion::toHexaString($speed, 4));
	my $r_AHD101 = shift;
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		
		#print "$msg_data\n";
		substr($msg_data, $speed_offset/4, $speed_length/4) = $speed;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		return 0;		
	}
	else{
		return -1;
	}
}
sub setTQ {
	my $tq = shift;
	$tq = uc(Conversion::toHexaString($tq,2));
	my $r_AHD101 = shift;
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		
		#print "$msg_data\n";
		substr($msg_data, $tq_offset/4, $tq_length/4) = $tq;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		return 0;		
	}
	else{
		return -1;
	}
}

sub setPlatform {
	my $platform = shift;
	$platform = uc(Conversion::toHexaString($platform, 2));
	my $r_AHD101 = shift;
	return -1 if(!defined($r_AHD101));
	if($$r_AHD101 =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\w{8}) (\w{8}) (.*$)/){
		my $time = $1;
		my $length = $2;
		my $msg_ID = $3;
		my $msg_data = $4;

		# suppression des blanc
		$msg_data =~ s/\s//g;
		
		#print "$msg_data\n";
		substr($msg_data, $platform_offset/4, $platform_length/4) = $platform;
		#print "$time $length $msg_ID $msg_data\n";
		$$r_AHD101 = "$time $length $msg_ID $msg_data";
		return 0;		
	}
	else{
		return -1;
	}
}

sub addTime(){
	my $r_AHD101 = shift;
	my $time = shift;
	$$r_AHD101 =~ s/^(\d{2}:\d{2}:\d{2}\.\d{3})/$time/;
	#print "+time $$r_AHD101\n";
}

if($test == 1){
	my $AHD101;
	open Fout, ">test.xhd";
	for my $i (0..90){
		$AHD101 = $AHD101_ref;
		setLatitude(Conversion::latitude2BAM_32($i+0.5), \$AHD101);
		setLongitude(Conversion::longitude2BAM_32($i+0.5), \$AHD101);
		setCourse(Conversion::longitude2BAM_32($i+0.5), \$AHD101);
		#print Fout "$AHD101\n";		
	}
	for my $i (90..180){
		$AHD101 = $AHD101_ref;
		setLatitude(Conversion::latitude2BAM_32(90), \$AHD101);
		setLongitude(Conversion::longitude2BAM_32($i+0.5), \$AHD101);
		setCourse(Conversion::longitude2BAM_32($i+0.5), \$AHD101);
		#print Fout "$AHD101\n";		
	}
	for my $i (0..90){
		$AHD101 = $AHD101_ref;
		setLatitude(Conversion::latitude2BAM_32(-90+0.5), \$AHD101);
		setLongitude(Conversion::longitude2BAM_32(-180+$i+0.5), \$AHD101);
		setCourse(Conversion::longitude2BAM_32(-180+$i+0.5), \$AHD101);
		#print Fout "$AHD101\n";		
	}
	for my $i (90..180){
		$AHD101 = $AHD101_ref;
		setLatitude(Conversion::latitude2BAM_32(-90), \$AHD101);
		setLongitude(Conversion::longitude2BAM_32(-180+$i+0.5), \$AHD101);
		setCourse(Conversion::longitude2BAM_32(-180+$i+0.5), \$AHD101);
		#print Fout "$AHD101\n";		
	}
	close Fout;

	exit 0;
}

1