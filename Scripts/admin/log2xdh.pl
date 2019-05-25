#! /bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 26/05/2006
# Description :
# génére les fichiers sampt_main.xhd et sampt_main.xdh à partir des traces full socket dump du fichier sampt_main.log
# Les fichiers .xhd et .xdh sont compatibles avec l'outil Aladdin


my $time;
my $msg;
my $findw = 0;
my $findr = 0;
my $length = 0;
my $length_xhd;
my $thd="";
my $temp_xhd;
my $temp_xhd_id;
my $tdh;
my $temp;
my $heure;
my $minute;
my $seconde;
my $length_hexa;

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

open Fin, "<sampt_main.log" or die " Impossible ouvrir sampt_main.log";
open Fout1, ">sampt_main.xdh" or die " Impossible ouvrir sampt_main.xdh";
open Fout2, ">sampt_main.xhd" or die " Impossible ouvrir sampt_main.xhd";

print " Create sampt_main.xhd & sampt_main.xdh from sampt_main.log, please wait...\n";
while(<Fin>) {
	my $line = $_;
	if($findw == 0 && $line =~/WRITE_DONE\s+in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(MLK Msg Queue\)\s+(.*)\s+\.\.\./){
		$msg = $1;
		#print "$msg\n";
		if($msg =~ /44 48\s(\d\d)\s(\d\d)\s(.+)/){
			#print "XDH ... \n";
			#print "$msg\n";
			$length_hexa = "0000$1$2";
			$length = hex($length_hexa);
			#print "$length_hexa : $length\n";
			$tdh = $3;
			#suppression des espaces
			$tdh =~ s/\s//g;
			#identification du adh pour Aladdin
			$tdh =~ s/^00/01/;
			# calcul de la longueur restante	
			$length = $length - length($tdh)/2;
			#print "$tdh\n";;
			#print "$length\n"; 
			if ($length  > 0 ){
				# si tout le message n'est pas lu on passe le findw à 1
				$findw = 1;
				next;
			}
			else {
				$findw = 2;
				next;
			}
		}
	}
	if($findw == 1 && $length > 0 && $line =~/WRITE_DONE\s+in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(MLK Msg Queue\)\s+(.*)\s+\.\.\./){
			$temp = $1;
			#suppression des espaces
			$temp =~ s/\s//g;
			#print "$temp\n";
			# calcul de la longueur restante	
			$length = $length - length($temp)/2;
			#print "$length\n"; 
			# Concatenation du message
			$tdh = "$tdh$temp";
			#print "tdh : $tdh\n";

			if ($length > 0 ){
				# si tout le message n'est pas lu on passe le findw à 
				next;
			}
			else {
				$line =~ /(\d+\.\d+)/;
				$time = $1;
				$tdh =~ /^(.{8})(.*)/;
				my $tmp1 = $1;
				my $tmp2 = $2;
				$tmp2 =~ s/(....)/$1 /g;
				$tdh = "$tmp1 $tmp2";
				#print "$tdh\n";
				($heure, $minute, $seconde) = conv2Time($time);
				if($seconde >= 10){ 
					printf Fout1 ( "%02d:%02d:%2.3f $length_hexa $tdh\n", $heure, $minute, $seconde);
				}
				else{
					printf Fout1 ( "%02d:%02d:0%2.3f $length_hexa $tdh\n", $heure, $minute, $seconde);
				}
				$findw = 0;
				next;
			}
	}
	if($findw == 2 && $line =~ /(\d+\.\d+)\s+MESSAGE_SENT/){
		
		$findw = 0;
		next;	
	}
# Traitement des READ
	# Première ligne contenant la longueur
	if($findr == 0 && $line =~/READ_DONE\s+in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \( 9\)\s+(..)\s+(..)/){
		$length_xhd_hexa = "0000$1$2";
		$length_xhd = hex($length_xhd_hexa);
		$findr = 1;
		$thd = "";
		#print "Length : $length_xhd\n";
		next;
		}
	#  Deuxième ligne contenant le message id
	if($findr == 1 && $length_xhd > 0 && $line =~/READ_DONE\s+in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \( 9\)\s+(.*)/){
			$temp_xhd_id = $1;
			#suppression des espaces
			$temp_xhd_id =~ s/\s//g;
			#ajout du code Aladdin
			$temp_xhd_id =~ s/^00/02/;
			#print "$temp_xhd_id\n";
			# calcul de la longueur restante	
			$length_xhd = $length_xhd - length($temp_xhd_id)/2;
			#print "Length : $length_xhd\n";
			if ($length_xhd > 0 ){
				# si tout le message n'est pas lu on passe le findr à 
				$findr = 2;
				next;
			}
			# sinon le message n'est pas valide
			else {
				$findr = 0;
				next;
			}
	}
	if($findr == 2 && $length_xhd > 0 && $line =~/READ_DONE\s+in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \( 9\)\s+(.*)/){
			$temp_xhd = $1;
			#suppression des espaces
			$temp_xhd =~ s/\s//g;
			#print "$temp_xhd\n";
			# calcul de la longueur restante	
			$length_xhd = $length_xhd - length($temp_xhd)/2;
			#print "Length : $length_xhd\n";
			# Concatenation du message
			$thd = "$thd$temp_xhd";
			#print "thd : $thd\n";
			if ($length_xhd > 0 ){
				# si tout le message n'est pas lu on passe le findr à 
				next;
			}
			else {
				$line =~ /(\d+\.\d+)/;
				my $time_xhd = $1;
				#print "Time : $time_xhd\n";
				($heure, $minute, $seconde) = conv2Time($time_xhd);
				#suppression des espaces
				$thd =~ s/\s//g;
				#ajout d'un espace tous les octets
				$thd =~ s/(..)/$1 /g;
				if($seconde >= 10){ 
					printf Fout2 ( "%02d:%02d:%2.3f $length_xhd_hexa $temp_xhd_id $thd\n", $heure, $minute, $seconde);
				}
				else{
					printf Fout2 ( "%02d:%02d:0%2.3f $length_xhd_hexa $temp_xhd_id $thd\n", $heure, $minute, $seconde);
				}
					$findr = 0;
					next;
			}
	}
}
print "That's all folk ! \n";
exit 0;
