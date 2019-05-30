#! /bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 26/05/2006
# Description :
# génére les fichiers recorder.fom et recorder.fim à partir des traces full socket dump du fichier recorder.log
# Les fichiers .fim et .fom sont compatibles avec l'outil Aladdin

my $time;
my $msg;
my $findr = 0;
my $findw = 0;
my $heure;
my $minute;
my $seconde;
# heure réception msg;
my $heure_r;
my $minute_r;
my $seconde_r;
# heure émission msg
my $heure_e;
my $minute_e;
my $seconde_e;
my $BXM1;
my $BXM2;
my $FXM;
my $lengthFxm;
my $Fim1MsgHeader = "06000001";
my $Fom1MsgHeader = "04000001";

sub conv2Time {
	my $chrono = shift;
	#print "chron : $chrono \n";
	my $heure = int $chrono/3600;
	#print "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);
	#print "$minute\n";
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	#print "$seconde\n";
	return ($heure, $minute, $seconde);
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

open Fin, "<recorder.log" or die " Impossible ouvrir recorder.log";
open Fout1, ">recorder.fim" or die "Impossible ouvrir recorder.fim";
open Fout2, ">recorder.fom" or die "Impossible ouvrir recorder.fom";

print " Create recorder.fom and recorder.fim from recorder.log, please wait...\n";

while(<Fin>) {
  	$line = $_;
	# récupère l'heure d'écriture
	if($findw == 0 && $line =~ /(\d+\.\d+)\sWRITE_DONE                 in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(umat_side\)\s*(..) (..) (.*)\s*/){
		$findw = 0;
		$time = $1;
		($heure_e, $minute_e, $seconde_e) = conv2Time($time);
		#print "$heure_e:$minute_e:$seconde_e\n";
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		$BXM1 = $2;
		$BXM2 = $3;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		$FXM=$4;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print "$FXM\n";
		#print "C'est un FIM \n";
		if($BXM1 =~ /82/){
		  #print "C'est un FIM01 \n";
		  # Calcul de la longueur du FXM
		  $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  if ($seconde_e < 10) {
		    printf ( "%02d:%02d:0%2.3f $lengthFxm $Fim1MsgHeader $FXM\n", $heure_e, $minute_e, $seconde_e);
		    printf Fout1 ( "%02d:0%2d:%02.3f $lengthFxm $Fim1MsgHeader $FXM\n", $heure_e, $minute_e, $seconde_e);
		  }
		  else {
		    #printf ( "%02d:%02d:%2.3f $lengthFxm $Fim1MsgHeader $FXM\n", $heure_e, $minute_e, $seconde_e);
		    printf Fout1 ( "%02d:%02d:%2.3f $lengthFxm $Fim1MsgHeader $FXM\n", $heure_e, $minute_e, $seconde_e);
		  }
		}
		next;	
	}
	# récupère la dernière heure de lecture
	if($findr == 0 && $line =~ /(\d+\.\d+)\sREAD_DONE                  in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \( 12\)\s*(..)\s(..)/){
		$findr = 1;
		$time = $1;
		($heure_r, $minute_r, $seconde_r) = conv2Time($time);
		$BXM1 = $2;
		$BXM2 = $3;
		#print "heure reception : $heure_r, $minute_r, $seconde_r\n";
		next;	
	}
	# récupère le FIM ou le FOM
	if($findr == 1 && $line =~ /\d+\.\d+\sREAD_DONE                  in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \( 12\)\s*(.*)/){
		$findr = 0;
		#print "heure reception : $heure_r, $minute_r, $seconde_r\n";
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		$FXM = $1;
		#print "$FXM\n";
		# suppresion des blancs
		$FXM =~ s/\s//g;
		#print "$FXM\n";
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print "$FXM\n";
		# Identification d'un FXM01
		if($BXM1 =~ /82/){
		  # Calcul de la longueur du FXM
		  $lengthFxm = hex($BXM2);
		  #print "mod : $mod5 \n";
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = toHexaString($lengthFxm);
		  #print "C'est un FOM\n";
		  # formattage des secondes ss.mmm
		  if ($seconde_r < 10) {
		    printf Fout2 ( "%02d:%02d:0%2.3f $lengthFxm $Fom1MsgHeader $FXM\n", $heure_r, $minute_r, $seconde_r);
		  }
		  else {
		    printf Fout2 ( "%02d:%02d:%2.3f $lengthFxm $Fom1MsgHeader $FXM\n", $heure_r, $minute_r, $seconde_r);
		  }			
		}
		next;
	      }
      }
close Fin;
close Fout1;
close Fout2;
print "That's all folk! \n";
exit 0;
