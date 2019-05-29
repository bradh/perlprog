#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 26/05/2006
# Description :
# extrait du fichier recorder.fom les messages J3.X J2.X avec leur TN / Source TN 
# dans le fichier fom_arrival_times_and_tns.txt


use Getopt::Std;

my @MOT;
my $RESULTS_FILE = "fom_arrival_times_and_tns.txt";

getopts("hf:");

my $Offset_motI=8; # offset du mot I dans le tableau @MOT $MOT[13].$MOT[14] est le 1er boctet

sub getJValue {
	my $Bit_offset = shift; # compris entre 0 et 79
	my $Bit_number = shift; # compris entre 1 et 80
	# Calcul des boctets utiles
	my $First_boctet = int($Bit_offset/16);
	my $Last_boctet = int(($Bit_offset+$Bit_number)/16);
	my $First_bit_of_first_boctet = $Bit_offset%16;
	my $Last_bit_of_last_boctet = ($Bit_offset+$Bit_number)%16;
	my $String = getBoctetHexaString($Last_boctet);
	$String = toHexaString(maskBoctetLastBit($String, $Last_bit_of_last_boctet));
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
  print "extract_TN_date_from_fom.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h && $opt_f ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "$RESULTS_FILE";

	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print " Create $fichierOutput from $fichierInput, please wait...\n";
	#for $I (0..15) {
	#	my $valeur = maskOctetLastBit("FFFF", $I);
	#}
	#exit 0;
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
		print "Label : $Label SubLabel : $Sublabel\n";
		if($Label == 10 && $Sublabel == 2){
		  # simulation d'un TN = 12345
			print Fout "$MOT[0] 12345 J10_2_IN $Label $Sublabel \n";
		}
		if($Label == 9 && $Sublabel == 0){
		  # simulaltion d'un TN = 12346
			print Fout "$MOT[0] 12346 J9_0_IN $Label - $Sublabel IN \n";
		}
		if($Label == 3 && ($Sublabel == 0 || $Sublabel == 2 ||$Sublabel == 3 || $Sublabel == 5)){
			my $TN_bit_offset = 19;
			my $TN_bit_number= 19;
			my $String_value = getJValue($TN_bit_offset, $TN_bit_number) ;
			#print "$String_value\n";
			print Fout "$MOT[0] $String_value $Label $Sublabel\n";
		}
		if($Label == 3 && ($Sublabel == 6 || $Sublabel == 7)){
			my $TN_bit_offset = 18;
			my $TN_bit_number= 19;
			my $String_value = getJValue($TN_bit_offset, $TN_bit_number) ;
			#print "TN : $String_value\n";
			print Fout "$MOT[0] $String_value $Label $Sublabel\n";
		}
		if($Label == 2) {
			my $STN = hex("$MOT[4]");
			print Fout "$MOT[0] $STN $Label $Sublabel\n";
		}
	}
}
close Fin;
close Fout;
print "That's all folk !\n";
exit 0;
