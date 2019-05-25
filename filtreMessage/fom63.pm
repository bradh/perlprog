package fom63;

use decodeHexaString;
my $debug =0;

sub new {
	my $messageHexa = shift;
	my (@validityInterpret) = (    "Time difference is not valid",
	                               "Time difference is valid");

    my $validityMapping = {   "firstWord" => 0,
                                    "lastWord" => 0,
                                    "firstBit" =>  0,
                                    "lastBit" => 0};

    my (@errorCodeInterpret) = (   "No Statement",
                                   "MTOD source invalid",
                                   "UTC source invalid",
                                   "Reserved",
                                   "Reserved",
                                   "Reserved",
                                   "Reserved",
                                   "Reserved") ;

    my $errorCodeMapping = {   "firstWord" => 0,
                                      "lastWord" => 0,
                                      "firstBit" =>  1,
                                      "lastBit" => 4};

    my $MTOD_UTC_DeltaTime_MSBMapping = {   "firstWord" => 1,
                                      "lastWord" => 1,
                                      "firstBit" =>  0,
                                      "lastBit" => 15};
    my $MTOD_UTC_DeltaTime_LSBMapping = {   "firstWord" => 2,
                                      "lastWord" => 2,
                                      "firstBit" =>  0,
                                      "lastBit" => 15};

    my $validity = @validityInterpret[decodeHexaString::new(\$messageHexa, $validityMapping)];
    my $errorCode = @errorCodeInterpret[decodeHexaString::new(\$messageHexa, $errorCodeMapping)];
    my $MTOD_UTC_DeltaTime_MSB = decodeHexaString::getHexaString(\$messageHexa, $MTOD_UTC_DeltaTime_MSBMapping);
    my $MTOD_UTC_DeltaTime_LSB = decodeHexaString::getHexaString(\$messageHexa, $MTOD_UTC_DeltaTime_LSBMapping);

	my $r_fom63 = {
			"validity" => $validity,
			"errorCode" => $errorCode,
			"MTOD_UTC_DeltaTime" => $MTOD_UTC_DeltaTime_MSB.$MTOD_UTC_DeltaTime_LSB
		};
    if ($debug){
         my $validity = $r_fom63->{validity};
         print "validity = $validity\n";
         #exit 0;
    }


	bless $r_fom63;
	return $r_fom63;
}

1
	
	
