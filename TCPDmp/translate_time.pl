#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 04/05/2007
# Description :
# translate le temps d'un fichier TD

use lib qw(c:/perlprog/lib);
use Getopt::Std;
use Conversion;
use File::Copy "cp";

my @MOT;
my $Delta_Error = "00:00:02.000";
my (@ext)= ("xhd", "xdh", "fom","fim");

getopts("hf:s:");

# convertit une heure en chrono référence log

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

if ($opt_h) { 
  print "translate_time.pl -f fichier TD -s delta en sec : A partir d'un nom de fichier, le script décale les temps d'un delta en sec";
  exit(0);
}
if( ! $opt_h && $opt_f && $opt_s ) {
	foreach my $EXT (@ext){
  		my $fichierInput = "$opt_f.$EXT";
  		my $fichierOutput = "$opt_f.$EXT.translated";
  		my $delta_time = $opt_s;
  		exit if ($delta_time==0);
  		if(-f $fichierInput){
  			open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  			open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
  			print "Décale $fichierInput de $delta_time sec, please wait...\n";	
	
  			while(<Fin>){
    			chomp;
    			my $LIGNE = $_;
    			(@MOT) = (split " ",$LIGNE);
    			#print "$MOT[0]\n";
    			if($MOT[0] =~ /(^\d{2}):(\d{2}):(\d{2})\.(\d{3})/){
      				my $Chrono = Conversion::toChrono ($1, $2, $3, $4);
      				print "$MOT[0] -> $Chrono\n" ;
      				$Chrono +=   $delta_time;
      				print "delta = $delta_time -> $Chrono\n";
      				my $Time = Conversion::toTime $Chrono;
      				print "$Chrono -> $Time\n";
      				print Fout "$Time ";
      				for (my $i = 1 ; $i < scalar @MOT; $i++){
						print  Fout "$MOT[$i] ";
      				}
      				print Fout "\n";
    			}
    			else{
     				print Fout "$LIGNE\n";
   				}
   				#<>;
  			} 
  		close Fin;
  		close Fout;
  		cp("$fichierOutput", "$fichierInput" );
  		}
  	}
  exit;
}
