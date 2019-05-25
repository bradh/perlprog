#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 26/05/2006
# Description :
# Crée des fichiers "fom_arrival_times_and_tns_<TN_number>.txt" à partir du fichier fom_arrival_times_and_tns.txt

use Getopt::Std;

my @MOT;
my $RESULTS_FILE = "fom_arrival_times_and_tns.txt";

getopts("hf:t:");

if ($opt_h) { 
  print "extract_by_TN.pl -t TN -f nom_fichier_entrée";
  exit(0);
}
if( ! $opt_h && $opt_f && $opt_t) {
	my $fichierInput = "$opt_f";
	my $TN = "$opt_t";
	my ($Racine, $Ext) = split /\./, $fichierInput;
	my $fichierOutput = "$Racine"."_$TN".".$Ext";
	# print "$fichierOutput\n";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	#print " Create $fichierOutput from $fichierInput, please wait...\n";
	while(<Fin>){
		my $Line = $_;
		(@MOT) = (split " ",$Line);
		if( $MOT[1] == $TN) {
			#print "$Line";
			print Fout "$Line";
		}		
	}
	#print "That's all folk !\n";
}
exit 0;
