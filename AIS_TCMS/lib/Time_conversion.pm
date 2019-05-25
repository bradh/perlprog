package Time_conversion;

#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 04/05/2007
# Description :
# translate le temps d'un fichier TD

use Getopt::Std;

getopts("hf:s:");
my $debug = 1;

# convertit une heure en chrono référence log

sub toChrono {
	my @time = split ":", shift;
	my $heure = shift @time;
 	my $minute = shift @time;
	my$seconde = shift @time;

	my $chrono = $heure*3600 + $minute*60 + $seconde;
	return $chrono;
}

sub toTime {
	my $chrono = shift;
	my  $heure = formatHeure(int $chrono/3600);
	print "heure = $heure\n";
	if( $heure > 23 ) {die "convChrono : chrono depasse 24 heures\n";}
	my $min = ($chrono - ($heure*3600))/60 if($debug == 1);
	print "min = $min\n" if($debug == 1);
	my $minute = formatHeure(int (($chrono - ($heure*3600))/60));
	my $sec = $chrono - ($heure*3600) - ($minute *60);
	print "seconde = $sec\n" if($debug == 1);
	my $seconde = formatSec($chrono - ($heure*3600) - ($minute *60));
	my $time = "$heure:$minute:$seconde";
	return $time;
}

sub formatHeure {
	my $chiffre = shift;
	if ( length "$chiffre" < 2) {
		$chiffre = "0$chiffre";
	}
	return $chiffre;
}
sub formatSec {
	my $chiffre = shift;
	if($chiffre < 0.001) {
		$seconde = "00.000";
	}	
	else {
		$chiffre = "$chiffre.000" unless $chiffre =~ /\./;
		$chiffre = "${chiffre}000" unless $chiffre =~ /\.\d+/;
		if($chiffre =~ /^(\d*)\.(\d*)/) {
			$seconde = $1;
			$millisec = $2;
			if (length "$millisec" < 3 ) {
				$millisec = "$millisec"."000";
			}
			$millisec =~ /^(\d\d\d)/;
			$millisec = $1;
			if (length "$seconde" <2 ) {
				$seconde = "00"."$seconde";
			}
			$seconde =~ /(\d\d)$/;
			$seconde = $1;
		}
		else { print "erreur entree $chiffre \n";}
		$seconde = "$seconde\.$millisec";
		return $seconde;
	}
}

sub toHexaString {
    my@tab = (0..9,A..F);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "00000000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%16;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/16);
	}
    }
    $string = substr("0000000000"."$string", -8, 8);
    #print "hexa : $string \n";
    return $string;
}
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

sub translate_time {
	my @MOT;
	my $Delta_Error = "00:00:02.000";
	my (@ext)= ("xhd", "xdh", "fom","fim");
	my $filename = shift;
	my $delta_time = shift;
	exit if ($delta_time==0);
		foreach my $EXT (@ext){
  			my $fichierInput = "$filename.$EXT";
  			my $fichierOutput = "$filename.$EXT.translated";		
  			#print "toto";
  			if(-f $fichierInput){
  				open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  				open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
  				print "Décale $fichierInput de $delta_time sec, please wait...\n";
  				while(<Fin>){
    				chomp;
    				my $LIGNE = $_;
    				(@MOT) = (split " ",$LIGNE);
    				print "$MOT[0]\n" if($debug == 1);
    				if($MOT[0] =~ /(^\d{2}:\d{2}:\d{2}\.\d{3})/){
      					my $Chrono = toChrono $1;
      					print "$MOT[0] -> $Chrono\n" if($debug == 1);
      					$Chrono +=   $delta_time;
      					print "delta = $delta_time -> $Chrono\n" if($debug == 1);
						next if($Chrono < 0);
      					my $Time = toTime $Chrono;
      					print "$Chrono -> $Time\n" if($debug == 1);
      					print Fout "$Time ";
      					for (my $i = 1 ; $i < scalar @MOT; $i++){
						print  Fout "$MOT[$i] ";
      					}
      					print  Fout "\n";
    				}
    				else{
     					print Fout "$LIGNE\n";
   					}
  				} 
  			close Fin;
  			close Fout;
  			system ("copy $fichierInput $fichierInput.bak");
  			system ("copy $fichierOutput  $fichierInput" );
  			system ("del $fichierOutput" );
  			}
		}
  	return 0;
}
1;
