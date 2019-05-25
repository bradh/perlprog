#!/usr/bin/perl

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 23/05/2006
# Description :
# le script extrait du fichier .xhd d'entree dans un fichier texte $RESULT_FILE
# l'heure le tag du champ la valeur du champ le SysTN et pour

use Getopt::Std;

getopts("hf:");

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

if ($opt_h) { 
  print "extract_by_TN_from_xhd.pl -f nom_fichier : extrait les messages AHD10x ";
  exit(0);
}
if( ! $opt_h && $opt_f) {
	print "Extract AHD by TN, please wait...\n";
	open Fin, "<$opt_f" or die "Impossible ouvrir $opt_f\n";
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;
		my $AHD_id;
		#print "$MOT[14]\n";
		# récupération de l'ADH id
		if($MOT[2] =~ /......(..)/){
			$AHD_id = hex($1);
			print "$AHD_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($AHD_id == 101 || $AHD_id == 102 || $AHD_id == 104 || $AHD_id == 106 || $AHD_id == 107 || $AHD_id == 109 ||$AHD_id == 117 ){
				my $TN_value = hex($MOT[11]);
				my $fichierOutput = "AHD$AHD_id-$TN_value.xhd";
				open Fout, ">>$fichierOutput" or open ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
				print Fout "$LIGNE\n";
				close Fout;
			}
			

		}
	}
	close Fin;
	print "That's all folk !\n";
}
exit 0;
