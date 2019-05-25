package Conversion;

#!/usr/bin/perl -w

# Affaire : SAMPT
# Tche : automatisation des tests
# Auteur : S. Mouchot
# Mis  jour : le 04/05/2007
# Description :
# translate le temps d'un fichier TD

# convertit une heure en chrono rrence log

my $debug = 0;
localtime2Time_tag_data();

sub localtime2Time_tag_data{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$sec += ($hour * 60 + $min) * 60;
	
	my $time_tag_data = 2**27 * $mday + $sec*1000;
	print "$mday : $time_tag_data\n";
	my $net_data = pack('N', $time_tag_data); 
	print  unpack('B32', $net_data)."\n";	
	return $time_tag_data;
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
sub toTime {
	#shift;
	my $chrono = shift;
	my  $heure = formatHeure(int $chrono/3600);
	if( $heure > 23 ) {die "convChrono : chrono depasse 24 heures\n";}
	my $minute = formatHeure(int (($chrono - ($heure*3600))/60));
	my $seconde = formatSec($chrono - ($heure*3600) - ($minute *60));
	my $time = "$heure:$minute:$seconde";
	#<>;
	return $time;
}
sub formatHeure {
	#shift;
	my $chiffre = shift;
	if ( length "$chiffre" < 2) {
		$chiffre = "0$chiffre";
	}
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
	
	if($nber < 0|| $nber > 2**$digitNumber - 1 || $digitNumber > 16 || $digitNumber < 1) {
		return -1;
	}
	else {
		$digitNumber = $digitNumber * -1;
		# conversion sur 16 bits
		$nber = pack('n', $nber);
		$nber = unpack("B16", $nber);
		# conversion binaire sur n bits (n < 16)
		$nber = substr($nber, $digitNumber);
		return $nber;
	}
}

sub toHexaString {
    $debug =1;
    my $nber = shift;
    my $digitNber = shift;
    #print"$nber ";
    $nber = pack('N', $nber);
    $hexaNber = unpack('H*', $nber);
    $hexaNber = substr($hexaNber, $digitNber*(-1));
    #print "$hexaNber\n";
    #$digitNber = 2 if(not defined($digitNber));
    #print "digitNber : $digitNber\n" if($debug);
    #my $nberMax = 16**$digitNber-1;
    #return -1 if($nber > $nberMax || $nber < 0 );
    #$hexaNber = sprintf("%08x", $nber );
    #$hexaNber = substr($hexaNber, $digitNber*-1);
 	#if ($debug){
 	#	print "$nber -> ";
 	#	print "hexa number : $hexaNber\n";
 	#}
    return $hexaNber;
}
if($debug == 1){
	my $string = toHexaString(100,2);
	print "hexa : $string\n";
	exit 0;
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
	# s�paration par paire d'octet XXXX XXXX ...
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
	my $milli = int($micro/1000);
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
