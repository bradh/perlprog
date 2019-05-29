package fim02_processing;

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);
use Conversion;

	my $word_number = 3;
	# fim02 est un tableau de mot composé d'un tableau de champs
	my $fim02_structure = [					
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
								],
								[
									{
											"field_name" => "set_index_number",
											"first_bit" => 0,
											"last_bit" => 7,
											"first_value" => 1,
											"last_value" => 255,
											"ns_value" => 0,
											"value" => 0
									}
								]
						];
	my @field_name_array;
	my @word;
	my $fim02;
	




sub fim02_create {
	#fim02->[0]->request_number = shift;
	#my $request_type = shift;
	#my $data_word_count = shift;
	#my $starting_data_word = shift;
	#my $set_index_number = shift;
	populate_field_name_array();
	foreach my $field_name (@field_name_array){
		my $field = get_field_by_name($field_name);
		$field->{'value'} = shift;
	}
	# on cree les mot
	$fim02 = '';
	foreach my $word ( @$fim02_structure ){
		my $word2 = "0"x16;
		print $word2."\n";
		foreach my $field (@$word){
			print $field->{"field_name"}."\n";
			my $digitNumber = $field->{"last_bit"} - $field->{"first_bit"} + 1;
			my $binary = Conversion::toBinaryString($field->{"value"}, $digitNumber);
			
			print $binary."\n";
			substr($word2, 15-$field->{"last_bit"}, $digitNumber, $binary);
			print $word2."\n";
			#exit 0;	
		}
		$word2 = oct ("0b$word2");
		print "décimal ".$word2 ."\n";
		$word2 = pack ('n', $word2);
		$fim02 = $fim02 . $word2;
		#print $fim02 . "\n";
		#$word2 = unpack("B*", $fim02);
		#print "toto ".$word2."\n";
	}
	#display_field_value_and_name();
	return $fim02;
}

sub display_field_value_and_name {
	foreach my $word ( @$fim02_structure ){
		foreach my $field (@$word){
			print  $field->{"field_name"}.$field->{"value"}."\n";
		}
	}
}

sub populate_field_name_array {
	@field_name_array = ();
	foreach my $word ( @$fim02_structure ){
		foreach my $field (@$word){
			push @field_name_array, $field->{"field_name"};
		}
	}
}

sub get_field_by_name {
	my $field_name = shift;
	foreach my $word ( @$fim02_structure ){
		foreach my $field (@$word){
			if($field->{"field_name"} eq $field_name){
				print "$field_name\n";
				return  $field
			}
		}
	}
}

1