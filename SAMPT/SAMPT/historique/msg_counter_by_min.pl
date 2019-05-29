#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hf:l:s:");

if ($opt_h) { 
	print "$! [-f] nom_fichier [-l] label [-s] sublabel [-h] : count les messages d'un .jo \n";
}

if( ! $opt_h && $opt_f  && $opt_l && $opt_s ) {
	my $label = $opt_l;
	my $sublabel = $opt_s;
	my $output_file = "msg_count_J$label$sublabel.txt";
	my $Extension;
	my $Corps;
  	my $INPUT_FILE = $opt_f;
	$INPUT_FILE =~ /(.+)\.(.*)/;
	$Corps = $1;
	$Extension = $2;
  	open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
	open Fout, ">$output_file" or die "Impossible d'ouvrir $output_file";
	my $Heure_prev = 0;
	my $Minute_prev = 0;
	my $Chrono_prev = 0;
	my $msg_count = 0;
	my $pattern = "0F0C0600" if($sublabel == 6);
	$pattern = "0F0C0700" if($sublabel == 7);
	while(<Fin>){
		my $LINE = $_;
		if( $LINE =~ /^(\d\d):(\d\d):(\d\d).*$pattern/){
			#print $LINE;
			my $Heure = $1;
			my $Minute = $2;
			my $Chrono = $Heure*60 + $Minute;
			while( $Chrono_prev < $Chrono){
				print Fout "$Chrono_prev:$Heure:$Minute:$msg_count\n";
				$Chrono_prev += 1;
				$msg_count= 0;
			}
			$msg_count +=1;
		}
     }
	close Fin;
	close Fout;
}
exit 0;



