#!/usr/bin/perl -w

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(H:/tools/perlprog/lib);
use Net::TcpDumpLog;
use Conversion;
use BOM;
use SimpleMsg;
use J_Msg;
use Time_conversion;
use File::Basename;

print "convertie$ARGV[0]\n";
my $debug = 6;
my $log_file = $ARGV[0];

open Fin1, "<$log_file" or die "impossible ouvrir $tests_doors_file...";

open FoutSIMPLE, ">result.so" or die "impossible ouvrir result.so";
open FoutFIM, ">result.fim" or die "impossible ouvrir result.fim";
open Foutlog, ">result.log" or die "impossible ouvrir result.log";

while(<Fin1>){
	my $line = $_;
	chomp $line;
	# suppression du début de ligne
	$line =~ /^.* (\d+\.\d+).*SNCP_INTERFACE\/TACTICAL_SOCKET(.*)$/;
	my $time = $1;
	print Foutlog "time = $time\n";
	my ($heure, $minute, $seconde, $milli) = conv2Time($time);
	$line =~ s/^.*SNCP_INTERFACE\/TACTICAL_SOCKET\s\(\s\d+\)\s+(.*)$/$1/;
	$line =~ /^36 49 (\S\S) (\S\S)/;
	my $length = "0000$1$2";
	$line = uc($line);
	$line =~ s/ //g;
	print Foutlog "$time $line\n";
	my $FIM = decodeSIMPLEFIM($line);
	$FIM = uc ($FIM);
  	if($FIM ne "0"){
	    print FoutFIM "$heure:$minute:$seconde.$milli $FIM" ;
    }
    else {
		print FoutSIMPLE "$heure:$minute:$seconde.$milli $length 1C000000 $line\n";
	}
}
close Fin1;
close Fout;
close Foutlog;

exit 0;

sub decodeSIMPLEFIM {
	my $Line = shift;
	print Foutlog "$Line\n";
	$Line =~ s/\s//g;
	$Line =~ s/(..)(..)/$2 $1 /g;
	# Decodage entete SIMPLE en mot de 16 bits
	# 0-3 Network header
	# 3-6 Packet heaer
	# 7-13 Entête SIMPLE L16
	# msg J sur 5 mot de 16bit
	# checksun sur 16 bit
	print Foutlog "$Line\n";
		my @Entete = split (" ",$Line);
		print Foutlog "Sync : $Entete[1]$Entete[0]\n"if($debug == 6);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print Foutlog "$Length\n";		
		$Length = hex($Length);
		print Foutlog "Length = $Length\n"if($debug == 6);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print Foutlog "Seq_number = $Seq_number\n"if($debug == 6);
		my $Source_node = hex($Entete[6]);
		print Foutlog "Source node = $Source_node\n"if($debug == 6);
		my $Source_sub_node = hex($Entete[7]);
		print Foutlog "Source subnode = $Source_sub_node\n"if($debug == 6);
		my $Dest_node = hex($Entete[8]);
		print Foutlog "Dest node = $Dest_node\n"if($debug == 6);
		my $Dest_sub_node = hex($Entete[9]);
		print Foutlog "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
		my $Packet_size = hex($Entete[10]);	
		print Foutlog "Packet size = $Packet_size\n"if($debug == 6);
		my $Packet_type = hex($Entete[11]);
		print Foutlog "Packet type = $Packet_type\n"if($debug == 6);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print Foutlog "Transmit time = $Transit_time\n"if($debug == 6);
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print Foutlog "$Line\n$Packet_header_data\n"if($debug == 6);
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print Foutlog "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print Foutlog "\tRC_flag = $RC_flag\n"if($debug == 6);
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print Foutlog "\tNet_number= $Net_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print Foutlog "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print Foutlog "\tNPG_number = $NPG_number\n"if($debug == 6);
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print Foutlog "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print Foutlog "\tSTN = $STN\n"if($debug == 6);
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print Foutlog "\tWord_count = $Word_count\n"if($debug == 6);
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print Foutlog "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		  my $Msg_data= substr($Packet_header_data,28);
		  print Foutlog "\tMsg_data = $Msg_data\n"if($debug == 6);
		  # Suppression du checksum
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print Foutlog "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    print Foutlog "\t\t$Msg_data\n";
		    my $lengthFxm = $Word_count*2+4+16;
		    $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
		    print Foutlog "longueur en hexa sur 8 bit = $lengthFxm\n";
		    my $STN = substr(Conversion::toHexaString($STN, 4),-4,4);
		    print Foutlog "STN : $STN\n";
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number, 4),-4,2);
	        my $NPG_number_low = substr(Conversion::toHexaString($NPG_number, 4),-2,2);
		    my $Msg_data= "0000 0000 0000 0000 0000 0000 $NPG_number_low$NPG_number_high $STN"." $Msg_data";
		    #print Foutlog "\t\t$Msg_data\n";
			$Msg_data = "$lengthFxm 06000001 $Msg_data\n";
			print Foutlog "\t\t$Msg_data\n";
			return $Msg_data;
		  }
		  else {
			return 0;
		}
	}
	else {
		return 0;
	}
}

sub conv2Time {
	my $chrono = shift;
	my $milli = 0;
	#print Foutlog "chron : $chrono \n";
	my $heure = int $chrono/3600;
	#print Foutlog "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);	
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	#print Foutlog "$heure $minute $seconde\n";
	$milli = int(($seconde-int($seconde))*1000);
	$seconde = int( $seconde);
	#print Foutlog "$heure $minute $seconde $milli\n";
	$heure = substr('00'.$heure, -2);
	#print Foutlog "$heure\n";
	$minute = substr('00'.$minute, -2);
	#print Foutlog "$minute\n";
	$seconde = substr('00'.$seconde, -2);
	$milli = substr('00'.$milli, -3);
	print Foutlog "$heure $minute $seconde $milli\n" if($debug == 1);
	return ($heure, $minute, $seconde, $milli);
}
