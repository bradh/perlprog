package Octet_field;

sub new {
	my $name = shift;
	my $octet_number = shift;
	my $value = shift;
	my $r_octet_field =  {
		"name" => $name,
		"octet_number" => $octe_number,
		"value_array" => [],
		"value" => $value
	};
	bless $r_octet_field;
	return $r_octet_field;
}

sub set_value {
	my $r_octet_field = shift;
	$r_octet_field->{"value"} = shift;
}

sub get_value {
	my $r_octet_field = shift;
	return $r_octet_field->{"value"};
}

sub get_length {
	my $r_octet_field = shift;
	return $r_octet_field->{"octet_number"};
}

$field = new("sync1", 1, "H");
#print $field->get_value();



1