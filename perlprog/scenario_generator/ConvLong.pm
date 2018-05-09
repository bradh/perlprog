#!/usr/bin/perl -w

package ConvLong;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&convLong_00051 &revConvLong_00051 &convLong_00013 &revConvLong_00013 &longSum);

if(0){
my $hemi;
my $deg;
my $min;
my $sec;

my $long =  convLong_00013(@ARGV);
#print "degre = $long\n";
($hemi,$deg, $min, $sec) =  revConvLong_00013($long);
#print "hemisphere = $hemi\n";
#print " degre = $deg\n";
#print " minute = $min\n";
#print " seconde = $sec\n";
exit 0;
}

sub convLong_00051 {
	my $pas = 2097151;
	my $step = 2097153;
	my $hemisphere = shift;
 	my $degre = shift;
	my $minute = shift;
 	my $seconde = shift;
	my $long_00051 = 0;
	my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 180 ) {
		print "valeur longitude sup € 180 \n";
		exit -1;
	}
	if($hemisphere eq "E"){
		$long_00051 = int($degreTotal/180*$pas);
	}
	if($hemisphere eq "W"){
		$long_00051 = $step+int((180-$degreTotal)/180*$pas);
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $long_00051\n";
	return  $long_00051;
}

sub revConvLong_00051 {
        my $pas = 2097151;
        my $step = 2097153;
	my $hemi = "no statement";
	my $degre = 0;
	my $minute = 0;
	my $seconde = 0.0;
        my $long_00051 = shift;
	my $no_statement = 262144;
        if( $long_00051 > $pas+$step) {
                print "$long_00051 hors format \n";
                exit -1;
        }
        if( $long_00051 == $no_statement) {
                return "no statement";
        }
        else {
                $degreTotal = 180-($long_00051-$step)*180/$pas;
        }
	if( $long_00051 == $no_statement) {
		$hemi = "no statement";
	}
	if( $long_00051 >= $step) {
		$hemi = "W";
	}
	else {
		$hemi = "E";
	}
        if( $long_00051 >= $step) {
                my $degreTotal = 180-($long_00051-$step)*180/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
                $seconde = ($minuteTotal - $minute)*60 ;
        }
        else {
                my $degreTotal = $long_00051*180/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
		$seconde = ($minuteTotal - $minute)*60 ;
        }
	return ($hemi, $degre, $minute, $seconde);
}

# Convertit une longitude en degré

sub convLong2Degre {

  my $hemisphere = shift;
  my $degre = shift;
  $degre <= 180 or die "degre sup a 180 \n";
  my $minute = shift;
  $minute <= 60 or die "minute sup € 60 \n";
  my $seconde = shift;
  my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 180 ) {
		print "valeur longitude sup € 180 \n";
		exit -1;
	}
	if($hemisphere eq "W"){
		$degreTotal = -$degreTotal;
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $lat_00051\n";
	return  $degreTotal;
}

sub convDegre2Long {
  
  my $degreTotal = shift;
  if ($degreTotal > 180 or $degreTotal< -180) {
    print "valeur longitude hors range\n";
    exit -1;
  }
  if ($degreTotal<0) {
    $hemi = "W";
    $degreTotal = abs($degreTotal);
  }
  else {
    $hemi = "E";
  }
  my $degre =int($degreTotal);
  my $minute = int (($degreTotal-$degre)*60);
  my $seconde = ($degreTotal-$degre-$minute/60)*3600;
  return ($hemi, $degre, $minute, $seconde);
}

# Additionne deux longitudes

sub longSum {
  my $longA = shift;
  my $longB = shift;

  my $degreA = convLong2Degre ((split("/", $longA)));
  my $degreB = convLong2Degre ((split("/", $longB)));

  return convDegre2Long($degreA+$degreB);
}


sub convLong_00013 {
	my $pas = 1048575;
	my $step = 1048577;
	my $hemisphere = shift;
 	my $degre = shift;
	my $minute = shift;
 	my $seconde = shift;
	my $long_00013 = 0;
	my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 180 ) {
		print "valeur longitude sup € 180 \n";
		exit -1;
	}
	if($hemisphere eq "E"){
		$long_00013 = int($degreTotal/180*$pas);
	}
	if($hemisphere eq "W"){
		$long_00013 = $step+int((180-$degreTotal)/180*$pas);
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $long_00013\n";
	return  $long_00013;
}

sub revConvLong_00013 {
        my $pas = 1048575;
        my $step = 1048577;
	my $hemi = "no statement";
	my $degre = 0;
	my $minute = 0;
	my $seconde = 0.0;
        my $long_00013 = shift;
	my $no_statement = 1048576;
	my $toto = $pas+$step;
	# print "$toto\n";
        if($long_00013 > ($pas+$step)) {
                print "$long_00013 hors format \n";
                exit -1;
        }
        $degreTotal = 180-($long_00013-$step)*180/$pas;
	if( $long_00013 == $no_statement) {
		$hemi = "no statement";
	}
	if( $long_00013 >= $step) {
		$hemi = "W";
	}
	else {
		$hemi = "E";
	}
        if( $long_00013 >= $step) {
                my $degreTotal = 180-($long_00013-$step)*180/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
                $seconde = ($minuteTotal - $minute)*60 ;
        }
        else {
                my $degreTotal = $long_00013*180/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
		$seconde = ($minuteTotal - $minute)*60 ;
        }
	return ($hemi, $degre, $minute, $seconde);
}
1;
