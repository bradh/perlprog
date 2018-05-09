#!/usr/bin/perl -w

package ConvLat;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&convLat_00051 &revConvLat_00051 &convLat_00013 &revConvLat_00013 &latSum);

if(0){

my $hemi;
my $deg;
my $min;
my $sec;


($hemi,$deg, $min, $sec) =  latSum(@ARGV);
print "hemisphere = $hemi\n";
print " degre = $deg\n";
print " minute = $min\n";
print " seconde = $sec\n";
exit 0;
}

# Convertit une lattitude en hemisphere/degré/minute/seconde en lat_0051 (int)
sub convLat_00051 {
	my $pas = 1048575;
	my $step = 1048577;
	my $hemisphere = shift;
 	my $degre = shift;
	$degre <= 90 or die "degre sup a 90 \n";
	my $minute = shift;
	$minute <= 60 or die "minute sup € 60 \n";
 	my $seconde = shift;
	my $lat_00051 = 0;
	my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 90 ) {
		print "valeur latitude sup € 90 \n";
		exit -1;
	}
	if($hemisphere eq "N"){
		$lat_00051 = int($degreTotal/90*$pas);
	}
	if($hemisphere eq "S"){
		$lat_00051 = $step+int((90-$degreTotal)/90*$pas);
	}
	print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	print "degr‰ = $lat_00051\n";
	return  $lat_00051;
}

# Convertit une lattitude en lat_0051 (int) en hemisphere/degré/minute/seconde
sub revConvLat_00051 {
        my $pas = 1048575;
        my $step = 1048577;
	my $hemi = "no statement";
	my $degre = 0;
	my $minute = 0;
	my $seconde = 0.0;
        my $lat_00051 = shift;
	my $no_statement = 1048576;

        ($lat_00051 < $pas+$step) or die "$lat_00051 hors format \n";

        if( $lat_00051 == $no_statement) {
                return "no statement";
        }
        else {
                $degreTotal = 90-($lat_00051-$step)*90/$pas;
        }
	if( $lat_00051 == $no_statement) {
		$hemi = "no statement";
	}
	if( $lat_00051 >= $step) {
		$hemi = "S";
	}
	else {
		$hemi = "N";
	}
        if( $lat_00051 >= $step) {
                my $degreTotal = 90-($lat_00051-$step)*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
                $seconde = ($minuteTotal - $minute)*60 ;
        }
        else {
                my $degreTotal = $lat_00051*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
		$seconde = ($minuteTotal - $minute)*60 ;
        }
	return ($hemi, $degre, $minute, $seconde);
}

# Convertit une latitude en degré

sub convLat2Degre {

  my $hemisphere = shift;
  my $degre = shift;
  $degre <= 90 or die "degre sup a 90 \n";
  my $minute = shift;
  $minute <= 60 or die "minute sup € 60 \n";
  my $seconde = shift;
  my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 90 ) {
		print "valeur latitude sup € 90 \n";
		exit -1;
	}
	if($hemisphere eq "S"){
		$degreTotal = -$degreTotal;
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $lat_00051\n";
	return  $degreTotal;
}

sub convDegre2Lat {
  
  my $degreTotal = shift;
  if ($degreTotal > 90 or $degreTotal< -90) {
    print "valeur lattitude hors range\n";
    exit -1;
  }
  if ($degreTotal<0) {
    $hemi = "S";
    $degreTotal = abs($degreTotal);
  }
  else {
    $hemi = "N";
  }
  my $degre =int($degreTotal);
  my $minute = int (($degreTotal-$degre)*60);
  my $seconde = ($degreTotal-$degre-$minute/60)*3600;
  return ($hemi, $degre, $minute, $seconde);
}

# Additionne deux lattitudes

sub latSum {
  my $latA = shift;
  my $latB = shift;

  my $degreA = convLat2Degre ((split("/", $latA)));
  my $degreB = convLat2Degre ((split("/", $latB)));

  return convDegre2Lat($degreA+$degreB);
}


 

sub convLat_00013 {
	my $pas = 4194303;
	my $step = 4194305;
	my $hemisphere = shift;
 	my $degre = shift;
	
	my $minute = shift;
 	my $seconde = shift;
	my $lat_00013 = 0;
	my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 90 ) {
		print "valeur latitude sup € 90 \n";
		exit -1;
	}
	if($hemisphere eq "N"){
		$lat_00013 = int($degreTotal/90*$pas);
	}
	if($hemisphere eq "S"){
		$lat_00013 = $step+int((90-$degreTotal)/90*$pas);
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $lat_00013\n";
	return  $lat_00013;
}

sub revConvLat_00013 {
        my $pas = 4194303;
        my $step = 4194305;
	my $hemi = "no statement";
	my $degre = 0;
	my $minute = 0;
	my $seconde = 0.0;
        my $lat_00013 = shift;
	my $no_statement = 4194304;
	my $toto = $pas+$step;
	#print "$toto\n";
        if($lat_00013 > ($pas+$step)) {
                print "$lat_00013 hors format \n";
                exit -1;
        }
        $degreTotal = 90-($lat_00013-$step)*90/$pas;
	if( $lat_00013 == $no_statement) {
		$hemi = "no statement";
	}
	if( $lat_00013 >= $step) {
		$hemi = "S";
	}
	else {
		$hemi = "N";
	}
        if( $lat_00013 >= $step) {
                my $degreTotal = 90-($lat_00013-$step)*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
                $seconde = ($minuteTotal - $minute)*60 ;
        }
        else {
                my $degreTotal = $lat_00013*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
		$seconde = ($minuteTotal - $minute)*60 ;
        }
	return ($hemi, $degre, $minute, $seconde);
}

# Convertit une lattitude en hemisphere/degré/minute/seconde en lat_0051 (int)
sub convLat_BAM {
	my $pas = 1048575;
	my $step = 1048577;
	my $hemisphere = shift;
 	my $degre = shift;
	$degre <= 90 or die "degre sup a 90 \n";
	my $minute = shift;
	$minute <= 60 or die "minute sup € 60 \n";
 	my $seconde = shift;
	my $lat_00051 = 0;
	my $degreTotal = $degre+$minute/60+$seconde/3600;
	if( $degreTotal > 90 ) {
		print "valeur latitude sup € 90 \n";
		exit -1;
	}
	if($hemisphere eq "N"){
		$lat_00051 = int($degreTotal/90*$pas);
	}
	if($hemisphere eq "S"){
		$lat_00051 = $step+int((90-$degreTotal)/90*$pas);
	}
	#print"hemis = $hemisphere\n";
	#print" degr‰ total = $degreTotal\n";
	#print "degr‰ = $lat_00051\n";
	return  $lat_00051;
}

# Convertit un lat_0051 (int) en une lattitude en hemisphere/degré/minute/seconde 
sub revConvLat_BAM {
        my $pas = 1048575;
        my $step = 1048577;
	my $hemi = "no statement";
	my $degre = 0;
	my $minute = 0;
	my $seconde = 0.0;
        my $lat_00051 = shift;
	my $no_statement = 1048576;

        ($lat_00051 < $pas+$step) or die "$lat_00051 hors format \n";

        if( $lat_00051 == $no_statement) {
                return "no statement";
        }
        else {
                $degreTotal = 90-($lat_00051-$step)*90/$pas;
        }
	if( $lat_00051 == $no_statement) {
		$hemi = "no statement";
	}
	if( $lat_00051 >= $step) {
		$hemi = "S";
	}
	else {
		$hemi = "N";
	}
        if( $lat_00051 >= $step) {
                my $degreTotal = 90-($lat_00051-$step)*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
                $seconde = ($minuteTotal - $minute)*60 ;
        }
        else {
                my $degreTotal = $lat_00051*90/$pas;
		$degre = int($degreTotal);
		my $minuteTotal = ($degreTotal - int($degreTotal))*60;
		$minute = int( $minuteTotal);
		$seconde = ($minuteTotal - $minute)*60 ;
        }
	return ($hemi, $degre, $minute, $seconde);
}
1;
