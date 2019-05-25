#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 04/05/2007
# Description :
# translate le temps d'un fichier TD

use Getopt::Std;

my @MOT;
my $Delta_Error = "00:00:02.000";

getopts("hf:");

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
	if( $heure > 23 ) {die "convChrono : chrono depasse 24 heures\n";}
	my $minute = formatHeure(int (($chrono - ($heure*3600))/60));
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
		
	}
	else { print "erreur entree $chiffre \n";}
	$seconde = "$seconde\.$millisec";
	return $seconde;
}








if ($opt_h) { 
  print "toChrono.pl -f fichier TD : A partir d'un nom de fichier, le script transforme l'heure HH:MM:SS.SSS en SS.SSS";
  exit(0);
}
if( ! $opt_h && $opt_f ) {
  my $fichierInput = "$opt_f"; 
  my $fichierOutput = "$opt_f.toChrono";
  my $fichierSave = "$opt_f.save";
  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
  open Fout2,">$fichierSave" or die "impossible d'ouvrir le fichier de sortie $fichierSave \n"; 
  print "to chrono $fichierInput, please wait...\n";	
	
  while(<Fin>){
    chomp;
    my $LIGNE = $_;
    chomp $LIGNE;
    print Fout2 "$LIGNE\n";
    (@MOT) = (split " ",$LIGNE);
    #print "$MOT[0]\n";
    if($MOT[0] =~ /(^\d{2}:\d{2}:\d{2}\.\d{3})/){
      my $Chrono = toChrono $1;
      $Chrono = formatSec($Chrono);
      print "$MOT[0] -> $Chrono\n" ;
      #$Chrono +=   $delta_time;
      #print "delta = $delta_time -> $Chrono\n";
      #my $Time = toTime $Chrono;
      #print "$Chrono -> $Time\n";
      printf Fout "$Chrono ";
      for (my $i = 1 ; $i < scalar @MOT; $i++){
	print  Fout "$MOT[$i] ";
      }
      print Fout "\n";
    }
    else{
     print Fout "$LIGNE\n";
   }
    
  }
  close Fin;
  close Fout;
  close Fout2;
  system ("mv $fichierOutput  $fichierInput" );
  exit 0;
}
