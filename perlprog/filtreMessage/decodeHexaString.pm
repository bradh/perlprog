 package decodeHexaString;
my $debug = 0;

sub new {
    my $r_hexaString = shift;
    my $hexaString = $$r_hexaString;
	my $r_mapping = shift;
    my $firstBit = $r_mapping->{firstBit};
    my $lastBit = $r_mapping->{lastBit};
    my $firstWord = $r_mapping->{firstWord};
    my $lastWord = $r_mapping->{lastWord};
    
    if($debug ) {
              print " $hexaString, $firstWord, $lastWord, $firstBit, $lastBit\n";
    }
    $hexaString = substr ($hexaString , length($hexaString)-4*($lastWord+1), 4*($lastWord+1-$firstWord));
    my $mask  = hex($hexaString);
    if($debug ) {
              print "$hexaString $mask\n";
    }
    $mask = int($mask/2**$firstBit);
    $mask = ($mask%(2**($lastBit-$firstBit+1)));
    if($debug ) {
              print "$hexaString $mask\n";
    }
	return $mask;
}

sub getHexaString {
     my $r_hexaString = shift;
    my $hexaString = $$r_hexaString;
	my $r_mapping = shift;
    my $firstWord = $r_mapping->{firstWord};
    my $lastWord = $r_mapping->{lastWord};
    
    $hexaString = substr ($hexaString , length($hexaString)-4*($lastWord+1), 4*($lastWord+1-$firstWord));
    print "$hexaString\n";
    return $hexaString;
}


1
