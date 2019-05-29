package BoctetProcessing;

my $Offset_mot=0; # offset du mot I dans le tableau @MOT $MOT[11] est le 1er boctet pour les fim ; 8 pour les fom
my $r_array;

sub getValue {
	$r_array = shift;
	my $Bit_offset = shift; # compris entre 0 et 79
	my $Bit_number = shift; # compris entre 1 et 80
	$Offset_mot = shift;
	
	# Calcul des boctets utiles
	my $First_boctet = int($Bit_offset/16)+ $Offset_mot;
	my $Last_boctet = int(($Bit_offset+$Bit_number)/16)+ $Offset_mot;
	my $First_bit_of_first_boctet = $Bit_offset%16;
	my $Last_bit_of_last_boctet = ($Bit_offset+$Bit_number)%16;
	#print "$First_boctet $Last_boctet $First_bit_of_first_boctet $Last_bit_of_last_boctet \n";
	#my $toto = scalar @$r_mot;
	#print "$toto\n";
	my $String = getBoctetHexaString($Last_boctet);
	#print "$String\n";
	$String = Conversion::toHexaString(maskBoctetLastBit($String, $Last_bit_of_last_boctet));
	# Compilation des boctets
	if($Last_boctet>$First_boctet){
		for $I (($Last_boctet-1).. $First_boctet) {
		$String = $String . getBoctetHexaString($I);
		}
	}
	my $JValue = int(hex($String)/(2**$First_bit_of_first_boctet));
	#print "Jvalue : $JValue\n";
	return $JValue;
}

sub getBoctetHexaString {
	my $Boctet_number = shift;
	my $Boctet_index = getIndexforBoctet($Boctet_number);
	my $String = $r_array->[$Boctet_index];
	#print "BoctetHexaString : $String\n";
	return $String;
}

sub getIndexforBoctet {
	my $Boctet_number = shift;
	my $IndexforBoctet = $Offset_mot + $Boctet_number;
	#print "index : $IndexforBoctet\n";
	return $IndexforBoctet;
}

sub getIndexBoctetMotI {
	my $Position_Mot_I = 8;
	my $BIT_Position = shift;
	return 14-int($BIT_Position/16);
}
sub maskBoctetLastBit {
	my $Boctet = shift;
	my $Last_bit_position = shift;
	#print "$Boctet : $Last_bit_position\n";
	my $Mask = (2**($Last_bit_position))-1;
	my $Boctet_value = hex($Boctet) & $Mask;
	#print "$Mask : $Boctet_value \n";
	return $Boctet_value;
}

1
