package LU2_field;

sub new {
 	my $name = shift;
	my $length = shift;
	my $value = shift;
	my $r_field = {
		"name" => $name,
		"length" => $length,
		
		"value" => $value,
 	};
 	#print "$name, $length,$value, \n";
	bless $r_field;
	return $r_field;
}
	
sub get_name {
	$r_field = shift;
	return $r_field->{name};
}
sub get_value {
	$r_field = shift;
	return $r_field->{value};
}
sub get_length {
	$r_field = shift;
	return $r_field->{length};
}
sub set_value() {
	$r_field = shift;
	my $value = shift;
	$r_field->{"value"} = $value;
}
sub get_binary_string{
	$r_field = shift;
	my $length = $r_field->{length};
	my $value = $r_field->{value};
	$binary_string =  sprintf("%0${length}B", $value);
	return $binary_string;
}

#my $field = new("word count", 24, 0);
#print $field->get_name()."\n";
#print $field->get_value()."\n";
#print $field->get_binary_string()."\n";


1 