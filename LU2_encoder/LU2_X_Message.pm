package LU2_X_Message;


use LU2_field;


sub new{
	my $type = shift;
	chomp $type;
	my $r_message = {
		"type" => $type,
		"fields" => []
	};
	my $encode_file = "encodage_message_${type}_LU2.csv";
	open Fin , "<$encode_file" or die "impossible ouvrir $encode_file\n";
	while(<Fin>){
		my $line = $_;
		print $line. "\n";
		#chomp $line;
		my (@line) = split(';', $line);
		print $#line. "\n";
		my $length = 0;
		my $name = "";
		my $previous_name = "";
		my $i = 0;
		foreach $name (@line){
			#print "name : $name previous $previous_name\n";
			if($name ne "" ){
				if($previous_name ne "" ||  $name eq "End"){
					push @{$r_message->{'fields'}} , LU2_field::new($previous_name, $length, $length) ;
					#print "previous_name : $previous_name : $length\n";
				}
				$previous_name = $name;
				$length = 1;
			}
			else {
				#print "$name $length \n";
				$length += 1;
			}	
		}
	}
	bless $r_message;
	return $r_message;
}

sub get_fields{
	my $r_message = shift;
	return $r_message->{fields};
}

sub get_type{
	my $r_message = shift;
	return $r_message->{type};
}

sub get_binary_string{
	my $r_message = shift;
	my $binary_string = "";
	foreach my $field (@{$r_message->{fields}}){
		$binary_string = $binary_string . $field->get_binary_string;
		my $name = $field->get_name;
		my $length = $field->get_length;
		#print "$name : $length : ";
		#print #"$binary_string \n";
	}
	return $binary_string;
}

sub get_hexa_string{
	my $r_message = shift;
	my $hexa_string = "";
	my $binary_string = $r_message->get_binary_string;
	my $l = 0;
	while($l < length($binary_string)){
		my $value = '0b' . substr($binary_string,$l, 4);
		#print "$value\n";
		$value = oct $value;
		#print "$value\n";
		$hexa_string .= sprintf('%2X', $value );
		$hexa_string =~ s/\s?//g;
#		print "$hexa_string\n";
		$l += 4;
	}
	
	return $hexa_string; 
}

sub initialize {
	my $r_message = shift;
	foreach my $field (@{$r_message->{fields}}){
		my $name = $field->get_name;
		print "Entrer la value du champs $name :\t";
		$value = <>;
		$field->set_value($value);
	}
	#print $r_message->get_binary_string;
	return $r_message->get_binary_string;	
}

print "Enter LU2 Message type : ";
my $msg_type =<>;

my $x1_i = LU2_X_Message::new($msg_type);
print $x1_i->get_type . "\n";

$x1_i->initialize;
my $hexa_string = $x1_i->get_hexa_string;
print "$hexa_string\n";
print length($hexa_string);
print "\n";

my $binary_string = $x1_i->get_binary_string;
print "$binary_string \n";
$length = length($binary_string) ;
print "$length\n";

1
