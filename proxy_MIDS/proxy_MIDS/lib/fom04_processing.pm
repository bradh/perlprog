package fom04_processing;

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);
use Conversion;

	my $word_number = 2;
	# fim02 est un tableau de mot composé d'un tableau de champs
	my $fom04_structure = [					
								[
									{
											"field_name" => "request_number",
											"first_bit" => 9,
											"last_bit" => 13,
											"first_value" => 0,
											"last_value" => 31,
											"ns_value" => -1,
											"value" => 0
									},
									{
											"field_name" => "request_type",
											"first_bit" => 6,
											"last_bit" => 8,
											"first_value" => 0,
											"last_value" => 7,
											"ns_value" => -1,
											"value_interprétation" => [
												"Current Initialization Data Request",
												"Status Data Request",
												"Maintenance Parameters Data Request",
												"Initialization Data Set Request",
												"Memory Inspect",
												"Start-Up BIT Capture File Request",
												"Manually Initiated BIT Capture File Request",
												"Operational BIT Capture File Request"
											],
											"value" => 0
									},
									{
											"field_name" => "status",
											"first_bit" => 5,
											"last_bit" => 5,
											"first_value" => 0,
											"last_value" => 7,
											"ns_value" => -1,
											"value_interprétation" => [
												"Invalid_request",
												"Valid_requestt"
											],
											"value" => 0
									},
									{
											"field_name" => "data_word_count",
											"first_bit" => 0,
											"last_bit" => 4,
											"first_value" => 1,
											"last_value" => 30,
											"ns_value" => -1,
											"value" => 0
									}
								],
								[
									{
											"field_name" => "starting_data_word",
											"first_bit" => 0,
											"last_bit" => 12,
											"first_value" => 1,
											"last_value" => 8191,
											"ns_value" => -1,
											"value" => 0
									}
								]
						];
	my @field_name_array;
	my @word;
	my $fom04;
	my $binary_fom04;
	my $hexa_fom04;

sub test {
	
	init(10, 1, 1, 2, 151);
	print_binary();
	print_hexa();
	create($fom04);
	print_binary();
	print_hexa();
	exit 0;
}

sub create {
	$fom04 = shift;
	init (				decode_field_value("request_number"),
					decode_field_value("request_type"),
					decode_field_value("status"),
					decode_field_value("data_word_count"),
					decode_field_value("starting_data_word")
				);
}

sub print_binary {
	$binary_fom04 = unpack('B*', $fom04);
	print "binary fom04 : $binary_fom04 \n";
	return $binary_fom04;
}

sub print_hexa {
	$hexa_fom04 = unpack('H*', $fom04);
	print "hexa fom04   : $hexa_fom04 \n";
	return $hexa_fom04;
}

sub encode(){
	# on cree les mot
	$fom04 = '';
	my $debug = 1;
	foreach my $word (@$fom04_structure){
		my $word2 = "0"x16;
		#print $word2."\n" if($debug);
		foreach my $field (@$word){
			print $field->{"field_name"}."\n" if($debug);
			my $digitNumber = $field->{"last_bit"} - $field->{"first_bit"} + 1;
			my $binary_value = Conversion::toBinaryString($field->{"value"}, $digitNumber);			
			print "binary value : " . $binary_value . "\n" if($debug);
			substr($word2, 15-$field->{"last_bit"}, $digitNumber, $binary_value);
			print "binary word : " . $word2 . "\n" if($debug);
		}
		#$word2 = oct ("0b$word2");
		#print "decimal ".$word2 ."\n"if($debug);
		$word2 = pack ('B*', $word2);
		$fom04 = $fom04 . $word2;
	}
	#display_field_value_and_name();
	foreach my $i (1..get_field_value("data_word_count")){
		$fom04 = $fom04 . pack('n', 0);
	}
	return $fom04;
}	

sub init {
	my $debug = 1;
	populate_field_name_array();
	foreach my $field_name (@field_name_array){
		print "field name = $field_name\n" if($debug);
		my $field = get_field_by_name($field_name);
		my $value = $field->{'value'} = shift;
		print "field value = $value\n" if($debug);
	}
	encode();
	return $fom04;
}

sub display_field_value_and_name {
	foreach my $word ( @$fom04_structure ){
		foreach my $field (@$word){
			print  $field->{"field_name"}.$field->{"value"}."\n";
		}
	}
}

sub populate_field_name_array {
	my $debug = 0;
	@field_name_array = ();
	foreach my $word ( @$fom04_structure ){
		foreach my $field (@$word){
			my $name = $field->{"field_name"};
			print "name = $name\n" if($debug);
			push @field_name_array, $field->{"field_name"};
		}
	}
}

sub get_field_value {
	my $field_name = shift;
	my $debug = 1;
	foreach my $word ( @$fom04_structure ){
		foreach my $field (@$word){
			if($field->{"field_name"} eq $field_name){
				my $value =  $field->{"value"};
				print "get_field_value : $field_name = $value\n" if($debug);
				return  $value;
			}
		}
	}
}

sub set_field_value {
	my $field_name = shift;
	my $field_value = shift;
	foreach my $word ( @$fom04_structure ){
		foreach my $field (@$word){
			if($field->{"field_name"} eq "$field_name"){
				$field->{"value"} = $field_value;
				return  $field->{"value"};
			}
		}
	}
}

sub decode_field_value {
	my $debug = 1;
	my $field_name = shift;
	my $taille_array = scalar(@$fom04_structure);
	print "taille array = $taille_array \n$field_name\n" if($debug);
	foreach my $i ( 0..scalar(@$fom04_structure)-1 ){
		print "i = $i\n" if($debug);
		foreach my $field (@{$fom04_structure->[$i]}){
			my $name =  $field->{"field_name"};
			print "$name" if($debug);
			if($field->{"field_name"} eq "$field_name"){
				my $word_number = $i;
				my $first_bit = $field->{'first_bit'};
				my $last_bit  = $field->{'last_bit'};
				my $binary_fom04 = unpack('B*', $fom04);
				print "binary_fom04 = $binary_fom04\n" if($debug);
				my $field_value = substr($binary_fom04, 15-$last_bit+16*$word_number, $last_bit - $first_bit + 1);
				print "binary_value = $field_value\n" if($debug);
				$field_value = oct("0b$field_value");
				print "decimal value = $field_value\n" if($debug);
				return $field_value;
			}
		}
	}	
}

sub encode_field_value {
	my $field_name = shift;
	my $field_value = shift;
	foreach my $i ( 0..$#$fom04_structure ){
		foreach my $field ($fom04_structure->[$i]){
			if($field->{"field_name"} eq "$field_name"){
				my $word_number = $i;
				my $first_bit = $field->{'first_bit'};
				my $last_bit  = $field->{'last_bit'};
				my $digitNumber = $field->{"last_bit"} - $field->{"first_bit"} + 1;
				my $binary_field = Conversion::toBinaryString($field->{"value"}, $digitNumber);
				$binary_fom04 = substr($binary_fom04, 15-$field->{"last_bit"}+16*$word_number, $digitNumber, $binary_field);
			}
		}
	}
	return 0;
}

sub get_field_by_name {
	my $field_name = shift;
	foreach my $word ( @$fom04_structure ){
		foreach my $field (@$word){
			if($field->{"field_name"} eq $field_name){
				print "$field_name\n";
				return  $field;
			}
		}
	}
}

1
