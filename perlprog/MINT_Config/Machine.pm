package Machine;

my $r_machine = new("SUN", "SOLARIS");
my $interface = "toto";
my $num = $r_machine->addInterface(\$interface);
print $num;
exit 0;


sub new {
	my $name = shift;
	my $type = shift;
	my $r_machine = {
		"name" => $name,
		"type" => $type,
		"Interfaces" => []
	};
	print " $r_machine->{\"name\"}\n";
	bless $r_machine;
	return $r_machine;
}

sub addInterface{
	my $r_machine = shift;
	my $r_interf = shift;
	my $r_array = $r_machine->{"Interfaces"};
	push @$r_array, $r_interf;
	return $#{$r_array};
}

1
