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

my @MOT;
my $RESULTS_FILE = "fom_arrival_times_and_tns.txt";

getopts("h");

my $Offset_motI=11; # offset du mot I dans le tableau @MOT $MOT[11] est le 1er boctet
sub getJValue {
	my $Bit_offset = shift; # compris entre 0 et 79
	my $Bit_number = shift; # compris entre 1 et 80
	# Calcul des boctets utiles
	my $First_boctet = int($Bit_offset/16);
	my $Last_boctet = int(($Bit_offset+$Bit_number)/16);
	print "$First_boctet .. $Last_boctet\n";
	my $First_bit_of_first_boctet = $Bit_offset%16;
	my $Last_bit_of_last_boctet = ($Bit_offset+$Bit_number)%16;
	my $String = getBoctetHexaString($Last_boctet);
	print "$String\n";
	$String = toHexaString(maskBoctetLastBit($String, $Last_bit_of_last_boctet));
		print "$String\n";
	if($Last_boctet>$First_boctet){
		for $I (($Last_boctet-1).. $First_boctet) {
		$String = $String . getBoctetHexaString($I);
		}
	}
	my $JValue = int(hex($String)/(2**$First_bit_of_first_boctet));
	#print "Jvalue : $JValue\n";
	return $JValue;
}

sub getBoctetHexaString {
	my $Boctet_number = shift;
	my $Boctet_index = getIndexforBoctet($Boctet_number);
	my $String = $MOT[$Boctet_index];
	#print "BoctetHexaString : $String\n";
	return $String;
}

sub getIndexforBoctet {
	my $Boctet_number = shift;
	my $IndexforBoctet = $Offset_motI + $Boctet_number;
	#print "index : $IndexforBoctet\n";
	return $IndexforBoctet;
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

if ($opt_h) { 
  print "extract_TN_date_from_fim.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "$RESULTS_FILE";
	print "Suppression des fichiers resultats...\n";
	system ("rm -fr J3-2-TN*.jo ");
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	#open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	#print " Create $fichierOutput from $fichierInput, please wait...\n";
	#for $I (0..15) {
	#	my $valeur = maskOctetLastBit("FFFF", $I);
	#}
	#exit 0;
	my @staticTargetArray;
	foreach my $index (0..64) {
		$staticTargetArray[$index]=0;
	}
	my $firstTarget = 1;
	my $firstChrono = 0;
	my $lastChrono = 0;
	
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		@MOT = split " ",$LIGNE;
		#print "$MOT[14]\n";
		# Recherche du label et du sublabel
		my $Label_bit_offset=2;
		my $Label_bit_number=5;
		my $Label = getJValue($Label_bit_offset, $Label_bit_number);
		my $Sublabel_bit_offset=7;
		my $Sublabel_bit_number=3;
		my $Sublabel = getJValue($Sublabel_bit_offset, $Sublabel_bit_number);
		#print "Label : $Label SubLabel : $Sublabel\n";

		if($Label == 3 && ($Sublabel == 0 || $Sublabel == 2 ||$Sublabel == 3 || $Sublabel == 5)){
			if ($firstTarget == 1){
				$firstChrono = toChrono($MOT[0]);
				$firstTarget = 0;
			}
			else {
				$lastChrono = toChrono($MOT[0]);
			}
			my $TN_bit_offset = 19;
			my $TN_bit_number= 19;
			my $String_value = getJValue($TN_bit_offset, $TN_bit_number) ;
			$staticTargetArray[$String_value] += 1;
			$staticTargetArray[64] += 1;			
			#print "$String_value\n";
			$fichierOutput = "J$Label-$Sublabel-TN_$String_value.fim";
			open Fout, ">>$fichierOutput" or open ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
			print Fout "$LIGNE\n";
			close Fout;
		}
	}
	close Fin;
	open Fout, ">statisticTarget.cvs" or die "Impossible ouvrir fichier";
	print Fout "Début du test = $firstChrono\n";
	print Fout "Fin du test =  $lastChrono\n";
	$lastChrono = $lastChrono - $firstChrono;
	print Fout "Durée du test = $lastChrono\n";
	my $nbreMsgAttendu = ($lastChrono-420)*50;# 280 correspond au period ou les target ne sont pas refraiichi RRN = 3
	my $temp = $staticTargetArray[64] * 100 / $nbreMsgAttendu;
	print Fout "Taux d'émission = $temp\n";
	
	foreach my $index (0..64) {
		print Fout "Nbre Target index $index = $staticTargetArray[$index]\n";
	}
	close Fout;
}

print "That's all folk !\n";
exit 0;
