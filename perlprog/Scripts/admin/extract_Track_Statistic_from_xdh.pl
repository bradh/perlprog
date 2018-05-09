#!/usr/bin/perl
# #!/cygdrive/c/Perl/bin/perl 

use Getopt::Std;

my $RESULTS_FILE2 = "track_statistic.txt";
my $RESULTS_FILE = "track_summary.txt";

getopts("hf:");

if ($opt_h) { 
  print "extract_TN_date_from_xdh.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h && $opt_f ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput2 = "$RESULTS_FILE2";
	my $fichierOutput = "$RESULTS_FILE";

	open Fin, "<$fichierInput.xhd" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	open Fout2, ">$fichierOutput2" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print " Create $fichierOutput and $fichierOutput2 from $fichierInput \n";
	# Traitement du fichier xhd
	print Fout "Date, Sens, Msg ID,Source TN, SysTN, Link TN, TQ, LTCI, Drop Reason, Tx Status, SysTN Ret, SysTN Drop, SysTN New, LTN Ret, LTN Drop, Resp. \n";
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;

		if($MOT[2] =~ /00..(....)/){
			$AHD_id = hex($1);
			if($AHD_id == 101){
				#print "$LIGNE\n";
				my $STN_offset = 88;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTCI_offset = 104;
				my $LTCI_length = 8;
				my $LTCI_offset_byte = int($LTCI_offset/8)+3;
				my $LTCI_value = $MOT[$LTCI_offset_byte];
				#$STN_value = toOctalString(hex($STN_value));
				$LTCI_value = hex($LTCI_value);
				my $TQ_offset = 304;
				my $TQ_length = 8;
				my $TQ_offset_byte = int($TQ_offset/8)+3;
				my $TQ_value = $MOT[$TQ_offset_byte];
				#$STN_value = toOctalString(hex($STN_value));
				$TQ_value = hex($TQ_value);
				print Fout "$MOT[0], xhd, $AHD_id, , $STN_value, , $TQ_value, $LTCI_value, , , , , , \n";
			}
			if($AHD_id == 121){
				#print "$LIGNE\n";
				my $STN_offset = 88;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 112;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				print Fout "$MOT[0], xhd, $AHD_id, , $STN_value, $LTN_value, , , , , , ,  \n";
			}
			if($AHD_id == 110){
				#print "$LIGNE\n";
				my $STN_offset = 104;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 120;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				print Fout "$MOT[0], xhd, $AHD_id, , $STN_value, $LTN_value, , , , , , , \n";
			}
			if($AHD_id == 334){
				print "AHD334\n";
				#print "$LIGNE\n";
				my $STNR_offset = 104;
				my $STNR_length = 16;
				my $STNR_offset_byte = int($STNR_offset/8)+3;
				my $STNR_value = $MOT[$STNR_offset_byte].$MOT[$STNR_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STNR_value = hex($STNR_value);
				my $STND_offset = 120;
				my $STND_length = 16;
				my $STND_offset_byte = int($STND_offset/8)+3;
				my $STND_value = $MOT[$STND_offset_byte].$MOT[$STND_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STND_value = hex($STND_value);
				my $STNDN_offset = 144;
				my $STNDN_length = 16;
				my $STNDN_offset_byte = int($STNDN_offset/8)+3;
				my $STNDN_value = $MOT[$STNDN_offset_byte].$MOT[$STNDN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STNDN_value = hex($STNDN_value);
				my $LTNR_offset = 200;
				my $LTNR_length = 32;
				my $LTNR_offset_byte = int($LTNR_offset/8)+3;
				my $LTNR_value = $MOT[$LTNR_offset_byte].$MOT[$LTNR_offset_byte+1].$MOT[$LTNR_offset_byte+2].$MOT[$LTNR_offset_byte+3];
				$LTNR_value = toOctalString(hex($LTNR_value));
				#$LTCI_value = hex($LTCI_value);
				my $LTND_offset = 232;
				my $LTND_length = 32;
				my $LTND_offset_byte = int($LTND_offset/8)+3;
				my $LTND_value = $MOT[$LTND_offset_byte].$MOT[$LTND_offset_byte+1].$MOT[$LTND_offset_byte+2].$MOT[$LTND_offset_byte+3];
				$LTND_value = toOctalString(hex($LTND_value));
				print Fout "$MOT[0], xhd, $AHD_id, , , , , , , , $STNR_value, $STND_value, $STNDN_value, $LTNR_value,  $LTND_value \n";
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
				print Fout "$MOT[0], xhd, $AHD_id, $TN_value\n";
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
				print Fout "$MOT[0], xhd, $AHD_id, $TN_value\n";
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
				print Fout "$MOT[0], xhd, $AHD_id, $TN_value\n";
			}
		}
	}	
	close Fin;

	# Traitement du fichier xdh
	open Fin, "<$fichierInput.xdh" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;
		if($MOT[2] =~ /01..(....)/){
			$ADH_id = hex($1);
			#print "$ADH_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($ADH_id == 101 || $ADH_id == 102 || $ADH_id == 103 || $ADH_id == 104 || $ADH_id == 105 || $ADH_id == 106 || $ADH_id == 107 || $ADH_id == 108|| $ADH_id == 109){
				# Source Track Number
				my $SoTN_offset = 96;
				my $SoTN_length = 16;
				my $SoTN_offset_byte = int($SoTN_offset/8)+3;
				my $SoTN_value = $MOT[$SoTN_offset_byte].$MOT[$SoTN_offset_byte + 1].$MOT[$SoTN_offset_byte + 2].$MOT[$SoTN_offset_byte + 3];
				#$STN_value = toOctalString(hex($STN_value));
				$SoTN_value = hex($SoTN_value);

				my $STN_offset = 136;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 154;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				my $TQ_offset = 384;
				my $TQ_length = 8;
				my $TQ_offset_byte = int($TQ_offset/8)+3;
				my $TQ_value = $MOT[$TQ_offset_byte];
				#$STN_value = toOctalString(hex($STN_value));
				$TQ_value = hex($TQ_value);
				print Fout "$MOT[0], xdh, $ADH_id, $SoTN_value, $STN_value, $LTN_value, $TQ_value, , , , , , \n";
			}
			if($ADH_id == 121){

				# Source Track Number
				my $SoTN_offset = 96;
				my $SoTN_length = 16;
				my $SoTN_offset_byte = int($SoTN_offset/8)+3;
				my $SoTN_value = $MOT[$SoTN_offset_byte].$MOT[$SoTN_offset_byte + 1].$MOT[$SoTN_offset_byte + 2].$MOT[$SoTN_offset_byte + 3];
				#$STN_value = toOctalString(hex($STN_value));
				$SoTN_value = hex($SoTN_value);

				print "ADH121\n";
				my $STN_offset = 104;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 120;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				my $DROP_offset = 120;
				my $DROP_length = 32;
				my $DROP_offset_byte = int($DROP_offset/8)+3;
				my $DROP_value = $MOT[$DROP_offset_byte];
				#$DROP_value = toOctalString(hex($DROP_value));
				$DROP_value = hex($DROP_value);
				print Fout "$MOT[0], xdh, $ADH_id, $SoTN , $STN_value, $LTN_value, ,  , $DROP_value, , , , , \n";
			}
			if($ADH_id == 125){
				my $STN_offset = 128;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 96;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				my $STATUS_offset = 144;
				my $STATUS_length = 8;
				my $STATUS_offset_byte = int($STATUS_offset/8)+3;
				my $STATUS_value = $MOT[$STATUS_offset_byte];
				#$STATUS_value = toOctalString(hex($STATUS_value));
				$STATUS_value = hex($STATUS_value);
				print Fout "$MOT[0], xdh, $ADH_id, , $STN_value, $LTN_value, , , , $STATUS_value, , , , \n";
			}
			if($ADH_id == 135){
				my $STN_offset = 88;
				my $STN_length = 16;
				my $STN_offset_byte = int($STN_offset/8)+3;
				my $STN_value = $MOT[$STN_offset_byte].$MOT[$STN_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STN_value = hex($STN_value);
				my $LTN_offset = 112;
				my $LTN_length = 32;
				my $LTN_offset_byte = int($LTN_offset/8)+3;
				my $LTN_value = $MOT[$LTN_offset_byte].$MOT[$LTN_offset_byte+1].$MOT[$LTN_offset_byte+2].$MOT[$LTN_offset_byte+3];
				$LTN_value = toOctalString(hex($LTN_value));
				#$LTCI_value = hex($LTCI_value);
				print Fout "$MOT[0], xdh, $ADH_id, , $STN_value, $LTN_value, , , , , , , , \n";
			}
			if($ADH_id == 142){
			  # simulation d'un TN fictif 12345
				print Fout2 "$MOT[0] 12345 J10_2_IN ADH$ADH_id\n";
			}
			if($ADH_id == 147){
			  # simulation d'un TN fictif 12346
			  print Fout2 "$MOT[0] 12346 J9_2_IN ADH$ADH_id\n";
			}
			if($ADH_id == 336){
				print "ADH336\n";
				#print "$LIGNE\n";
				my $STNR_offset = 128;
				my $STNR_length = 16;
				my $STNR_offset_byte = int($STNR_offset/8)+3;
				my $STNR_value = $MOT[$STNR_offset_byte].$MOT[$STNR_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STNR_value = hex($STNR_value);
				my $STND_offset = 176;
				my $STND_length = 16;
				my $STND_offset_byte = int($STND_offset/8)+3;
				my $STND_value = $MOT[$STND_offset_byte].$MOT[$STND_offset_byte + 1];
				#$STN_value = toOctalString(hex($STN_value));
				$STND_value = hex($STND_value);
				my $LTNR_offset = 144;
				my $LTNR_length = 32;
				my $LTNR_offset_byte = int($LTNR_offset/8)+3;
				my $LTNR_value = $MOT[$LTNR_offset_byte].$MOT[$LTNR_offset_byte+1].$MOT[$LTNR_offset_byte+2].$MOT[$LTNR_offset_byte+3];
				$LTNR_value = toOctalString(hex($LTNR_value));
				#$LTCI_value = hex($LTCI_value);
				my $LTND_offset = 192;
				my $LTND_length = 32;
				my $LTND_offset_byte = int($LTND_offset/8)+3;
				my $LTND_value = $MOT[$LTND_offset_byte].$MOT[$LTND_offset_byte+1].$MOT[$LTND_offset_byte+2].$MOT[$LTND_offset_byte+3];
				$LTND_value = toOctalString(hex($LTND_value));
				my $RESP_offset = 224;
				my $RESP_length = 32;
				my $RESP_offset_byte = int($RESP_offset/8)+3;
				my $RESP_value = $MOT[$RESP_offset_byte];
				$RESP_value = hex($RESP_value);
				print Fout "$MOT[0], xdh, $ADH_id, , , , , , , , $STNR_value, $STND_value, , $LTNR_value,  $LTND_value, $RESP_value \n";
			}
		}
		if($MOT[2] =~ /03....(..)/){
			$TDH_id = hex($1);
			if($TDH_id == 10){
				print Fout2 "\nTime = $MOT[0] \n";
				my $link_id = hex($MOT[14]);
				print Fout2 "link_id = $link_id \n";
				my $Tx_Filtered_Track = hex($MOT[15].$MOT[16]);
				print Fout2 "TX Filtered Track = $Tx_Filtered_Track \n";
				my $Tx_Track = hex($MOT[17].$MOT[18]);
				print Fout2 "TX Track = $Tx_Track \n";
				my $Rx_Un_Track = hex($MOT[19].$MOT[20]);
				print Fout2 "RX Unknown Track = $Rx_Un_Track \n";
				my $Rx_Space_Track = hex($MOT[21].$MOT[22]);
				print Fout2 "RX Space Track = $Rx_Space_Track \n";
				my $Rx_Air_Track = hex($MOT[23].$MOT[24]);
				print Fout2 "RX Air Track = $Rx_Air_Track \n";
				my $Rx_Surface_Track = hex($MOT[25].$MOT[26]);
				print Fout2 "RX Surface Track = $Rx_Surface_Track \n";
				my $Rx_Subsurface_Track = hex($MOT[27].$MOT[28]);
				print Fout2 "RX Subsurface Track = $Rx_Subsurface_Track \n";
				my $Rx_Land_Track = hex($MOT[29].$MOT[30]);
				print Fout2 "RX Land Track = $Rx_Land_Track \n";
				my $Rx_Surveillance_Message = hex($MOT[31].$MOT[32]);
				print Fout2 "RX Surveillance Message = $Rx_Surveillance_Message \n";


			}
		}
	}
}
print "That's all folk !\n";
exit 0;

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
