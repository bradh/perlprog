#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 14/05/2007
# Description :
# A partir du fichier log de la slp avec les traces MICA en detailed debug
# cree les fichier .fim .fom 
# rajoute dans ce dernier le desactivation du control de flux

use Getopt::Std;

my @MOT;
my $Delta_Error = "00:00:02.000";
my $fichier_Log = "slp.log";
my $Stop_Msg="00:00:25.000 00000005 FE000005 00";
my $FOM12_AA_Msg="00:00:30.000 00000030 0400000C 0002 001E 0006 001E 0007 001E 0009 001E 000A 001E 000C 001E 000D 001E 001D 001E 0001 001E 0005 001E 001E 000E";
my $FOM12_AT_Msg="00:00:30.000 00000030 0400000C 0002 001E 0006 001E 009E 001E 0101 001E 0102 001E 0104 001E 0109 001E 010A 001E 010C 001E 0005 001E 001E 000E";

getopts("ht:c:");

if ($opt_h) { 
  print "create_fxm_file_from_log.pl -c test_env -t nom_test :  A partir du fichier log de la slp avec les traces MICA en detailed debug";
  exit(-1);
}
if( ! $opt_h && $opt_t&& $opt_c) {
	my $Test_Name = $opt_t;
	my $Test_Name_Lc = lc $Test_Name;
	system ("log2fxm.sun $fichier_Log -fim 1 > ${Test_Name_Lc}.fim");
	system ("log2fxm.sun $fichier_Log -fom 1 > ${Test_Name_Lc}.fom");

  	my $fichierInput = "${Test_Name_Lc}.fom";
  	my $fichierOutputBak = "${Test_Name_Lc}.fom.bak";
	my $fichierTemp = "Temp.fom";
  	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  	open Fout, ">$fichierOutputBak" or die "impossible d'ouvrir le fichier de sortie $fichierOutputBak \n";
	open Fout2, ">$fichierTemp" or die "impossible d'ouvrir le fichier de sortie Temp.fom \n";

  	print "Add fom12, please wait...\n";	
	print Fout2 "$Stop_Msg\n";
	if ($opt_c == 7) {print Fout2 "$FOM12_AT_Msg\n";}
	if ($opt_c ==1 || $opt_c == 4) {print Fout2 "$FOM12_AA_Msg\n";}
  	while(<Fin>){
    		print Fout2 ;
		print Fout;
    	}
	close Fin ;
	close Fout;
	close Fout2;
    	system("sort -u  $fichierTemp > $fichierInput");
	exit 0
}
  
