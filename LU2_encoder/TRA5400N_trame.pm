package TRA5400N_trame;

# Decode TRA5400N header 


my $TRA_trame = "83 001A 00 0800 00 00 00 00 0000 0000 0000 0000 0000 00  08 01 24 00 00 00 27 60";

my $header = new($TRA_trame);

my $length = hex($header->{'length'}) ;
print "length = $length\n";



sub new{
	my $header = shift;
	# suppresion des fin de lignes
	chomp $header;
	# suppression des espaces
	$header =~ s/\s?//g;
	print "$header\n";	
	$header =~ /(\S{2})(\S{4})(\S{2})(\S{2})(\S{2})(\S{30})(\S*)/;
	my ($type_msg, $length, $cycle_num, $slot_num, $quality, $wrong_words, $data) = ($1, $2, $3, $4, $5, $6, $7);
	print "$type_msg, $length, $cycle_num, $slot_num, $quality, $wrong_words, $data\n";
	my $r_header = {
		"type_msg" => $type_msg,
		"length" => $length,
		"cycle_number" => $cycle_num,
		"slot_number" => $slot_num,
		"quality" => $quality,
		"wrong words" => $wrong_words,
		"data lu2" => $data
	};
	return $r_header;
}


1
