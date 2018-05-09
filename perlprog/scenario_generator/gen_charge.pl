#!/usr/bin/perl
# gen_charge permet ...
# Mise a jour le 8 octobre 2002 par S. Mouchot

use Getopt::Std;

getopts("hd:i:f:n:o:r:t:z:");

my $BASE_DIR = "/data/users/loc1int/scenario_generator";
my $TEST_NAME = "L16_SURV_TNM_002";
my $BIBLIO_DIR = "Bibliotheque";
my $TEST_DIR = "$TEST_NAME";

# print $ENV{PWD};
if ($opt_h) { print "usage gen_charge.pl [-i nom_fichier_init] [-f nom_fichier_sortie] [-n nombre_de_pistes] [-r nombre_repetitions] [-t delta_t_en_s] [-o T0 en secondes][-z firsSysTN]\n";
print "gen_charge.pl genere dun fichier au format .xhd contenant nombre_de_piste espacee de delta_t en ms\n";
exit(0);}

# lecture du fichier d'init
if($opt_d){
  $TEST_NAME=$opt_d;
}

# lecture du fichier d'entree (patern)
my $fichierInput = "piste_unitaire.xhd";
if($opt_i) { $fichierInput = $opt_i;}

# fichier de sortie intermediaire
my $fichierTemp = "temp.xhd";
# fichier de sortie final
my $fichierOutput = "$TEST_NAME.xhd";
if($opt_f) {$fichierOutput = "$opt_f";}
print "$fichierOutput\n";

# nombre de pistes generee
my $nbrePistes = 600;
if($opt_n) { $nbrePistes= "$opt_n";}

# nombre de repetition des pistes (chaque 12 s)
my $nbreRepet = 1;
if($opt_r) { $nbreRepet = $opt_r;}
# delta t entre pistes
my $deltaTps = 0.1;
if($opt_t) { $deltaTps= $opt_t;}

# heure de demarrage en seconde
my $T0 = 90;
if($opt_o) { $T0= $opt_o;}

# premier SysTN
my $sysTnPiste=0;
if($opt_z) { $sysTnPiste = $opt_z-1;}

# delta lattitude en element binaire
my $deltaLat = 1000000;
my $lat0 = hex("22222221");

# delta longitude
my $deltaLong = 1000000;
my $long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

# lecture du fichier piste unitaire
open fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput\n";
my $pattern = <fin>;
#print "$pattern\n";
close fin;

open fout, ">$fichierTemp" or die "impossible d'ouvrir le fichier de sortie $fichierTemp";
@AHD101 = split " ",$pattern;


$long0 = hex ("$AHD101[42]$AHD101[43]$AHD101[44]$AHD101[45]");
$lat0 = hex("$AHD101[38]$AHD101[39]$AHD101[40]$AHD101[41]\n");

my $timePiste=$T0;

for ($j=0; $j < $nbrePistes; ) {
  #print "toto$j\n";
	$timePiste=$timePiste + $deltaTps;
	$AHD101[0]=toTime($timePiste);
	$sysTnPiste = $sysTnPiste+1;
	my $toto = toHexaString($sysTnPiste);
	#print "$toto\n";
	if( toHexaString($sysTnPiste) =~ /(..)(..)(..)$/){
		$AHD101[24]= $1;
		$AHD101[25]= $2;
		$AHD101[26]= $3;	
	}
# boucle d'incrementation de la longitude
	$longitude= $long0 + int($j/20)*$deltaLong;
	$latitude = $lat0 + $j%20*$deltaLat;
	$longHexa = toHexaString( $longitude);
	$latHexa = toHexaString($latitude);
	#print "$longHexa : $latHexa \n";
	if($longHexa =~ /(..)(..)(..)(..)$/) {
		$AHD101[42] = $1;
		$AHD101[43] = $2;
		$AHD101[44] = $3;
		$AHD101[45] = $4;
	}
	if($latHexa =~ /(..)(..)(..)(..)$/) {
		
		$AHD101[38] = $1;
		$AHD101[39] = $2;
		$AHD101[40] = $3;
		$AHD101[41] = $4;
	}
	$message =  join " ",@AHD101;
	print fout "$message\n";
	$j=$j+1;
}
close fout;

open(fin, "<$fichierTemp") or die "impossible d'ouvrir tempFile\n";
open(fout, ">>$fichierOutput") or die "impossible d'ouvrir $fichierOutput\n";

@newLigne;
my $j=0;
my $deltaRepet = 12;
while (<fin>) {

	     my @ligne = split " ", $_;
	     my $timePiste = toChrono($ligne[0]);
	     for (my $i = 0; $i< $nbreRepet; $i++) {
	      
	    #print "$timePiste\n";
	       $ligne[0] = toTime($timePiste);
	       $newLigne[$j] = join (" ", @ligne);
	    #print "$newLigne[$j]\n";
	       $timePiste += $deltaRepet;
	       $j++;
	       
	     }
  
}
foreach my $ligne (@newLigne) { 
  #
#my $temp =toChrono( (split( " ", $ligne,2))[0]); 
#print "$temp\n";
}
#
my @file = sort { toChrono((split( " ", $a,2))[0]) <=> toChrono((split " ", $b,2)[0]) } @newLigne;

foreach $ligne (@file) {
  print fout "$ligne\n";
}

close fin;
close fout;

system("rm $fichierTemp");
	       
exit(0);



# convertit un chrono en nombre d'heure de minute et de seconde

sub toTime {

	my $chrono = shift;
	$heure = formatHeure(int $chrono/3600);
	if( $heure > 23 ) {die "convChrono : chrono depasse 24 heures\n";}
	$minute = formatHeure(int (($chrono - ($heure*3600))/60));
	$seconde = formatSec($chrono - ($heure*3600) - ($minute *60));
	$time = "$heure:$minute:$seconde";
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
	$chiffre = "$chiffre.000" unless $chiffre =~ /\./;
	$chiffre = "$chiffrre000" unless $chiffre =~ /\.\d+/;
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

# convertit une heure en chrono reference log

sub toChrono {
	@time = split ":", shift;
	$heure = shift @time;
 	$minute = shift @time;
	$seconde = shift @time;

	$chrono = $heure*3600 + $minute*60 + $seconde;
	return $chrono;
}

# test si le chrono est compris entre chronoDebut et chronoFin

sub isInTime {

	$chronox = shift;
	#print "chrono: $chronox \n";
	#print "fin   : $chronoFin \n";
	#print "debut : $chronoDebut) \n";
	if ($chronox < $chronoFin && $chronox > $chronoDebut) { return "oui";}
	else { return "non";}
}
sub toHexaString {

	my $chiffre= shift;
	my $hexString="";
	for ($i=8; $i>0; )  {
		$i--;
		$num = int ($chiffre/16**$i);
		$hexString = $hexString.(0..9,'A'..'F')[$num & 15];
		$chiffre = $chiffre-$num*16**$i;
	}
	return $hexString;
}	
