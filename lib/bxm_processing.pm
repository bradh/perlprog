package bxm_processing;

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);
use Conversion;

	my $word_number = 2;
	# fxm est un tableau de mot composé d'un tableau de champs
	my $bxm_structure = [					
								[
									{
											"field_name" => "last_field",
											"first_bit" => 15,
											"last_bit" => 15,
											"first_value" => 0,
											"last_value" => 1,
											"ns_value" => -1,
											"value" => 0
									},
									{
											"field_name" => "fxm_id",
											"first_bit" => 9,
											"last_bit" => 14,
											"first_value" => 0,
											"last_value" => 63,
											"ns_value" => -1,
											"value" => 0
									},
									{
											"field_name" => "fxm_length",
											"first_bit" => 0,
											"last_bit" => 8,
											"first_value" => 0,
											"last_value" => 511,
											"ns_value" => -1,
											"value" => 0
									}
								]
						];
	my @field_name_array;
	my @word;
	my $bxm;
	
#bxm_create(10, 1, 12, 13, 14);
#exit 0;

sub get_fxm_id {
	my $bim = shift;
	# conversion en chaine binaire 
	#print unpack("B*", $bim)."\n";
	$bim = unpack("B*", $bim);
	my $bxm_id = substr($bim, 15 - $bxm_structure->[0]->[1]->{last_bit}, $bxm_structure->[0]->[1]->{last_bit} - $bxm_structure->[0]->[1]->{first_bit} + 1);
	#print "bxm_id (bin) = $bxm_id\n";
	$bxm_id = oct("0b$bxm_id");
	print "bxm_id (dec) = $bxm_id\n";
	return $bxm_id;
}

sub get_fxm_length {
	my $bim = shift;
	# conversion en chaine binaire 
	#print unpack("B*", $bim)."\n";
	$bim = unpack("B*", $bim);
	my $bxm_length = substr($bim, 15 - $bxm_structure->[0]->[2]->{last_bit}, $bxm_structure->[0]->[2]->{last_bit} - $bxm_structure->[0]->[2]->{first_bit} + 1);
	#print "bxm_length (bin) = $bxm_length\n";
	$bxm_length = oct("0b$bxm_length");
	#print "bxm_length (dec) = $bxm_length\n";
	return $bxm_length;
}

sub bxm_create {
	my $fxm = shift;
	#fom02->[0]->request_number = shift;
	#my $request_type = shift;
	#my $data_word_count = shift;
	#my $starting_data_word = shift;
	#my $set_index_number = shift;
	populate_field_name_array();
	# init last_fxm
	$bxm_structure->[0]->[0]->{'value'} = 0;
	# init fxm_id
	$bxm_structure->[0]->[1]->{'value'} = shift;
	# init fxm_length
	$bxm_structure->[0]->[2]->{'value'} = length($fxm)/2;
	# on cree les mot
	$bxm = '';
	foreach my $word ( @$bxm_structure ){
		my $word2 = "0"x16;
		#print $word2."\n";
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
		$bxm = $bxm . $word2;
		#print $fom02 . "\n";
		#$word2 = unpack("B*", $fom02);
		#print "toto ".$word2."\n";
	}
	#display_field_value_and_name();
	$bxm = $bxm . $fxm;
	return $bxm;
}

sub display_field_value_and_name {
	foreach my $word ( @$fom02_structure ){
		foreach my $field (@$word){
			print  $field->{"field_name"}.$field->{"value"}."\n";
		}
	}
}

sub populate_field_name_array {
	@field_name_array = ();
	foreach my $word ( @$fom02_structure ){
		foreach my $field (@$word){
			push @field_name_array, $field->{"field_name"};
		}
	}
}

sub extract_fxm {
	my $bxm = shift;
	my $debug = 1;
	$bxm = unpack('H*', $bxm);
	print "extract_fxm : $bxm\n" if($debug);
	$bxm = substr($bxm, 4);
	print "extract_fxm : $bxm\n" if($debug);
	$bxm = pack('H*', $bxm);
	return $bxm;
}

sub get_field_by_name {
	my $field_name = shift;
	foreach my $word ( @$fom02_structure ){
		foreach my $field (@$word){
			if($field->{"field_name"} eq $field_name){
				print "$field_name\n";
				return  $field
			}
		}
	}
}

1
