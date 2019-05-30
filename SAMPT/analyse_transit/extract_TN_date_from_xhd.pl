#!/usr/bin/perl

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 23/05/2006
# Mis 
# Description :
# le script extrait du fichier .xhd d'entree dans un fichier texte $RESULT_FILE
# l'heure le tag du champ la valeur du champ le SysTN et pour
# exemple :
# 00:24:21.702 TIME_FUNC_0000 XHD107 TN 0377
# 00:24:21.703 IFF_0001 XHD101 TN 0407
# 00:24:21.704 ID_0000 XHD106 TN 0471
# La valeur de l'IFF est affichée en octal
# la valeur du sysTN est affichée en décimal

use Getopt::Std;

my $RESULTS_FILE = "xhd_arrival_times_and_msg_ids.txt";

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
  print "extract_TN_date_from_xhd.pl -f nom_fichier : extrait les messages AHD10x ";
  exit(0);
}
if( ! $opt_h && $opt_f ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "$RESULTS_FILE";

	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print "Extract date from $fichierInput to $fichierOutput, please wait...\n";
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		#print "$LIGNE\n";
		# formattage de la ligne 00:00:00.000 00000000 020000ID 00 00 00 00
		  $LIGNE =~ s/^(\d\d:\d\d:\d\d\.\d\d\d) (\S{8}) (\S{8}) (.*)/$4/;
		my $Time = $1;
		my $Length = $2;
		my $ID = $3;
		  $LIGNE = $4;
		$LIGNE =~ s/\s//g;
		$LIGNE =~ s/(\S\S)/ $1/g; 
		$LIGNE = "$Time $Length $ID $LIGNE\n";
		#print  "$LIGNE";
		#exit ;
		
		my @MOT = split " ",$LIGNE;
		my $AHD_id;
		#print "$MOT[14]\n";
		# récupération de l'ADH id
		if($MOT[2] =~ /02....(..)/){
			$AHD_id = hex($1);
			#print "$AHD_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($AHD_id == 142){

				print Fout "$MOT[0] J10_2_OUT \n";
			}
			if($AHD_id == 120){
				#print "$LIGNE\n";
				my $SID_offset = 552;
				my $SID_length = 8;
				my $SID_offset_byte = int($SID_offset/8)+3;
				#print "offset = $SID_offset_byte\n"; 
				my $SID_value = $MOT[$SID_offset_byte];
				$SID_value = toOctalString(hex($SID_value));
				my $INDEX_value = toOctalString(hex($MOT[24]));
				print Fout "$MOT[0] INDEX_$INDEX_value$SID_value XHD$AHD_id\n";
			}
			if($AHD_id == 218){
				#print "$LIGNE\n";
				my $SID_offset = 568;
				my $SID_length = 8;
				my $SID_offset_byte = int($SID_offset/8)+3;
				#print "offset = $SID_offset_byte\n"; 
				my $SID_value = hex($MOT[$SID_offset_byte]);
				#print "$SID_value\n";
				if ($SID_value == 4){
				  $SID_value = toOctalString(hex($SID_value));
				  my $INDEX_offset = 144;
				  my $INDEX_value = toOctalString(hex($MOT[($INDEX_offset/8)+3]));
				  print Fout "$MOT[0] INDEX_$INDEX_value XHD$AHD_id\n";
				}
			}
			if($AHD_id == 142){

				print Fout "$MOT[0] J10_2_OUT \n";
			}
			if($AHD_id == 101){
				#print "$LIGNE\n";
				my $IFF_offset = 472;
				my $IFF_length = 16;
				my $IFF_offset_byte = int($IFF_offset/8)+3;
				my $IFF_value = $MOT[$IFF_offset_byte].$MOT[$IFF_offset_byte + 1];
				$IFF_value = toOctalString(hex($IFF_value));
				my $TN_value = hex($MOT[19].$MOT[20]);
				print Fout "$MOT[0] IFF_$IFF_value XHD$AHD_id TN $TN_value\n";
			}
			if ($AHD_id == 107){
				my $TN = hex($MOT[16]);
				#print "$ADH_id\n";
				#print "$LIGNE\n";	
				my $TIM_offset = 184;
				my $TIM_length = 16;
				my $TIM_offset_byte = int($TIM_offset/8)+3;
				my $TIM_value = "00".$MOT[$TIM_offset_byte];
				my $TN_value = hex($MOT[19].$MOT[20]);
				#$PLAT_value = toOctalString(hex($PLAT_value));
				print Fout "$MOT[0] TIME_FUNC_$TIM_value XHD$AHD_id TN $TN_value\n";
			}
			if ($AHD_id == 106){
				my $TN = hex($MOT[16]);
				#print "$ADH_id\n";
				#print "$LIGNE\n";	
				my $BEAR_offset = 400;
				my $BEAR_length = 16;
				my $BEAR_offset_byte = int($BEAR_offset/8)+3;
				#print "$ID_offset_byte \n";
				my $BEAR_value = "00".$MOT[$BEAR_offset_byte];
				my $TN_value = hex($MOT[19].$MOT[20]);
				$BEAR_value = toOctalString(hex($BEAR_value));
				print Fout "$MOT[0] BEAR_$BEAR_value XHD$AHD_id TN $TN_value\n";
			}
			if ($AHD_id == 109){
				my $TN = hex($MOT[16]);
				#print "$ADH_id\n";
				#print "$LIGNE\n";	
				my $MINUTE_offset = 192;
				my $MINUTE_length = 8;
				my $MINUTE_offset_byte = int($MINUTE_offset/8)+3;
				#print "$MINUTE_offset_byte \n";
				my $MINUTE_value = "00".$MOT[$MINUTE_offset_byte];
				my $TN_value = hex($MOT[19].$MOT[20]);
				#$MINUTE_value = toOctalString(hex($MINUTE_value));
				print Fout "$MOT[0] MINUTE_$MINUTE_value XHD$AHD_id TN $TN_value\n";
			}
		}
	}
	print "That's all folk !\n";
}
exit 0;
