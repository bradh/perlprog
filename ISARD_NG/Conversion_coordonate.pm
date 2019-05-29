package Conversion_coordonate;

#testPackage();


sub testPackage {
	my $resultTest = testGetCharValue();
	print "test getCharValue : $resultTest\n";
	$resultTest = testGetValueChar();
	print "test getValueChar : $resultTest\n";
	$resultTest = testTranslate2Long();
	print "test translate2Long : $resultTest\n";
	$resultTest = testTranslate2Lat();
	print "test translate2Lat : $resultTest\n";
	$resultTest = testTranslateLatLong2Geo();
}

sub translateLatLong2Geo{
	my $degreLat = shift;
	my $minLat = shift;
	my $degreLong = shift;
	my $minLong = shift;
	
	my $degreLong2 = ($degreLong + 180)%15;
	my $degreLong1 = int (($degreLong - $degreLong2 + 180)/15);
	print "degreLong1 : $degreLong1\n";
	print "degreLat2 : $degreLong2\n"; 
	my $char1 = getValueChar($degreLong1);
	my $char3 = getValueChar($degreLong2);
	
	my $degreLat2 = ($degreLat + 90)%15;
	my $degreLat1 = int (($degreLat - $degreLat2 + 90)/15);
	print "degreLat1 : $degreLat1\n";
	print "degreLat2 : $degreLat2\n"; 
	my $char2 = getValueChar($degreLat1);
	my $char4 = getValueChar($degreLat2);
	$char5 = sprintf("%02d", $minLong );
	$char6 = sprintf("%02d", $minLat);
	my $geo_ref = $char1.$char2.$char3.$char4.$char5.$char6;
	print "geo_ref = $geo_ref\n";
	return $geo_ref;
}

sub translate2Long {
	my $geo_reference = shift;
	my ($char1, $char2, $char3, $char4, $minLong, $minLat) = unpack("AAAAA2A2", $geo_reference);
	my $degreLong1 = getCharValue($char1); 
	my $degreLong2 = getCharValue($char3);
	my $degreLong = (15 * $degreLong1) - 180 + $degreLong2;
	print "Long = $degreLong°$minLong'\n";
	return ($degreLong, $minLong);
}

sub translate2Lat {
	my $geo_reference = shift;
	my ($char1, $char2, $char3, $char4, $minLong, $minLat) = unpack("AAAAA2A2", $geo_reference);
	my $degreLat1 = getCharValue($char2); 
	my $degreLat2 = getCharValue($char4);
	my $degreLat = (15 * $degreLat1) - 90 + $degreLat2;
	print "Lat = $degreLat°$minLat'\n";
	return ($degreLat, $minLat);
}

sub getCharValue {
	my $char = shift;
	my $value = ord($char);
	$value += -65;
	if ($value > 14){
		$value += -2;
	}
	else{
		if($value > 8){
			$value += -1;
		}	
	}
	print "$char -> $value\n";
	return $value;
}

sub getValueChar {
	my $value = shift;
	my $value_ref = $value;
	if ($value > 12){
		$value += +2;
	}
	else{
		if($value > 7){
			$value += 1;
		}	
	}
	#$value += 65;
	my $char = chr($value + 65);
	print "$value_ref -> $char\n";
	return $char;
}

sub testGetCharValue {
	my $testResult = "OK";
	foreach $i (65..90){
		my $char = chr($i);
		my $value = getCharValue($char);
		$testResult = "KO" if($char eq 'A' && $value != 0 );
		$testResult = "KO" if($char eq 'H' && $value != 7 );
		$testResult = "KO" if($char eq 'J' && $value != 8 );
		$testResult = "KO" if($char eq 'N' && $value != 12 );
		$testResult = "KO" if($char eq 'P' && $value != 13 );
		$testResult = "KO" if($char eq 'Z' && $value != 23 );
	}
	return $testResult;
}
sub testGetValueChar {
	my $testResult = "OK";
	foreach $i (0..23){
		my $char = getValueChar($i);
		$testResult = "KO" if($char ne 'A' && $i == 0 );
		$testResult = "KO" if($char ne 'H' && $i == 7 );
		$testResult = "KO" if($char ne 'J' && $i == 8 );
		$testResult = "KO" if($char ne 'N' && $i == 12 );
		$testResult = "KO" if($char ne 'P' && $i == 13 );
		$testResult = "KO" if($char ne 'Z' && $i == 23 );
	}
	return $testResult;
}
sub testTranslate2Long{
	my $testResult = "OK";
	my $geo_reference = "MKNF4951";
	my ($degreLong, $minLong) = translate2Long($geo_reference);
	$testResult = "KO" if($degreLong != -3);
	$testResult = "KO" if($minLong != 49);
	return $testResult;
}
sub testTranslate2Lat{
	my $testResult = "OK";
	my $geo_reference = "MKNF4951";
	my ($degreLat, $minLat) = translate2Lat($geo_reference);
	$testResult = "KO" if($degreLat != 50);
	$testResult = "KO" if($minLat != 51);
	return $testResult;
}
sub testTranslateLatLong2Geo {
	my $degreLat = 50;
	my $minLat = 3;
	my $degreLong = -3;
	my $minLong = 49;
	translateLatLong2Geo($degreLat, $minLat, $degreLong, $minLong);
	return;
}
1;