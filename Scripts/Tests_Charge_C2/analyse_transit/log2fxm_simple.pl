#! /bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée pour les tests SIMPLE
# Auteur : S. Mouchot
# Mis à jour : le 20/09/2006
# Description :
# génére les fichiers recorder.simm et recorder.somm à partir des traces full socket dump du fichier recorder.log
# Le script supose que le traces READ et WRITE ne sont pas entrelacées 
# Le script suppose que les mesg SIMPLE sont lu en 2 fois 
#  1fois l'netete de 7 mot de 16 bits 
#  2 fois le packet hearder and data et le checksum
# Le script suppose que l'écriture se fait en 1 seule fois
# Attention : Le byte de poids faible des mots de 16 bit est écrit en premier dans le log du recorder !
#
# Packet SIMPLE par mot de 16 bits
# Sync Byte 2 / Sync Byte 1
# Length in Bytes 
# Seq number by node
# Source Sub-node / Source node
# Dest Sub node / Dest node
# Packet type / Packet size
# Transit time
# Packet Header and data
# ...
# Checksum

use lib qw(c:/perlprog/lib);
use Conversion;

my $Sync_byte_1 = 0x49;
my $Sync_byte_2 = 0x36;
my $Length;
my $Packet_type;
my $Seq_number;
my $Source_sub_node;
my $Source_node;
my $Dest_sub_node;
my $Dest_node;
my $Transit_time;
my $Packet_header_data;

my $Msg_sub_type;
my $RC_flag;
my $Net_number;
my $Seq_slot_count_field_2;
my $NPG_number;
my $Seq_slot_count_field_1;
my $STN;
my $Word_count;
my $Loopback_id;
my $Msg_data;

my $Count_length;
my $msg;
my $find_r = 0;
my $find_w = 0;
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



open Fin, "<recorder.log" or die " Impossible ouvrir recorder.log";
open Fout1, ">recorder.fim" or die "Impossible ouvrir recorder.fim";
open Fout2, ">recorder.fom" or die "Impossible ouvrir recorder.fom";

print " Create recorder.fom and recorder.fim from recorder.log, please wait...\n";

while(<Fin>) {
	$Line = $_;
	# récupère la dernière heure de lecture
	if($find_r == 0 && ($Line =~ /(\d+\.\d+)\s*READ_DONE\s*in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(\s*10\)\s+(.*)/)){
		$find_r = 1;
		$time = $1;
		($heure_r, $minute_r, $seconde_r) = conv2Time($time);
		print "\nheure reception : $heure_r:$minute_r:$seconde_r\n";
		my $Line = $2;
		@Entete = split (" ",$Line);
		print " Sync : $Entete[0] $Entete[1]\n";
		$Length = "$Entete[3]"."$Entete[2]";
		print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n";
		$Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n";
		$Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n";
		$Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n";
		$Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n";
		$Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n";
		$Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n";
		$Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n";
		$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n";
		$Count_length = $Length-14;
		next;	
	}
	# récupère l'entete réseau SIM
	if($find_r == 1 && $Line =~ /READ_DONE\s*in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(\s*10\)\s+(.*)/){
	  $find_r = 0;
	  $Line = $1;
	  print "$Line\n";
	  # suppression des espaces
	  $Line =~ s/\s*//g;
	  # suppression du cheksum
	  $Line =~ s/.{4}$//;
	  $Packet_header_data = $Line;
		print "Packet_header_data = $Packet_header_data\n";
		if($Packet_type == 1){
		  $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  print "\tMsg_sub_type = $Msg_sub_type\n";
		  $RC_flag= hex(substr($Packet_header_data,2,2));
		  print "\tRC_flag = $RC_flag\n";
		  $Net_number= hex(substr($Packet_header_data,4,2));
		  print "\tNet_number= $Net_number\n";
		  $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
		  $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print "\tNPG_number = $NPG_number\n";
		  $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
		  $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n";
		  $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n";
		  $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n";
		  $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n";
		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    print "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    print "\t\t$Msg_data\n";
		    $lengthFxm = $Word_count*2+4+10;
		    $lengthFxm = toHexaString($lengthFxm);
		    $STN = substr(toHexaString($STN),-4);
		    $NPG_number_high =  substr(toHexaString($NPG_number),-4,2);
	            $NPG_number_low = substr(toHexaString($NPG_number),-2,2);
		    $Msg_data= "0000 $STN $NPG_number_low$NPG_number_high 0000 0000"." $Msg_data";
		    #print "\t\t$Msg_data\n";
		    if ($seconde_r < 10) {
		      printf Fout2 ( "%02d:%02d:0%2.3f $lengthFxm $Fom1MsgHeader $Msg_data\n", $heure_r, $minute_r, $seconde_r);
		    }
		    else {
		      printf Fout2 ( "%02d:%02d:%2.3f $lengthFxm $Fom1MsgHeader $Msg_data\n", $heure_r, $minute_r, $seconde_r);
		    }
		  }
		}
	  next;
	}
	# récupère l'heure d'écriture              WRITE_DONE   in CSC_RTE_FULL_SOCKET_DUMP/SOCKET (smpnet_side)
	if($find_w == 0 && ($Line =~ /(\d+\.\d+)\s*WRITE_DONE\s*in CSC_RTE_FULL_SOCKET_DUMP\/SOCKET \(smpnet_side\)\s+(.*)/)){
		$find_w = 0;
		$time = $1;
		($heure_e, $minute_e, $seconde_e) = conv2Time($time);
		print "\nheure emission : $heure_e:$minute_e:$seconde_e\n"; 
	       	$Line = $2;
		@Entete = split (" ",$Line);
		my $Line = $2;
		@Entete = split (" ",$Line);
		print " Sync : $Entete[0] $Entete[1]\n";
		$Length = "$Entete[3]"."$Entete[2]";
		#print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n";
		$Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n";
		$Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n";
		$Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n";
		$Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n";
		$Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n";
		$Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n";
		$Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n";
		$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n";
		$Count_length = $Length-14;
		#print "$Line\n";
		# suppression des espaces
		$Line =~ s/\s*//g;
		# suppresion des ... en fin de ligne
		$Line =~ s/\.//g;
		# suppression du cheksum
		$Line =~ s/.{4}$//;
		# suppression du Network header
		$Packet_header_data = substr($Line,28);
		print "Packet_header_data = $Packet_header_data\n";
		
		if($Packet_type == 1){
		  $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  print "\tMsg_sub_type = $Msg_sub_type\n";
		  $RC_flag= hex(substr($Packet_header_data,2,2));
		  print "\tRC_flag = $RC_flag\n";
		  $Net_number= hex(substr($Packet_header_data,4,2));
		  print "\tNet_number= $Net_number\n";
		  $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
		  $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8 ,2));
		  print "\tNPG_number = $NPG_number\n";
		  $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
		  $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n";
		  $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n";
		  $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n";
		  $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n";
		  # Si c'est un message J
		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    #print "\t\t$Msg_data\n";
		    $lengthFxm = $Word_count*2+4+16;
		    $lengthFxm = toHexaString($lengthFxm);
		    $STN = substr(toHexaString($STN),-4);
		    $NPG_number_high =  substr(toHexaString($NPG_number),-4,2);
	            $NPG_number_low = substr(toHexaString($NPG_number),-2,2);
		    $Msg_data= "0000 0000 0000 0000 0000 0000 $NPG_number_low$NPG_number_high $STN"." $Msg_data";
		    #print "\t\t$Msg_data\n";
		    if ($seconde_e < 10) {
		      printf Fout1 ( "%02d:%02d:0%2.3f $lengthFxm $Fim1MsgHeader $Msg_data\n", $heure_e, $minute_e, $seconde_e);
		    }
		    else {
		      printf Fout1 ( "%02d:%02d:%2.3f $lengthFxm $Fim1MsgHeader $Msg_data\n", $heure_e, $minute_e, $seconde_e);
		    }
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
