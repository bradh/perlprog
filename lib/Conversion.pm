package Conversion;

#!/usr/bin/perl -w

# Affaire : SAMPT
# Tache : automatisation des tests
# Auteur : S. Mouchot
# Mis a jour : le 04/05/2007
# Description :
# translate le temps d'un fichier TD

# convertit une heure en chrono reference log

my $debug = 0;

if($debug == 5){
	foreach my $latitude ( 180, -180, 90, -90, 45, -45, 45.5, -45.5, 0){
		latitude2BAM_32($latitude);
	}
	foreach my $longitude ( 180, -180, 90, -90, 45, -45, 45.5, -45.5, 0){
		longitude2BAM_32($longitude);
	}
	exit 0;
}

sub latitude2BAM_32 {
	my $latitude = shift;
	my $quadran = 0;
	my $BAM = 0;
	# si latitude hors range BAM = N/S value
	if($latitude > 90 || $latitude < -90){
		$BAM = 0x80000000;
	}
	else {
		 if($latitude < 0){
			$latitude = 180 + $latitude;
			$quadran = -1;  
		}
		foreach my $i (1..31){
			my $puissance = 2**$i;
			$diff = $latitude-180/$puissance;
			
			if ( $diff > 0){
				$BAM = $BAM + 2**(31-$i);
				$latitude = $diff;
			}
			my $hexa = toHexaString($BAM, 8);
			#print "$i: $puissance:$diff:$hexa :$latitude\n";
			#print "$latitude:$BAM\n";
			$i += 1;
		}
		$BAM = $BAM + 2**31 + 1 if($quadran < 0);		
	}

	my $HexaBAM = toHexaString($BAM, 8);
	print "$latitude: $BAM: $HexaBAM\n";
	return $HexaBAM; 
	
}

sub longitude2BAM_32 {
	
	my $longitude = shift;
	my $quadran = 0;
	my $BAM = 0;
	# si longitude hors range BAM = N/S value
	if($longitude > 180 || $longitude < -180){
		$BAM = 0x80000000;
	}
	else {
		if($longitude == 180 || $longitude == -180){
			$BAM = 0x80000001if($longitude == -180);
			$BAM = 0x7FFFFFFF if($longitude == 180);
			
		}
		else {
			 if($longitude < 0){
				$longitude = 180 + $longitude;
				$quadran = -1;  
			}
			foreach my $i (1..31){
				my $puissance = 2**$i;
				$diff = $longitude-180/$puissance;
				
				if ( $diff > 0){
					$BAM = $BAM + 2**(31-$i);
					$longitude = $diff;
				}
				my $hexa = toHexaString($BAM, 8);
				#print "$i: $puissance:$diff:$hexa :$longitude\n";
				#print "$longitude:$BAM\n";
				$i += 1;
			}
			$BAM = $BAM + 2**31 + 1 if($quadran < 0);		
		}	
	}


	my $HexaBAM = toHexaString($BAM, 8);
	print "$longitude: $BAM: $HexaBAM\n";
	return $HexaBAM;
}

sub toChrono {
	my $heure = shift;
 	my $minute = shift;
	my $seconde = shift;
	my $milliseconde = shift;
	print "heure : $heure $minute $seconde $milliseconde\n" if($debug == 1);
	$seconde = $seconde + ($milliseconde/1000);
	print "heure : $heure $minute $seconde $milliseconde\n" if($debug == 1);
	my $chrono = $heure*3600 + $minute*60 + $seconde;
	print "chrono : $chrono\n" if($debug == 1);
	#<>;
	return $chrono;
	
}

sub timeToChrono {
	my $time = shift;
 	my ($hour, $minute, $second) = split ":", $time;
 	print "hour : $hour $minute $second \n" if($debug == 1);
	($second, my $millisecond) = split '\.', $second;
	print "hour : $hour $minute $second $millisecond\n" if($debug == 1);
	$second = $second + ($millisecond/1000);
	print "hour : $hour $minute $second $millisecond\n" if($debug == 1);
	my $chrono = $hour*3600 + $minute*60 + $second;
	print "chrono : $chrono\n" if($debug == 1);
	#<>;
	return $chrono;
	
}

sub time2Chrono {
	my $time = shift;
 	my ($hour, $minute, $second) = split ":", $time;
 	print "hour : $hour $minute $second \n" if($debug == 1);
	($second, my $millisecond) = split '\.', $second;
	print "hour : $hour $minute $second $millisecond\n" if($debug == 1);
	$second = $second + ($millisecond/1000);
	print "hour : $hour $minute $second $millisecond\n" if($debug == 1);
	my $chrono = $hour*3600 + $minute*60 + $second;
	print "chrono : $chrono\n" if($debug == 1);
	#<>;
	return $chrono;
	
}

sub toTime {
	#shift;
	my $chrono = shift;
	my  $heure = formatHeure(int $chrono/3600);
	#print "format heure : $heure\n";
	if( $heure > 23 ) {die "convChrono : chrono depasse 24 heures\n";}
	my $minute = int(($chrono - ($heure*3600))/60);
	$minute = sprintf("%02d", $minute);
	my $seconde = ($chrono - ($heure*3600) - ($minute *60));
	my $milliseconde = int(($seconde-int($seconde))*1000);
	$milliseconde = sprintf("%03d", $milliseconde);
	$seconde = sprintf("%02d", $seconde);
	$milliseconde = substr($milliseconde,0,3);
	print "$heure:$minute:$seconde.$milliseconde\n";
	my $time = "$heure:$minute:$seconde.$milliseconde";
	#<>;
	return $time;
}
sub formatHeure {
	#shift;
	my $chiffre = shift;
	$chiffre = sprintf("%02d", $chiffre);
	return $chiffre;
}
sub formatSec {
	#shift;
	my $sec = shift;	
	$sec = "$sec.000" unless $sec =~ /\./;
	$sec = "${sec}000" unless $sec =~ /\.\d+/;
	if($sec =~ /^(\d*)\.(\d*)/) {
		$seconde = $1;
		$millisec = $2;
		if (length "$millisec" < 3 ) {
			$millisec = "$millisec"."000";
		}
		$millisec =~ /^(\d\d\d)/;
		$millisec = $1;
	}
	else { print "erreur entree $sec \n";}
	$seconde = "$seconde\.$millisec";
	return $seconde;
}

sub toBinaryString {
	my $nber = shift;
	my $digitNumber = shift;
	
	if($nber < 0 || $nber > 2**$digitNumber - 1 || $digitNumber > 16 || $digitNumber < 1) {
		return -1;
	}
	else {
		
		# conversion sur 16 bits
		$nber = pack('n', $nber);
		$nber = unpack("B16", $nber);
		# conversion binaire sur n bits (n < 16)
		$digitNumber = $digitNumber * -1;
		$nber = substr($nber, $digitNumber);
		return $nber;
	}
}

sub toHexaString {
    my $nber = shift;
    my $digitNber = shift;
    $digitNber = 2 if(not defined($digitNber));
    print "digitNber : $digitNber\n" if($debug);
    my $nberMax = 16**$digitNber-1;
    return -1 if($nber > $nberMax || $nber < 0 );
    $hexaNber = sprintf("%08x", $nber );
    $hexaNber = substr($hexaNber, $digitNber*-1);
 	if ($debug){
 		print "$nber -> ";
 		print "hexa number : $hexaNber\n";
 	}
    return $hexaNber;
}

# retourne une chaine octal de 4 caracteres
sub toOctalString {
    my@tab = (0..7);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "0000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%8;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/8);
	}
    }
    $string = substr("0000"."$string", -4, 4);
    #print "Octal : $string \n";
    return $string;
}


sub toBoctetArray{
	my $r_string = shift;
	my $r_array = shift;
	# suppresion des blancs
	$$r_string =~ s/\s//g;
	# separation par paire d'octet XXXX XXXX ...
	$$r_string =~ s/(....)/$1 /g;
	(@$r_array) = split(" ", $$r_string);
	return 0;
}

sub toRelative{
	my $secs = shift;
	my $msecs = shift;
	my $origin_seconds = shift;
	my $origin_micro = shift;
	#print "ori $origin_seconds: $origin_milli\n";
	if ($msecs < $origin_micro) {
		$msecs = 1000000 + $msecs - $origin_micro;
		$secs = $secs - $origin_seconds -1;
	}
	else {
		$msecs = $msecs - $origin_micro;
		$secs = $secs - $origin_seconds;
	}
	#print "del $secs, $msecs\n";
	return ($secs, $msecs);
}

sub micro2Milli{
	my $micro = shift;
	($micro < 1000000 && $micro >= 0)or die "micro2Milli micro exceed 1 million\n";
	my $milli = sprintf("%02d",int($micro/1000));
	return $milli;
}

sub port2hexaString{
	my $port = shift;
	my $string = sprintf("%04x", $port);
	return $string;
}

sub hexaString2addressIP {
	my $addressIP = shift;
	print "$addressIP\n";
	$addressIP =~ /(..)(..)(..)(..)/;
	my($d1,$d2,$d3,$d4) = (hex($1),hex($2),hex($3),hex($4));
	$addressIP = "$d1\.$d2\.$d3\.$d4";
	print "IP : $addressIP\n";
	return $addressIP;
}

sub addressIP2hexaString {
	print "addressIP2hexaString\n";
	my $addressIP = shift;
	print "$addressIP\n";
	my $string = "";
	my @digit = split('\.', $addressIP);
	if(scalar @digit == 4){
		foreach my $digit (@digit){
			$string = $string.sprintf("%02x", $digit);
		}
		print "address IP : $string\n" if($debug);
	}
	else{
		return "00000000";
	}

	return $string;
}

1
