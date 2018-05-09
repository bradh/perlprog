#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 23/05/2006
# Description :
# le script extrait du fichier .fim d'entree dans un fichier texte $RESULT_FILE
# contenant les infos suivantes dans les fichiers texte correspondants :
# exemple :
# pour les j3_0
# 00:24:51.993 PLAT_0003
# pour les j3_2
# 00:24:51.993 IFF_0033
# pour les j3_7
# 00:25:00.192 ID_0000
# La valeur de l'IFF est affichée en octal

use Getopt::Std;
use lib qw(c:/perlprog/lib);
use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use Conversion;
use BoctetProcessing;

my @MOT;
my $RESULTS_FILE = "fim_arrival_times_and_tns.txt";
 my $Old_word = "0000";
my $SuppDoublon = 0;

getopts("hf:o:");

BoctetProcessing::setOffsetMotI(11); # offset du mot I dans le tableau @MOT $MOT[11] est le 1er boctet

if ($opt_h) { 
  print "extract_TN_date_from_fim.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h && $opt_f) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "fim_arrival_times_and_msg_ids.txt";

	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	open Fout2, ">tri.fim" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print "Extract from $fichierInput to $fichierOutput, please wait...\n";	
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		@MOT = split " ",$LIGNE;
		BoctetProcessing::setRefMOT(\@MOT);
		#print "$MOT[14]\n";
		# Recherche du label et du sublabel
		my $Label_bit_offset=2;
		my $Label_bit_number=5;
		my $Label = BoctetProcessing::getJValue($Label_bit_offset, $Label_bit_number);
		my $Sublabel_bit_offset=7;
		my $Sublabel_bit_number=3;
		my $Sublabel = BoctetProcessing::getJValue($Sublabel_bit_offset, $Sublabel_bit_number);
		print "Label : $Label SubLabel : $Sublabel\n";
		#my $Length_fxm = scalar @MOT;
		#print "Length_fxm = $Length_fxm\n";
		if($Label == 10 && $Sublabel == 2 ){ 
		  #print "$Old_word\n";
		  if (!( $MOT[14]==$Old_word)){
		   # print "OK\n";
			print Fout "$MOT[0] J10_2_OUT\n";
		  }
		   $Old_word = $MOT[14];
		}
		if($Label == 9 && $Sublabel == 0 ){ 
			print Fout "$MOT[0] J9_0_OUT\n";
		}
		if($Label == 3 && $Sublabel == 2 && !(scalar @MOT < 22) ){ 
			my $IFF_M2_bit_offset = 173;
			my $IFF_M2_bit_number= 12;
			my $String_value = Conversion::toOctalString(BoctetProcessing::getJValue($IFF_M2_bit_offset, $IFF_M2_bit_number)) ;
			print "IFF M2 : $String_value\n";
			print Fout "$MOT[0] IFF_$String_value\n";
		}
		if($Label == 3 && $Sublabel == 0 ){
			my $TIME_FUNC_bit_offset = 42;
			my $TIME_FUNC_bit_number= 3;
			my $String_value = Conversion::toOctalString(BoctetProcessing::getJValue($TIME_FUNC_bit_offset, $TIME_FUNC_bit_number)) ;
			print "Time function : $String_value\n";
			print Fout "$MOT[0] TIME_FUNC_$String_value\n";
			print Fout2 "$LIGNE\n";
		}
		if($Label == 3 && $Sublabel == 6  && !(scalar @MOT < 22)){
			my $MINUTE_bit_offset = 37;
			my $MINUTE_bit_number= 6;
			my $String_value = Conversion::toOctalString(BoctetProcessing::getJValue($MINUTE_bit_offset, $MINUTE_bit_number));
			#print "TN : $String_value\n";
			print Fout "$MOT[0] MINUTE_$String_value\n";
		}
		if($Label == 3 && $Sublabel == 7 && !(scalar @MOT < 22)){
			my $BEAR_bit_offset = 126;
			my $BEAR_bit_number= 4;
			my $String_value = Conversion::toOctalString(BoctetProcessing::getJValue($BEAR_bit_offset, $BEAR_bit_number));
			#print "TN : $String_value\n";
			print Fout "$MOT[0] BEAR_$String_value\n";
		}
		if($Label == 12 && $Sublabel == 6 ){
			my $SID_bit_offset = 13;
			my $SID_bit_number= 4;
			my $String_value = Conversion::toOctalString(BoctetProcessing::getJValue($SID_bit_offset, $SID_bit_number));
			my $INDEX_bit_offset = 23;
			my $INDEX_bit_number= 6;
			my $String_value2 = Conversion::toOctalString(BoctetProcessing::getJValue($INDEX_bit_offset, $INDEX_bit_number));
			#print "TN : $String_value\n";
			print Fout "$MOT[0] INDEX_$String_value2$String_value\n";
		}
		if($Label == 12 && $Sublabel == 7 ){
			my $INDEX_bit_offset = 13;
			my $INDEX_bit_number= 6;
			my $String_value2 = Conversion::toOctalString(BoctetProcessing::getJValue($INDEX_bit_offset, $INDEX_bit_number));
			#print "TN : $String_value\n";
			print Fout "$MOT[0] INDEX_$String_value2\n";
		}
	}
	close Fin;
	close Fout;
	# A activer en cas de messages doublon 
	if ($SuppDoublon == 1) {
	  # Suppresion des doublons
	  open Fin1, "<$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	  open Fout, ">temp.txt" or die "impossible d'ouvrir le fichier de sortie temp.txt \n";
	  while(<Fin1>){
	    my $Line = $_; 
	    chomp $Line;
	    #print "$Line\n";
	    $Line =~ /^(\d\d):(\d\d):(\d\d)\.(\d\d\d)\s(.*)/;
	    my $Heure = $1;
	    my $Minute = $2;
	    my $Seconde = $3;
	    my $Millisec = $4;
	    my $Msg_ID = $5;
	    my $Doublon_ind = 0;
	    open Fin2, "<$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	    while(<Fin2>){
	      my $Line2 = $_;
	      chomp $Line2;
	      #print "$Line2\n";
	      $Line2 =~ /^(\d\d):(\d\d):(\d\d)\.(\d\d\d)\s(.*)/;
	      my $Heure2 = $1;
	      my $Minute2 = $2;
	      my $Seconde2 = $3;
	      my $Millisec2 = $4;
	      my $Msg_ID2 = $5;
	      #print "Heure $Heure, Heure2 $Heure2 $Msg_ID2 $Msg_ID $Millisec2 $Millisec\n";
	      #if ($Heure2 > $Heure && $Minute2 > $Minute && $Second2 > $Second ) break
	      if ($Heure2 == $Heure && $Minute2 == $Minute && $Seconde2 == $Seconde && $Msg_ID2 eq $Msg_ID && $Millisec2 > $Millisec) {
		$Doublon_ind = 1;
	      }
	      else {
		next;
	      }
	    }
	    close Fin2;
	    if ($Doublon_ind == 0) { 
	      print Fout "$Line\n";
	    }
	  }
	  close Fin1;
	  close Fout;
	  system("mv temp.txt $fichierOutput");
	}
	print "That all folk !\n";
      }
exit 0;
