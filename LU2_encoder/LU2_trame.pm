package LU2_trame;

use LU2_X_Message;

sub new {
	my $hexa_trame = '0' x 384;
	$r_trame = {
		'hexa_trame' => $hexa_trame
	};
	bless $r_trame;
	return $r_trame;
}

sub get_hexa_trame{
	my $r_trame = shift;
	return $r_trame->{hexa_trame};
}

sub add_message{
	my $r_trame = shift;
	my $message_number = shift;
	print "Type de message : ";
	my $message_type = <>;
	my $message = LU2_X_Message::new($message_type);
	$message->initialize();
	$hexa_string = $message->get_hexa_string();
	my $message_position = ($message_number-1)*16; 
	substr($r_trame->{hexa_trame}, $message_position, 16, $hexa_string);
	return $r_trame->{hexa_trame};
}

sub format {
	my $r_trame = shift;
	my $string = $r_trame->{hexa_trame};
	$string =~ s/(\S{4})/$1 /g;
	return $string;
}

1