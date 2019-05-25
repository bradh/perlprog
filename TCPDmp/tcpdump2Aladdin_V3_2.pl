# Modif S. Mouchot le 14/09/2009
#        - Am‰lioration de la pr‰sentation des champs
#        - Add CheckButton to select interface
#        - Add Button to save configuration file
# Modif S. Mouchot le 28/06/09 anniversaire de mariage (13 ans d‰j€!)
#       - Ajout du decodage des FOM techniques (FOM03 /FOM20 / FOM62) pour LOC1
# Modif S. Mouchot le 22/06/09
#    - Ajout d'un fichier de configuration
#    - Ajout de la selection des sortie dans l'interface graphique
#    - Ajout de l'interface L16ES discrete des FIM/FOM 62 et 63
# Modif S. Mouchot le 24/02/09
#   - traitement message SIMPLE multi trame
# Modif S. Mouchot le 12/01/09
#   - Traitement XDH octet par octet pour Meltem
# Modif S. Mouchot le 7/11/08
# 	- correction fonction toChrono pour le test de transit time SAMPT
#  	- retour au decodage SIMPLE en FIM /FOM avec les fonctions locales
#	- affichage des champs des paquets SIMPLE en mode debug = 6
#
use strict;
use Tk;
use Getopt::Std;
#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(d:/perlprog/Scripts/lib);
use Net::TcpDumpLog;

use Conversion;
use SimpleMsg;
use J_Msg;

getopts("t:c:v:hf:");

my $debug = 0;
# 7 pour xdh
# 5 pour les xhd
# 6 pour le SIMPLEFOM
# 8 pour le SIMPLEFIM
# 9 pour les FIM / FOM (techniques)

my $Config_File = "TCPDump.cfg";

if(my $opt_f){
  $Config_File = "$opt_f";
}

my $processFIMFOM=0;
my $processXHDXDH=0;
my $processSIMPLE=0;
my $processSLP=0;
my $processC4TX=0;
my $processC4RX=0;

my $TCPDumpDir = "T:\\TEMP\\ForceTell\\";
my $TCPDumpFile = "FT_2.pcap";

my $OutputDir = "T:\\TEMP\\ForceTell\\";
my $OutputFile = "FT_2";

# TCP parameters for FIM/FOM flow (serveur side)
my $FIMFOM_IP_Address = "192.168.18.14";
my $FIMFOM_TCP_Port = "1035";

# TCP parameters for FIM/FOM techniques flow (serveur side)
my $FIMFOMTECH_IP_Address = "10.100.25.120";
my $FIMFOMTECH_TCP_Port = "1070";

# TCP parameters for XHD/XDH flow (server side)
my $XHD_IP_Address = "192.198.18.197";
my $XHD_TCP_Port = "40391";

# TCP parameters for SIMPLE flow (server side)
my $SIMPLE_IP_Address = "200.1.18.5";
my $SIMPLE_TCP_Port = "10301";

my $C4_SEND_IP_Address = "172.25.7.160";
my $C4_SEND_UDP_Port = "15000";

my $C4_RECEIVE_IP_Address = "172.25.7.100";
my $C4_RECEIVE_UDP_Port = "14000";

# TCP parameters for SLP flow (server side)
my $SLP_SERVER_IP_Address = "172.25.8.170";
my $SLP_SERVER_TCP_Port = "10200";

my $origin_seconds = 0;
my $origin_milli = 0;

# Fichier de log
my $RESULTS_LOG = "Log.txt";
my $fichierLog = "$RESULTS_LOG";
open Fout, ">$fichierLog" or die "impossible d'ouvrir le fichier de sortie $fichierLog \n";


# Initialisation des paramˆtres via le fichier de configuration tcpdump2Aladdin.cfg
if(-f $Config_File){
  print "Config file = $Config_File\n";
  open Fin, "<$Config_File" or die "Impossible ouvrir $Config_File\n";
  while(<Fin>){
    my $line  =  $_ ;
    chomp $line;
    $TCPDumpDir = $1 if($line =~ /TCPDumpDir=(\S*)/);
    $TCPDumpFile = $1 if($line =~ /TCPDumpFile=(\S*)/);
    $OutputDir = $1 if($line =~ /OutputDir=(\S*)/);
    $OutputFile = $1 if($line =~ /OutputFile=(\S*)/);
    $FIMFOM_IP_Address = $1 if($line =~ /FIMFOM_IP_Address=(\S*)/);
    $FIMFOM_TCP_Port = $1 if($line =~ /FIMFOM_TCP_Port=(\S*)/);
    $FIMFOMTECH_IP_Address = $1 if($line =~ /FIMFOMTECH_IP_Address=(\S*)/);
    $FIMFOMTECH_TCP_Port = $1 if($line =~ /FIMFOMTECH_TCP_Port=(\S*)/);
    $XHD_IP_Address = $1 if($line =~ /XHD_IP_Address=(\S*)/);
    $XHD_TCP_Port = $1 if($line =~ /XHD_TCP_Port=(\S*)/);
    $SIMPLE_IP_Address = $1 if($line =~ /SIMPLE_IP_Address=(\S*)/);
    $SIMPLE_TCP_Port = $1 if($line =~ /SIMPLE_TCP_Port=(\S*)/);
    $C4_SEND_IP_Address = $1 if($line =~ /C4_SEND_IP_Address=(\S*)/);
    $C4_SEND_UDP_Port = $1 if($line =~ /C4_SEND_UDP_Port=(\S*)/);
    $C4_RECEIVE_IP_Address = $1 if($line =~ /C4_RECEIVE_IP_Address=(\S*)/);
    $C4_RECEIVE_UDP_Port = $1 if($line =~ /C4_RECEIVE_UDP_Port=(\S*)/);
    $SLP_SERVER_IP_Address = $1 if($line =~ /SLP_SERVER_IP_Address=(\S*)/);
    $SLP_SERVER_TCP_Port = $1 if($line =~ /SLP_SERVER_TCP_Port=(\S*)/);
    $origin_seconds = $1 if($line =~ /Origin_Seconds=(\S*)/);
    $origin_milli = $1 if($line =~ /Origin_Milli=(\S*)/);
    $processFIMFOM= $1 if($line =~ /processFIMFOM=(\S*)/);
    $processXHDXDH= $1 if($line =~ /processXHDXDH=(\S*)/);
    $processSIMPLE= $1 if($line =~ /processSIMPLE=(\S*)/);
    $processSLP= $1 if($line =~ /processSLP=(\S*)/);
    $processC4TX= $1 if($line =~ /processC4TX=(\S*)/);
    $processC4RX= $1 if($line =~ /processC4RX=(\S*)/);
  }
  close Fin;
  if($debug == 1){
  print "$1\n";
      print " TCPDumpDir=$TCPDumpDir\n";
      print " TCPDumpFile=$TCPDumpFile\n";
  }
}



if( my $opt_h){
	print "tcpdump2Aladdin.pl [-h] [-c test configuration] [-v version] [-t test name]\n";
	print "convertit un fichier tcpdump en fichier Aladdin...\n";
	print
	exit -1;
}

my $mw = MainWindow->new;
$mw->title("$0");

my $Vframe1 = $mw->Frame->pack(-pady => 1);
$Vframe1->Label(-text => "tcpdump2Aladdin.pl [-h] convertit un fichier tcpdump en fichiers Aladdin...\n")->pack(-side => 'left');
my $Vframe12 = $mw->Frame->pack(-pady => 5);
$Vframe12->Label(-text => "Input directory : ", -width => 20)->pack(-side=>'left');
$Vframe12->Entry(-textvariable => \$TCPDumpDir, -width => 35, -borderwidth => 2)->pack(-side =>'left');
$Vframe12->Label(-text => 'TCPDump file : ', -width => 20)->pack(-side=>'left');
$Vframe12->Entry(-textvariable => \$TCPDumpFile, -width => 35, -borderwidth => 2)->pack(-side =>'left',	-padx => '10');
my $Vframe13 = $mw->Frame->pack(-pady => 0);
$Vframe13->Label(-text => "Output directory : ", -width => 20)->pack(-side=>'left');
$Vframe13->Entry(-textvariable => \$OutputDir, -width => 35, -borderwidth => 2)->pack(-side =>'left');
$Vframe13->Label(-text => 'Output file : ', -width => 20)->pack(-side=>'left');
$Vframe13->Entry(-textvariable => \$OutputFile, -width => 35, -borderwidth => 2)->pack(-side =>'left',	-padx => '10');


my $Vframe2 = $mw->Frame->pack(-pady => 1);
$Vframe2->Checkbutton( -variable => \$processFIMFOM, -command => \&radiobuttonproceed, -width => 5)->pack(-side=>'left', -padx => '5');
$Vframe2->Label(-text => "FIM/FOM  (server side) IP Address : ",  -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe2->Entry(-textvariable => \$FIMFOM_IP_Address, -borderwidth => 2, -width => 15)->pack(-side =>'left', -padx => '5');
$Vframe2->Label(-text => 'TCP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe2->Entry(-textvariable => \$FIMFOM_TCP_Port, -borderwidth => 2,-width => 10)->pack(-side =>'left', -padx => '10');

my $Vframe3 = $mw->Frame->pack(-pady => 1);
$Vframe3->Checkbutton( -variable => \$processXHDXDH, -command => \&radiobuttonproceed, -width => 5)->pack(-side=>'left', -padx => '5');
$Vframe3->Label(-text => "XHD/XDH (server side) IP Address : ", -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe3->Entry(-textvariable => \$XHD_IP_Address, -borderwidth => 2, -width => 15)->pack(-side =>'left', -padx => '5');
$Vframe3->Label(-text => 'TCP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe3->Entry(-textvariable => \$XHD_TCP_Port, -borderwidth => 2, -width => 10)->pack(-side =>'left', -padx => '10');

my $Vframe4 = $mw->Frame->pack(-pady => 1);
$Vframe4->Checkbutton( -variable => \$processSIMPLE, -command => \&radiobuttonproceed, -width => 5 )->pack(-side=>'left', -padx => '5');
$Vframe4->Label(-text => "SIMPLE (server side) IP Address : ", -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe4->Entry(-textvariable => \$SIMPLE_IP_Address, -borderwidth => 2, -width => 15)->pack(-side =>'left', -padx => '5');
$Vframe4->Label(-text => 'TCP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe4->Entry(-textvariable => \$SIMPLE_TCP_Port, -borderwidth => 2, -width => 10)->pack(-side =>'left', -padx => '10');

my $Vframe5 = $mw->Frame->pack(-pady => 1);
$Vframe5->Checkbutton( -variable => \$processC4TX, -command => \&radiobuttonproceed, -width => 5)->pack(-side=>'left', -padx => '5');
$Vframe5->Label(-text => "C4 SEND IP Address : ", -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe5->Entry(-textvariable => \$C4_SEND_IP_Address, -width => 15, -borderwidth => 2)->pack(-side =>'left', -padx => '5');
$Vframe5->Label(-text => 'UDP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe5->Entry(-textvariable => \$C4_SEND_UDP_Port, -width => 10, -borderwidth => 2)->pack(-side =>'left', -padx => '10');

my $Vframe6 = $mw->Frame->pack(-pady => 1);
$Vframe6->Checkbutton( -variable => \$processC4RX, -command => \&radiobuttonproceed, -width => 5)->pack(-side=>'left', -padx => '5');
$Vframe6->Label(-text => "C4 RECEIVE IP Address : ", -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe6->Entry(-textvariable => \$C4_RECEIVE_IP_Address, -width => 15, -borderwidth => 2)->pack(-side =>'left', -padx => '5');
$Vframe6->Label(-text => 'UDP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe6->Entry(-textvariable => \$C4_RECEIVE_UDP_Port, -width => 10, -borderwidth => 2)->pack(-side =>'left', -padx => '10');

my $Vframe7 = $mw->Frame->pack(-pady => 1);
$Vframe7->Checkbutton( -variable => \$processSLP, -command => \&radiobuttonproceed, -width => 5)->pack(-side=>'left', -padx => '5');
$Vframe7->Label(-text => "SLP server IP Address : ", -width => 35)->pack(-side=>'left', -padx => '5');
$Vframe7->Entry(-textvariable => \$SLP_SERVER_IP_Address, -width => 15, -borderwidth => 2)->pack(-side =>'left', -padx => '5');
$Vframe7->Label(-text => 'TCP Port : ', -width => 10)->pack(-side=>'left', -padx => '5');
$Vframe7->Entry(-textvariable => \$SLP_SERVER_TCP_Port, -width => 10, -borderwidth => 2)->pack(-side =>'left', -padx => '10');

my $Vframe4 = $mw->Frame->pack;
my $ButtonExtract=$Vframe4->Button(-text=>'Extract', -state => 'active', -command => \&extract2Aladdin, -width => 10)->pack(-side => 'left', -pady => 5, -padx => 5);
my $ButtonSave=$Vframe4->Button(-text=>'Save config', -state => 'active', -command => \&saveConfig, -width => 10)->pack(-side => 'left', -pady => 5, -padx => 5);
MainLoop;

sub saveConfig{
    system("copy $Config_File $Config_File.old");
    system("del $Config_File");
    print "$Config_File";
    open Fout, ">$Config_File" or die "Impossible ouvrir $Config_File\n";
    print Fout "TCPDumpDir=$TCPDumpDir\n";
    print Fout "TCPDumpFile=$TCPDumpFile\n";
    print Fout "OutputDir=$OutputDir\n";
    print Fout "OutputFile=$OutputFile\n";
    print Fout "FIMFOM_IP_Address=$FIMFOM_IP_Address\n";
    print Fout "FIMFOM_TCP_Port=$FIMFOM_TCP_Port\n";
    print Fout "FIMFOMTECH_IP_Address=$FIMFOMTECH_IP_Address\n";
    print Fout "FIMFOMTECH_TCP_Port=$FIMFOMTECH_TCP_Port\n";
    print Fout "XHD_IP_Address=$XHD_IP_Address\n";
    print Fout "XHD_TCP_Port=$XHD_TCP_Port\n";
    print Fout "SIMPLE_IP_Address=$SIMPLE_IP_Address\n";
    print Fout "SIMPLE_TCP_Port=$SIMPLE_TCP_Port\n";
    print Fout "C4_SEND_IP_Address=$C4_SEND_IP_Address\n";
    print Fout "C4_SEND_UDP_Port=$C4_SEND_UDP_Port\n";
    print Fout "C4_RECEIVE_IP_Address=$C4_RECEIVE_IP_Address\n";
    print Fout "C4_RECEIVE_UDP_Port=$C4_RECEIVE_UDP_Port\n";
    print Fout "SLP_SERVER_IP_Address=$SLP_SERVER_IP_Address\n";
    print Fout "SLP_SERVER_TCP_Port=$SLP_SERVER_TCP_Port\n";
    print Fout "Origin_Seconds=$origin_seconds\n";
    print Fout "Origin_Milli=$origin_milli\n";
    print Fout "processFIMFOM=$processFIMFOM\n";
    print Fout "processXHDXDH=$processXHDXDH\n";
    print Fout "processSIMPLE=$processSIMPLE\n";
    print Fout "processSLP=$processSLP\n";
    print Fout "processC4TX=$processC4TX\n";
    print Fout "processC4RX=$processC4RX\n";
    close Fout;
    return 0;
}

sub radiobuttonproceed {
    # print "$titi ";
    #$toto->deselect;

    #print "FIMFOM = $titi \n";
    #print "Tk:selectedButton\n";
    return 0;
}

sub extract2Aladdin {
    if(! -f "$TCPDumpDir$TCPDumpFile"){
      print "$TCPDumpDir$TCPDumpFile does not exist !\n";
      exit -1;
    }
    
    #$OutputDir = qw("$OutputDir");
    #$OutputFile = qw("$OutputFile");
	open FoutFIM, ">$OutputDir$OutputFile.fim" or die "Impossible ouvrir test.fim" if($processFIMFOM);
	open FoutFOM, ">$OutputDir$OutputFile.fom" or die "Impossible ouvrir test.fom" if($processFIMFOM);
	open FoutFIMTECH, ">$OutputDir$OutputFile.tech.fim" or die "Impossible ouvrir $OutputDir$OutputFile.tech.fim" if($processFIMFOM);
	open FoutFOMTECH, ">$OutputDir$OutputFile.tech.fom" or die "Impossible ouvrir $OutputDir$OutputFile.tech.fom" if($processFIMFOM);
	open FoutXHD, ">$OutputDir$OutputFile.xhd" or die "Impossible ouvrir test.xhd" if($processXHDXDH);
	open FoutXDH, ">$OutputDir$OutputFile.xdh" or die "Impossible ouvrir test.xdh" if($processXHDXDH);
	open FinSIMPLE, ">$OutputDir$OutputFile.so" or die "Impossible ouvrir test.so" if($processSIMPLE);
	open FoutSIMPLE, ">$OutputDir$OutputFile.si" or die "Impossible ouvrir test.si" if($processSIMPLE);
	open FoutSIMPLEFIM, ">$OutputDir$OutputFile.SIMPLE.fim" or die "Impossible ouvrir test.SIMPLE.fim" if($processSIMPLE);
	open FoutSIMPLEFOM, ">$OutputDir$OutputFile.SIMPLE.fom" or die "Impossible ouvrir test.SIMPLE.fom" if($processSIMPLE);
	open FoutSIMPLEJI, ">$OutputDir$OutputFile.SIMPLE.ji" or die "Impossible ouvrir ..." if($processSIMPLE);
	open FoutC4_SEND, ">$OutputDir$OutputFile.C4.xdh" or die "Impossible ouvrir test_C4.xdh" if($processC4RX);
	open FoutC4_RECEIVE, ">$OutputDir$OutputFile.C4.xhd" or die "Impossible ouvrir test_C4.xhd" if($processC4TX);
	open FoutSLP, ">$OutputDir$OutputFile.SLP.ind_rep_apu" or die "Impossible ouvrir ind_rep_apu" if($processSLP);
	open FoutTI, ">$OutputDir$OutputFile.TI.dem_apu" or die "Impossible ouvrir dem_apu" if($processSLP);
	my $log = Net::TcpDumpLog->new(32);	# force 32-bits to match this file
	$log->read("$TCPDumpDir$TCPDumpFile");

	my ($length_orig,$length_incl,$drops,$secs,$msecs) = $log->header(0);
	$origin_seconds = $secs;
	$origin_milli = $msecs;

	my @Indexes = $log->indexes;

	my $etatLectureXDH = 0;
	# $etatLectureXDH definit l'‰tat de lecture du message XDH octet par octet modif Meltem
	# = 0 : 1er octet de synchro trame non lu
	# = 1 : 1ˆme octet de synchro trame lu
	# = 2 : 2ˆme octet de synchro trame lu
	# = 3 : 1er octet de longueur lu
	# = 4 : 2ˆme octet de longueur lu
	my $XDH_msg = "";
	my $XDH_length = 0;
	my $XDH_current_length = 0;
	my $XDH_length_in_char;
	
	my $etatLectureSIMPLE = 0;
	# $etatLectureSIMPLE definit l'‰tat de lecture du message SIMPLE octet par octet modif SNCP TD
	# = 0 : 1er octet de synchro trame non lu
	# = 1 : 1ˆme octet de synchro trame lu
	# = 2 : 2ˆme octet de synchro trame lu
	# = 3 : 1er octet de longueur lu
	# = 4 : 2ˆme octet de longueur lu
	my $SIMPLE_msg = "";
	my $SIMPLE_length = 0;
#	my $SIMPLE_current_length = 0;
#	my $SIMPLE_length_in_char;

    my $etatLectureSIMPLEFIM = 0;
	# $etatLectureSIMPLE definit l'‰tat de lecture du message SIMPLE octet par octet modif SNCP TD
	# = 0 : 1er octet de synchro trame non lu
	# = 1 : 1ˆme octet de synchro trame lu
	# = 2 : 2ˆme octet de synchro trame lu
	# = 3 : 1er octet de longueur lu
	# = 4 : 2ˆme octet de longueur lu
	my $SIMPLEFIM_msg = "";
	my $SIMPLEFIM_length = 0;
#	my $SIMPLEFIM_current_length = 0;
#	my $SIMPLEFIM_length_in_char;

	my $new_XHD= 1;
        my $XHD = "";
        my $XHD_length_in_char;
	my $XHD_current_length = 0;

	my $new_C4_SEND = 1;
	my $new_C4_RECEIVE= 1;
	my $C4_SEND = "";
	my $C4_RECEIVE = "";
	my $C4_SEND_current_length = 0;
	my $C4_RECEIVE_current_length = 0;
	my $C4_SEND_length_in_char;
	my $C4_RECEIVE_length_in_char;

	my $etat_slp_msg = 0;
	my $slp_msg;

	# Creation du fichier SIMPLE.conf
	if($processSIMPLE){
	                   open fout, ">$OutputDir$OutputFile.SIMPLE.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n" ;
	                   #print fout "Host_Input_File=$OutputDir$OutputFile.xhd\n";
	                   #print fout "Host_Output_File=$OutputDir$OutputFile.xdh\n";
	                   print fout "Simple_Output_File = $OutputDir$OutputFile.so\n";
	                   print fout "Simple_Input_File = $OutputDir$OutputFile.si\n";
	                   close fout;
	}

	# Creation du fichier FXM.conf
	if($processFIMFOM){
	                   open fout, ">$OutputDir$OutputFile.FXM.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	                   print fout "Link_Output_File_1 = $OutputDir$OutputFile.fom\n";
	                   print fout "Link_Input_File_1 = $OutputDir$OutputFile.fim\n";
	                   close fout;
	}

		# Creation du fichier XHD.conf
    if($processXHDXDH){
	                   open fout, ">$OutputDir$OutputFile.XHD.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	                   print fout "Host_Output_File_1 = $OutputDir$OutputFile.xdh\n";
	                   print fout "Host_Input_File_1 = $OutputDir$OutputFile.xhd\n";
	                   print fout "Host_Output_File_2 = $OutputDir$OutputFile.C4.xdh\n";
	                   print fout "Host_Input_File_2 = $OutputDir$OutputFile.C4.xhd\n";
	                   close fout;
    }
	
	foreach my $num  (0..$#Indexes){
		#retrieve for each tcpdump record header data
		my ($length_orig,$length_incl,$drops,$secs_2,$msecs_2) = $log->header($num);
		#print "$secs_2,$msecs_2\n";
		my $zoneoffset = $log->zoneoffset();
		my $data = $log->data($num);
		my ($ether_dest,$ether_src,$ether_type,$ether_data) = getEtherParam(\$data);
		my $length = length($data);
		#print "$ether_dest,$ether_src,$ether_type,$ether_data\n";
		# si le paquet ethernet est un paquet IP	
		if( hex($ether_type) == 0x800) { 
			#print "$secs_2.$msecs_2\n";
			my ($secs, $msecs) = toRelative($secs_2, $msecs_2);
			my $chrono = toChrono($secs, $msecs);
			my ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = getIPParam(\$ether_data);
			# Traitement protocole TCP
			if( hex($ip_proto) == 6) {
				$ip_total_length = hex($ip_total_length);
				my $ip_src = hexa2IPAddress($ip_src1, $ip_src2, $ip_src3, $ip_src4);
				my $ip_dest = hexa2IPAddress($ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4);
				my ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length) = getTCPParam(\$ip_data);
				$tcp_port_src = hex($tcp_port_src);
				$tcp_port_dest = hex($tcp_port_dest);
				# TCP header length is contained in the 6 left bits of the byte !
				$tcp_head_length = int(hex($tcp_head_length)/16)*4;
				#print "tcp header lentgh, src port, dest port : $tcp_head_length, $tcp_port_src, $tcp_port_dest\n";
				my $length_tcp_head_in_char = $tcp_head_length*2;
				# Assuming ip header length is always 20, to withdraw trailing data
				my $data_length_in_char = ($ip_total_length - 20 - $tcp_head_length)*2;
				if ($data_length_in_char != 0) {
					my ($tcp_header, $tcp_data) = unpack ("H${length_tcp_head_in_char}H${data_length_in_char}", $ip_data);
					#print "tcp header  : $tcp_header\n";
					print "tcp data    : $tcp_data\n" if ((length($ip_data) > $tcp_head_length)&& $debug == 7);
					print "$ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port\n" if ($debug == 7);
                    #$tcp_data reprsente la trame sous forme hexadecimal : 1 octet est represente par 2 caracteres hexa
                    # $data_length_in_char est le double de $data_length_in_byte (1 byte = 2 char)
                    my $data_length_in_byte = int($data_length_in_char/2);
					# Traitement des flux XDH



		    # J-P. Coron, le 20 octobre 2009 - Debut modification
                    #if($ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port){

                    my @tab_ip_src = split (/\./,$ip_src);
		    
                    my @tab_XHD_IP_Address = split (/\./,$XHD_IP_Address);
                    if ($ip_src == $XHD_IP_Address && $tcp_port_src == $XHD_TCP_Port) {
                    # J-P. Coron, le 20 octobre 2009 - Fin modification
                      for my $i (0..$data_length_in_byte-1) {
                        # traitement 2 char par 2 char
                        my $char = substr($tcp_data, $i*2, 2);
                        print "$char, $i, $data_length_in_char\n" if($debug == 7);
                        # recherche du premier octet de synchro
                          if($etatLectureXDH == 0) {
                            if($char =~/44/){
                              $etatLectureXDH = 1;
                              #$XDH_msg = $char;
                              print "passage a l'etat 1\n" if($debug == 7);
                              #print "$XDH_msg\n" if($debug == 7);
                              #<> if($debug == 7);
                            }
                            next;
                          }
                          # recherche du 2ˆme octet de synchro trame
                          if($etatLectureXDH == 1) {
                            if($char =~ /48/) {
                              #$XDH_msg .= $char;
                              $etatLectureXDH = 2;
                              print "passage a l'etat 2\n" if($debug == 7);
                              print "$XDH_msg\n" if($debug == 7);
                              #<> if($debug == 7);
                            }
                            else {
                              $XDH_msg = "";
                              $etatLectureXDH = 0;
                              print "retour a l'etat 0\n" if($debug == 7);
                            }
                            next;
                          }
                          # recherche du 1er octet de longueur
                          if($etatLectureXDH == 2) {
                            $XDH_length = $char;
							$XDH_msg = $char;
                            $etatLectureXDH = 3;
                            print "passage a l'etat 3 \n" if($debug == 7);
                            print "XDH_Length (1st byte): $XDH_length\n" if($debug == 7);
                            next;
                          }
                          # recherche du 2eme octet de longueur
                          if($etatLectureXDH == 3) {
                            $XDH_length .= $char;
							$XDH_msg .= $char;
                            $XDH_length = hex($XDH_length);
                            $etatLectureXDH = 4;
                            print "passage a l'etat 4 \n" if($debug == 7);
                            print "XDH_length (1st and 2nd byte): $XDH_length \n" if($debug == 7);
                            next;
                          }
                          if($etatLectureXDH == 4) {
                            $XDH_msg .= $char;
							my $calc_length=length($XDH_msg);
                            #print "$XDH_length\n";
				    if($calc_length == ($XDH_length*2)+4) {
				      $XDH_msg =~s/^(.{4})(..)(.{6})/0000$1 01$3/;
				      $XDH_msg =~ s/\s//g;
				      $XDH_msg =~ s/(....)/$1 /g;
				      $XDH_msg =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
				      #	conversion minuscules en majuscules
				      $XDH_msg = uc($XDH_msg);
				      my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
				      print FoutXDH "$heure:$minute:$seconde.$milli $XDH_msg\n";
				      $etatLectureXDH = 0;
				      $XDH_msg = "";
				    }
                            print "etat 4 \n" if($debug == 7);
                            print "XDH_Msg: $XDH_msg \n" if($debug == 7);
			    print "XDH_Length: $XDH_length \n" if($debug == 7);
			    print "Length of XDH_Msg: $calc_length \n" if($debug == 7);
                            next;
                          }
		      }
                      print "sortie analyse trame\n" if($debug == 7);
                      <> if($debug == 7);
                    }   
			# Le paquet TCP est un XHD
					print "$ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port\n" if ($debug == 5);
					if($ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port){
						#print "XHD:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						# Si le paquet est le debut d'un message
						if($tcp_data =~/^4844(....)/ && $new_XHD == 1){
							#print "new XDH\n";
							$XHD=$tcp_data;
							$XHD_length_in_char = (hex($1)+4)*2;
							print "new XHD length in char = $XHD_length_in_char\n" if($debug == 5);
							<> if($debug == 5);
							#print "XDH:$XDH\n";
						}
						# Si le message est la continuation d'un message
						else{
							$XHD=$XHD.$tcp_data;
							#print "XDH:$XDH\n";
						}
						$XHD_current_length = length($XHD);
						if($XHD_current_length == $XHD_length_in_char){
							$new_XHD = 1;
							$XHD=substr($XHD, 4, $XHD_length_in_char-4);
							#print "$XHD\n";
							$XHD =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							$XHD =~ s/\s//g;
							$XHD =~ s/(....)/$1 /g;
							$XHD =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
							# conversion minuscules en majuscules
							$XHD = uc($XHD);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutXHD "$heure:$minute:$seconde.$milli $XHD\n";
							print "$heure:$minute:$seconde.$milli $XHD\n" if($debug == 5);
							#<> if($debug == 5);
						}
					}
					# Le paquet TCP est un paquet SIMPLE entrant cote serveur  (FIM)
					print "SIMPLEFIM $ip_src eq $SIMPLE_IP_Address && $tcp_port_src eq $SIMPLE_TCP_Port\n" if ($debug == 8);
					if($ip_src eq $SIMPLE_IP_Address && $tcp_port_src eq $SIMPLE_TCP_Port) {
						for my $i (0..$data_length_in_byte-1){
                            # traitement 2 char par 2 char
                            my $char = substr($tcp_data, $i*2, 2);
                            print "$char, $i, $data_length_in_char\n" if($debug == 8);
                            # recherche du premier octet de synchro
                            if($etatLectureSIMPLEFIM == 0) {
                                                     if($char =~/49/){
                                                              $SIMPLEFIM_msg .= $char;
                                                              print " etatlecture = 1\n" if($debug == 8);
                                                              $etatLectureSIMPLEFIM = 1;
                                                     }
                                                     next;
                            }
                            # recherche du 2ˆme octet de synchro trame
                            if($etatLectureSIMPLEFIM == 1) {
                                                     if($char =~ /36/){
                                                              $SIMPLEFIM_msg .= $char;
                                                              $etatLectureSIMPLEFIM = 2;
                                                              print "passage a l'etat 2\n" if($debug == 8);
                                                              print "$SIMPLEFIM_msg\n" if($debug == 8);
                                                              #<> if($debug == 8);
                                                     }
                                                     else {
                                                          $SIMPLEFIM_msg = "";
                                                          $etatLectureSIMPLEFIM = 0;
                                                          print "FIM retour a l'etat 0\n" if($debug == 8);
                                                     }
                                                     next;
                          }
                          # recherche du 1er octet de longueur
                          if($etatLectureSIMPLEFIM == 2) {
                            $SIMPLEFIM_length = $char;
                            $SIMPLEFIM_length = hex($SIMPLEFIM_length);
                            $SIMPLEFIM_msg .= $char;
                            $etatLectureSIMPLEFIM = 4;
                            print "passage a l'etat 4 \n" if($debug == 8);
                            print "$SIMPLEFIM_msg\n" if($debug == 8);
                            print "SIMPLEFIM_length = $SIMPLEFIM_length \n" if($debug == 8);
                            next;
                          }
                          if($etatLectureSIMPLEFIM == 4) {
                            $SIMPLEFIM_msg .= $char;
                            print "etat 4 $SIMPLEFIM_length\n";
                            if(length($SIMPLEFIM_msg) == ($SIMPLEFIM_length*2)){
                              #$SIMPLE_msg =~s/^(.{4})(..)(.{6})/0000$1 01$3/;
						      #$SIMPLE_msg =~ s/\s//g;
						      #$SIMPLE_msg =~ s/(....)/$1 /g;
						      #$SIMPLE_msg =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
						      #	conversion minuscules en majuscules
						      $SIMPLEFIM_msg = uc($SIMPLEFIM_msg);
						      my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
						      print "Msg : $chrono, $SIMPLEFIM_msg \n" if($debug == 8);
							  #Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
							  my $FIM = decodeSIMPLEFIM($SIMPLEFIM_msg);
							  $FIM = uc ($FIM);
							  print "FIM : $FIM" if($debug == 8);

							  if($FIM != 0){
                                      #print "print FIM \n";
							          print FoutSIMPLEFIM "$heure:$minute:$seconde.$milli $FIM" ;
                              }
                              else {
									print FoutSIMPLE "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLEFIM_msg";
                              }
                              print "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLEFIM_msg" if($debug == 8);
						      print FoutSIMPLE "$heure:$minute:$seconde.$milli $SIMPLEFIM_msg\n";
                              $etatLectureSIMPLEFIM = 0;
                              $SIMPLEFIM_msg = "";
                            }
                            #print "etat 4 \n" if($debug == 6);
                            print "$SIMPLEFIM_msg \n" if($debug == 8);
                            next;
                          }
                        }
                        #print "sortie analyse trame\n";
                        #<> if($debug == 8);
            }

 # Le paquet TCP est un paquet SIMPLE entrant cote serveur  (FOM)
					print "$ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port\n" if ($debug == 6);
					if(($ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port)) {
  						for my $i (0..$data_length_in_byte-1){
                            # traitement 2 char par 2 char
                            my $char = substr($tcp_data, $i*2, 2);
                            print "$char, $i, $data_length_in_char\n" if($debug == 6);
                            # recherche du premier octet de synchro
                            if($etatLectureSIMPLE == 0) {
                                                  if($char =~/49/){
                                                           $SIMPLE_msg .= $char;
                                                           print " etatlecture = 1\n" if($debug == 6);
                                                           $etatLectureSIMPLE = 1;
                                                  }
                                                  next;
                            }
                            # recherche du 2ˆme octet de synchro trame
                            if($etatLectureSIMPLE == 1) {
                                                  if($char =~ /36/){
                                                           $SIMPLE_msg .= $char;
                                                           $etatLectureSIMPLE = 2;
                                                           print "passage a l'etat 2\n" if($debug == 6);
                                                           print "$SIMPLE_msg\n" if($debug == 6);
                                                           #<> if($debug == 6);
                                                  }
                                                  else {
                                                           $SIMPLE_msg = "";
                                                           $etatLectureSIMPLE = 0;
                                                           print "retour a l'etat 0\n" if($debug == 6);
                                                  }
                                                  next;
                          }
                          # recherche du 1er octet de longueur
                          if($etatLectureSIMPLE == 2) {
                            $SIMPLE_length = $char;
                            $SIMPLE_length = hex($SIMPLE_length);
                            $SIMPLE_msg .= $char;
                            $etatLectureSIMPLE = 4;
                            print "passage a l'etat 4 \n" if($debug == 6);
                            print "$SIMPLE_msg\n" if($debug == 6);
                            print "SIMPLE_length = $SIMPLE_length \n" if($debug == 6);
                            next;
                          }
                          # recherche du 2eme octet de longueur
                          if($etatLectureSIMPLE == 3) {
                            $SIMPLE_length .= $char;
                            $SIMPLE_length = hex($SIMPLE_length);
                            $SIMPLE_msg .= $char;
                            $etatLectureSIMPLE = 4;
                            print "passage a l'etat 4 \n" if($debug == 6);
                            print "$SIMPLE_msg \n" if($debug == 6);
                            print "SIMPLE_length = $SIMPLE_length \n" if($debug == 6);
                            next;
                          }
                          if($etatLectureSIMPLE == 4) {
                            $SIMPLE_msg .= $char;
                            #print "$XDH_length\n";
                            if(length($SIMPLE_msg) == ($SIMPLE_length*2)){
                              #$SIMPLE_msg =~s/^(.{4})(..)(.{6})/0000$1 01$3/;
						      #$SIMPLE_msg =~ s/\s//g;
						      #$SIMPLE_msg =~ s/(....)/$1 /g;
						      #$SIMPLE_msg =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
						      #	conversion minuscules en majuscules
						      $SIMPLE_msg = uc($SIMPLE_msg);
						      my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
						      print "Msg : $chrono, $SIMPLE_msg \n";
						      #<>;
							  #Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
							  my $FOM = decodeSIMPLEFOM($SIMPLE_msg);
							  $FOM = uc ($FOM);
							  print "FOM : $FOM" if($debug == 6);

							  if($FOM != 0){
                                      #print "print FIM \n";
							          print FoutSIMPLEFOM "$heure:$minute:$seconde.$milli $FOM" ;
                              }
                              else {
									print FoutSIMPLE "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE_msg";
                              }
                              print "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE_msg" if($debug == 6);
						      print FoutSIMPLE "$heure:$minute:$seconde.$milli $SIMPLE_msg\n";
                              $etatLectureSIMPLE = 0;
                              $SIMPLE_msg = "";
                            }
                            #print "etat 4 \n" if($debug == 6);
                            print "$SIMPLE_msg \n" if($debug == 6);
                            next;
                          }
                        }
                        #print "sortie analyse trame\n";
                        #<> if($debug == 6);
                    }
		    # Le paquet est un fom
		    if($ip_src eq $FIMFOM_IP_Address && $tcp_port_src eq $FIMFOM_TCP_Port){
		      my $length = length($tcp_data); # length of hexa string : 2 for 1 octet
		      while ($length > 0){
			print " $tcp_data\n" if ($debug == 9);
			print "length data = $length\n" if ($debug == 9);
			print "this is a F0M : $tcp_data\n" if ($debug == 9);
			my $FOMlength = fxmLength(\$tcp_data);
			# FOMlength is the nber of 16bit word without the BIM/BOM word
			# FOMlength_in_car is the nber of hexa char in the FOM
			my $FOMlength_in_car = $FOMlength*4+4;
			my $fom = substr($tcp_data, 0, $FOMlength_in_car);
			print "new fom: $fom length : $FOMlength_in_car\n" if ($debug == 9);
			$length = $length - ($FOMlength_in_car);
			if($length > 0){
			    $tcp_data = substr($tcp_data, $FOMlength_in_car, $length);
			    print "new tcp_data : $tcp_data new length : $length\n"  if ($debug == 9);
			}
			if (isFxm01($fom)){
			  my $fom = fom2Aladdin($chrono, $fom);
			  print "fom01 : $fom \n"  if ($debug == 9);
			  print FoutFOM "$fom\n";
			}
			else {
			  my $fom = fomtech2Aladdin($chrono, $fom);
			  if( length($fom) > 2){
			    print FoutFOMTECH "$fom\n" ;
			    print "fom tech : $fom\n" if ($debug == 9);
			  }
			}
		      }
		      print "FOM:$secs.$msecs:$tcp_data\n"  if ($debug == 9);
		      print "Destination : $ip_dest\t$tcp_port_dest\n\n\n"  if ($debug == 9);
		      #<> if($debug == 9);
		    }
		    # Le paquet est un fim
		    if($ip_dest eq $FIMFOM_IP_Address && $tcp_port_dest eq $FIMFOM_TCP_Port){
		      print "FIM:$secs.$msecs:$tcp_data\n" if( $debug == 9);
		      print "Source :      $ip_src\t$tcp_port_src\n" if( $debug == 9);
		      print "Destination : $ip_dest\t$tcp_port_dest\n" if( $debug == 9);
		      # Decoupe du message en fim elementaire
		      my $length = length($tcp_data);
		      while ($length > 0){
			print " $tcp_data\n" if ($debug == 9);
			print "length data = $length\n" if ($debug == 9);
			print "this is a FIM : $tcp_data\n" if ($debug == 9);
			  my $FIMlength = fxmLength(\$tcp_data);
			  # FIMlength is the nber of 16bit word without the BIM/BOM word
			  # FIMlength_in_car is the nber of hexa char in the FIM
			  my $FIMlength_in_car = $FIMlength*4+4;
			  my $fim = substr($tcp_data, 0, $FIMlength_in_car);
			  print "new fim : $fim length : $FIMlength_in_car\n" if ($debug == 9);
			  $length = $length - ($FIMlength_in_car);
			  if($length > 0){
			    $tcp_data = substr($tcp_data, $FIMlength_in_car, $length);
			    print "new tcp_data : $tcp_data new length : $length\n"  if ($debug == 9);
			  }
			  if (isFxm01($fim)){
			  	my $fim = fim2Aladdin($chrono, $fim);
			  	print "fim : $fim \n"  if ($debug == 9);
			  	print FoutFIM "$fim\n";
			  }
			else {
			  my $fim = fimtech2Aladdin($chrono, $fim);
			  if( length($fim) > 2){
			  	print FoutFIMTECH "$fim\n" ;
			  	print "fim tech : $fim\n" if ($debug == 9);
			  }
			}
		      }
		      #<> if($debug == 9);
		    }
		    # Le paquet est un fom technique  sur la liaison discrets FOM62
		    if($ip_src eq $FIMFOMTECH_IP_Address && $tcp_port_src eq $FIMFOMTECH_TCP_Port){
		      #print "FOM:$secs.$msecs:$tcp_data\n";
		      ##print "Source :      $ip_src\t$tcp_port_src\n";
		      ##print "Destination : $ip_dest\t$tcp_port_dest\n";
		      my $fom = fomtech2Aladdin($chrono, $tcp_data);
		      print FoutFOMTECH "$fom\n" if( length($fom) > 2);
		      print "fom tech 2 : $fom\n";
		    }
		    # Le paquet est un fim technique     sur la liaison discrets    FIM62 FIM63
		    if($ip_dest eq $FIMFOMTECH_IP_Address && $tcp_port_dest eq $FIMFOMTECH_TCP_Port){
		      print "FIM:$secs.$msecs:$tcp_data\n" if( $debug == 9);
		      print "Source :      $ip_src\t$tcp_port_src\n" if( $debug == 9);
		      print "Destination : $ip_dest\t$tcp_port_dest\n" if( $debug == 9);
		      my $fim = fimtech2Aladdin($chrono, $tcp_data);
		      print "$fim\n"  if( $debug == 9);
		      #exit 0;
		      print FoutFIMTECH "$fim\n" if( $fim !~/^-1/);
		      print "fim tech 2 : $fim\n" if( $debug == 9);
		      #close FoutFIMTECH;
		      #exit 0;
		    }
		# Le paquet est un message re‡u de la SLP 
		if($ip_src eq $SLP_SERVER_IP_Address && $tcp_port_src eq $SLP_SERVER_TCP_Port){
						# r‰ception champ par champ 
						if(length($tcp_data)==4 && $etat_slp_msg == 0){
							$etat_slp_msg=1;
							$slp_msg=$tcp_data;
							next;
						}
						if(length($tcp_data)==4 && $etat_slp_msg == 1){
							$etat_slp_msg=2;
							$slp_msg=$slp_msg.$tcp_data;
							next;
						}
						if(length($tcp_data)==4 && $etat_slp_msg == 2 ){
							$etat_slp_msg=3;
							$slp_msg=$slp_msg.$tcp_data;
							next;
						}
						if(length($tcp_data)==8 && $etat_slp_msg == 3){
							$etat_slp_msg=4;
							$slp_msg=$slp_msg.$tcp_data;
							next;
						}
						if($etat_slp_msg == 4){
							$etat_slp_msg=0;
							$slp_msg=$slp_msg.$tcp_data;
							$slp_msg = slp2Aladdin($chrono, $slp_msg);
						}
					
						print FoutSLP "$slp_msg\n";
					}
					if($ip_dest eq $SLP_SERVER_IP_Address && $tcp_port_dest eq $SLP_SERVER_TCP_Port){
						#print "FIM:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						my $ti_msg = ti2Aladdin($chrono, $tcp_data);
						print FoutTI "$ti_msg\n";
					}
				}
			}
			# Traitement protocole UDP
			if( hex($ip_proto) == 17){
				$ip_total_length = hex($ip_total_length);
				my $ip_src = hex($ip_src1).".".hex($ip_src2).".". hex($ip_src3).".". hex($ip_src4);
				my $ip_dest = hex($ip_dest1).".".hex($ip_dest2).".".hex($ip_dest3).".".hex($ip_dest4);
				#print "$ip_data\n";
				#print "ip lentgh, ip src, ip dest  : $ip_total_length, $ip_src, $ip_dest\n";
				my ($udp_port_src, $udp_port_dest, $udp_length, $udp_cksum, $udp_data) = unpack('H4H4H4H4a*', $ip_data);
				$udp_port_src = hex($udp_port_src);
				$udp_port_dest = hex($udp_port_dest);
				#print "udp port src, port dst : $udp_port_src, $udp_port_dest\n";
				my $data_length_in_byte = hex($udp_length) - 8;
				print "udp data length in byte : $data_length_in_byte \n" if($debug == 3);
				if ($data_length_in_byte != 0) {
					my $data_length_in_char = $data_length_in_byte * 2;
					print "$ip_src -> $C4_SEND_IP_Address $udp_port_src -> $C4_SEND_UDP_Port\n"if($debug == 3);
					if($ip_src eq $C4_SEND_IP_Address && $udp_port_src eq $C4_SEND_UDP_Port){
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						#00:04:22.058 0000001D 01000079 0000 0329 0079 0100 2375 C20A 0000 000A 0100 0000 0000 0210 00
						print "C4 SEND : $secs.$msecs:$udp_data\n"if($debug == 3);
						#print "Source :      $ip_src\t$udp_port_src\n";
						#print "Destination : $ip_dest\t$udp_port_dest\n";
						if($udp_data =~/^4448(....)/ && $new_C4_SEND == 1){
							#print "new XDH\n";
							$C4_SEND=$udp_data;
							$C4_SEND_length_in_char = (hex($1)+4)*2;
							print "new C4 SEND length in char = $C4_SEND_length_in_char\n" if($debug == 3);
							<> if($debug == 3);
							#print "C4 SEND:$C4_SEND\n";
							$new_C4_SEND = 0;
						}
						else{
							$C4_SEND=$C4_SEND.$udp_data;
							#print "XDH:$XDH\n";
						}
						$C4_SEND_current_length = length($C4_SEND);
						print "Current length : $C4_SEND_current_length\n" if($debug == 3);
						if($C4_SEND_current_length == $C4_SEND_length_in_char && $new_C4_SEND == 0){
							$new_C4_SEND = 1;
							$C4_SEND=substr($C4_SEND, 4, $C4_SEND_length_in_char-4);
							$C4_SEND =~s/^(.{4})(..)(.{6})/0000$1 01$3 /;
							# conversion minuscules en majuscules
							$C4_SEND = uc($C4_SEND);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_SEND "$heure:$minute:$seconde.$milli $C4_SEND\n";
							print "$heure:$minute:$seconde.$milli $C4_SEND\n" if($debug == 3);
							<> if($debug == 3);
						}	
						# On memorise la longueur du message 
						# 
					}
					print "$ip_dest -> $C4_RECEIVE_IP_Address $udp_port_dest -> $C4_RECEIVE_UDP_Port\n" if ($debug == 2);
					if($ip_src eq $C4_RECEIVE_IP_Address && $udp_port_dest eq $C4_SEND_UDP_Port){
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						print "C4 RECEIVE  :$secs.$msecs:$udp_data\n" if($debug == 2);
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						if($udp_data =~/^4844(....)/ && $new_C4_RECEIVE == 1){
							#print "new C4_RECEIVE\n";
							$C4_RECEIVE=$udp_data;
							$C4_RECEIVE_length_in_char = (hex($1)+4)*2;
							print "new C4 RECEIVE length in char = $C4_RECEIVE_length_in_char\n" if($debug == 2);
							<> if($debug == 2);
							$new_C4_RECEIVE = 0;
							#print "C4 RECEIVE:$C4_RECEIVE\n";
						}
						else{
							$C4_RECEIVE=$C4_RECEIVE.$udp_data;
						}
						$C4_RECEIVE_current_length = length($C4_RECEIVE);
						print "Current length : $C4_RECEIVE_current_length\n" if($debug == 2);
						if($C4_RECEIVE_current_length == $C4_RECEIVE_length_in_char && $new_C4_RECEIVE == 0 ){
							$new_C4_RECEIVE = 1;
							$C4_RECEIVE=substr($C4_RECEIVE, 4, $C4_RECEIVE_length_in_char-4);
							$C4_RECEIVE =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							# conversion minuscules en majuscules
							$C4_RECEIVE = uc($C4_RECEIVE);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_RECEIVE "$heure:$minute:$seconde.$milli $C4_RECEIVE\n";
							print "$heure:$minute:$seconde.$milli $C4_RECEIVE\n" if($debug == 2);
							<> if($debug == 2);
						}
					}
				}
			}
		}

	}
	close FoutFIM;
	close FoutFOM;
	close FoutFIMTECH;
	close FoutFOMTECH;
	close FoutXHD;
	close FoutXDH;
	close FoutC4_SEND;
	close FoutC4_RECEIVE;
	close FoutSIMPLE;
	close FinSIMPLE;
	close FoutSIMPLEFIM;
	close FoutSIMPLEFOM;
	close FoutSIMPLEJI;
	close FoutSLP;
	close FoutTI;
	return 0;
}

sub getEtherParam{
	my $r_data = shift;
	my ($ether_dest,$ether_src,$ether_type,$ether_data) = unpack('H12H12H4a*',$$r_data);
	return ($ether_dest,$ether_src,$ether_type,$ether_data);
}

sub getIPParam{
	my $r_data = shift;
	my ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = unpack('H2H2H4H10H2H4H2H2H2H2H2H2H2H2a*', $$r_data);
	return ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data);
}

sub hexa2IPAddress{
	my $ip_1 = shift;
	my $ip_2 = shift;
	my $ip_3 = shift;
	my $ip_4 = shift;
	my $IPAddress =  hex($ip_1).".".hex($ip_2).".". hex($ip_3).".". hex($ip_4);
	return  $IPAddress;
}

sub getTCPParam{
	my $r_data = shift;
	my ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length) = unpack('H4H4H8H8H2a*', $$r_data);
	return ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length);
}
	

sub toRelative{
	my $secs = shift;
	my $msecs = shift;
	#print "ori $origin_seconds: $origin_milli\n";
	if ($msecs < $origin_milli) {
		$msecs = 1000000 + $msecs - $origin_milli ;
		$secs = $secs - $origin_seconds -1;
	}
	else {
		$msecs = $msecs - $origin_milli;
		$secs = $secs - $origin_seconds;
	}
	#print "del $secs, $msecs\n";
	return ($secs, $msecs);
}
sub toChrono{
	my $secs = shift;
	my $msecs = shift;
	my $chrono ="$secs.$msecs"if(                   $msecs > 99999);
	$chrono = "$secs.0$msecs" if(100000 > $msecs && $msecs > 9999);
	$chrono = "$secs.00$msecs"if(10000 > $msecs  && $msecs > 999);
	$chrono = "$secs.000"     if(1000  > $msecs);
	return $chrono;
}
	
sub fom2Aladdin {
	my $Fom1MsgHeader = "04000001";
	my $time = shift;
	#print "time : $time\n";
	my $fom = shift;
	if($fom =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;;
		if($BXM1 =~ /[08]2/){
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fom = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $Fom1MsgHeader $FXM";
		  return $fom;
	  	}
		else {
			return -1;
		}
  	}
}	      
	
sub fim2Aladdin {
	my $Fim1MsgHeader = "06000001";
	my $time = shift;
	#print "time : $time\n";
	my $fim = shift;
	if($fim =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print "$FXM\n";
		#print "C'est un FIM \n";
		if($BXM1 =~ /[08]2/){
		  #print "C'est un FIM01 \n";
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fim = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $Fim1MsgHeader $FXM";
		  return $fim;
		}	
		else{
			return -1;
		}
	}
}

sub fomtech2Aladdin {
	my $FomMsgHeader = "04000001";
	my $time = shift;
	#print "time : $time\n";
	my $fom = shift;
	if($fom =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
  		my $isFOMTECH = 0;
    		 # FOM03
  		if($BXM1 =~ /[08]6/){
    			$FomMsgHeader = "04000003";
    			$isFOMTECH = 1;
    			#print "$FXM\n";
    			#exit 0;
  		}
  		# FOM20
  		if($BXM1 =~ /[2a]8/){
    			$FomMsgHeader = "04000014";
    			$isFOMTECH = 1;
  		}
 		# FOM62
  		if($BXM1 =~ /fc/ ){
    			$FomMsgHeader = "0400003E";
    			$isFOMTECH = 1;
  		}
  		# FOM63
  		if($BXM1 =~ /fe/){
    			$FomMsgHeader = "0400003F";
    			$isFOMTECH = 1;
  		}
  		if( $isFOMTECH ) {
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  $FXM =~ s/\s*//g;
		  #print "$FXM \n";
		  # Suppression des FOM01 associ‰s on suppose qu'il n'y a pas de FOM tech associ‰ !
		  my $length = $lengthFxm*4;
		  $FXM = substr($FXM, 0, $length);
		  #print "$FXM $length $lengthFxm \n";
		  #exit 0;
		  #<>;
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+6;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fom = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $FomMsgHeader $BXM2 $BXM1 $FXM";
		}
		else {
      			$fom = -1;
 		}
		return $fom;
	}
}
 sub fimLength {
	my $r_fim = shift;
	if($$r_fim =~ /(..)(..)(.*)\s*/){
		my $BXM2 = $2 ;
		return hex($BXM2);
	}
	else {
		return -1;
	}
}	      
	
sub fimtech2Aladdin {
	my $FimMsgHeader = "06000001";
	my $time = shift;
	print "time : $time\n" if( $debug == 9);
	my $fim = shift;
	if($fim =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		print "$FXM\n";
		print "C'est un FIM \n";
  		my $isFIMTECH = 0;
  		# FIM62
  		if($BXM1 =~ /fc/ ){
    			$FimMsgHeader = "0600003E";
    			$isFIMTECH = 1;
			print "0600003E $FXM\n" if ($debug == 9);
			exit 0 ;
  		}
 		 # FIM63
  		if($BXM1 =~ /fe/){
    			$FimMsgHeader = "0600003F";
    			$isFIMTECH = 1;
			print "0600003F $FXM\n"if ($debug == 9);
			#exit 0;
  		}
  		if( $isFIMTECH ){
		  print "C'est un FIM tech \n" if( $debug == 9);
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  $FXM =~ s/\s*//g;
		  my $length = $lengthFxm*4;
		  $FXM = substr($FXM, 0, $length);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+6;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fim = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $FimMsgHeader $BXM2 $BXM1 $FXM";
		}
  		else {
        		$fim = "-1";
  		}
		return $fim;
	}
}

sub isFxm01 {
	my $r_fim = shift;
	if($r_fim =~ /(..)(..)(.*)\s*/){
		my $BXM1 = $1;
		if($BXM1 =~ /[08]2/){
			#print "true\n";
			return 1;
		}
		else{
			return 0;
		}
	}
	else {
		return 0;
	}
}

sub fxmLength {
	my $r_fim = shift;
	if($$r_fim =~ /(..)(..)(.*)\s*/){
		my $BXM2 = $2 ;
		return hex($BXM2);
	}
	else {
		return -1;
	}
}

sub slp2Aladdin {
	my $SlpMsgHeader = "09000000"; # en r‰ception de la SLP
	my $time = shift;
	#print "time : $time\n";
	my $slp_msg = shift;
	print "tcp_data : $slp_msg\n";
	if($slp_msg =~ /(....)(....)(....)(......)(.*)/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $length = $1;
		my $code_prim = $2;
		my $num_seq = $3;
		my $res_h = $4;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $slp_msg=$5;
		# suppresion des blancs
		#$slp_msg =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$slp_msg =~ s/(....)/$1 /g;
		my $lengthSlpMsg = hex($length);
		# Calcul de la longueur du message Aladdin
		$lengthSlpMsg = $lengthSlpMsg+4;
		$lengthSlpMsg = Conversion::toHexaString($lengthSlpMsg);
		# formattage des secondes ss.mmm
		$slp_msg = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthSlpMsg $SlpMsgHeader $length $code_prim $num_seq $res_h $slp_msg";
		print "$slp_msg\n";
		#<>;
		return $slp_msg;
	}
}

sub ti2Aladdin {
	my $tiMsgHeader = "08000000"; # en r‰ception de la SLP
	my $time = shift;
	#print "time : $time\n";
	my $ti_msg = shift;
	print "tcp_data : $ti_msg\n";
	if($ti_msg =~ /(....)(....)(....)(......)(.*)/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $length = $1;
		my $code_prim = $2;
		my $num_seq = $3;
		my $res_h = $4;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $ti_msg=$5;
		# suppresion des blancs
		#$ti_msg =~ s/\s//g;
		# s‰paration par paire d'octet XXXX XXXX ...
		$ti_msg =~ s/(....)/$1 /g;
		my $lengthSlpMsg = hex($length);
		# Calcul de la longueur du message Aladdin
		$lengthSlpMsg = $lengthSlpMsg+4;
		$lengthSlpMsg = Conversion::toHexaString($lengthSlpMsg);
		# formattage des secondes ss.mmm
		$ti_msg = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthSlpMsg $tiMsgHeader $length $code_prim $num_seq $res_h $ti_msg";
		print "$ti_msg\n";
		#<>;
		return $ti_msg;
	}
}

sub conv2Time {
	my $chrono = shift;
	my $milli = 0;
	#print "chron : $chrono \n";
	my $heure = int $chrono/3600;
	#print "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);	
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	#print "$heure $minute $seconde\n";
	$milli = int(($seconde-int($seconde))*1000);
	$seconde = int( $seconde);
	#print "$heure $minute $seconde $milli\n";
	$heure = substr('0'.$heure, -2);
	#print "$heure\n";
	$minute = substr('0'.$minute, -2);
	#print "$minute\n";
	$seconde = substr('0'.$seconde, -2);
	$milli = substr('00'.$milli, -3);
	#print "$heure $minute $seconde $milli\n";
	return ($heure, $minute, $seconde, $milli);
}

sub decodeSIMPLEFOM {
	my $Line = shift;
	#print "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print "$Line\n";
		my @Entete = split (" ",$Line);
		print "Sync : $Entete[0]$Entete[1]\n" if($debug == 6);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n"if($debug == 6);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n"if($debug == 6);
		my $Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n"if($debug == 6);
		my $Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n"if($debug == 6);
		my $Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n"if($debug == 6);
		my $Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
		my $Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n"if($debug == 6);
		my $Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n"if($debug == 6);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n"if($debug == 6);
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print "$Line\n$Packet_header_data\n"if($debug == 6);
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print "\tRC_flag = $RC_flag\n"if($debug == 6);
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print "\tNet_number= $Net_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print "\tNPG_number = $NPG_number\n"if($debug == 6);
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n"if($debug == 6);
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n"if($debug == 6);
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		  my $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n"if($debug == 6);
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    print "\t\t$Msg_data\n"if($debug == 6);
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    print "\t\t$Msg_data\n"if($debug == 6);
		    my $lengthFxm = $Word_count*2+4+10;
		    my $lengthFxm = Conversion::toHexaString($lengthFxm);
		    my $STN = substr(Conversion::toHexaString($STN),-4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
		    my $Msg_data= "0000 $STN $NPG_number_low$NPG_number_high 0000 0000"." $Msg_data";
		    print "\t\t$Msg_data\n"if($debug == 6);
			$Msg_data = "$lengthFxm 04000001 $Msg_data\n";
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


sub decodeSIMPLEFIM {
	my $Line = shift;
	#print "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print "$Line\n";
		my @Entete = split (" ",$Line);
		print "Sync : $Entete[0]$Entete[1]\n"if($debug == 6);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n"if($debug == 6);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n"if($debug == 6);
		my $Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n"if($debug == 6);
		my $Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n"if($debug == 6);
		my $Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n"if($debug == 6);
		my $Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
		my $Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n"if($debug == 6);
		my $Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n"if($debug == 6);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n"if($debug == 6);
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print "$Line\n$Packet_header_data\n"if($debug == 6);
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print "\tRC_flag = $RC_flag\n"if($debug == 6);
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print "\tNet_number= $Net_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print "\tNPG_number = $NPG_number\n"if($debug == 6);
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n"if($debug == 6);
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n"if($debug == 6);
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		  my $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n"if($debug == 6);
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    #print "\t\t$Msg_data\n";
		    my $lengthFxm = $Word_count*2+4+16;
		    my $lengthFxm = Conversion::toHexaString($lengthFxm);
		    my $STN = substr(Conversion::toHexaString($STN),-4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
		    my $Msg_data= "0000 0000 0000 0000 0000 0000 $NPG_number_low$NPG_number_high $STN"." $Msg_data";
		    #print "\t\t$Msg_data\n";
			$Msg_data = "$lengthFxm 06000001 $Msg_data\n";
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


sub decodeSIMPLEJI {
	my $r_Line = shift;
	#print "$Line\n";
	#$Line = s/\s//g;
	$$r_Line =~ s/(..)/$1 /g;
	#print "$Line\n";
	my @Entete = split (" ",$$r_Line);
	print "Sync : $Entete[0]$Entete[1]\n";
	my $Length = "$Entete[3]"."$Entete[2]";
	#print "$Length\n";		
	$Length = hex($Length);
	print "Length = $Length\n";
	my $Seq_number = "$Entete[5]"."$Entete[4]";
	$Seq_number = hex ($Seq_number);
	print "Seq_number = $Seq_number\n";
	my $Source_node = hex($Entete[6]);
	print "Source node = $Source_node\n";
	my $Source_sub_node = hex($Entete[7]);
	print "Source subnode = $Source_sub_node\n";
	my $Dest_node = hex($Entete[8]);
	print "Dest node = $Dest_node\n";
	my $Dest_sub_node = hex($Entete[9]);
	print "Dest_sub_node = $Dest_sub_node\n";
	my $Packet_size = hex($Entete[10]);	
	print "Packet size = $Packet_size\n";
	my $Packet_type = hex($Entete[11]);
	print "Packet type = $Packet_type\n";
	my$Transit_time = "$Entete[13]"."$Entete[12]";
	$Transit_time = hex($Transit_time);
	print "Transmit time = $Transit_time\n";
	if($Packet_type == 1){
		$$r_Line =~ s/\s*//g;
		my $Packet_header_data = substr($$r_Line, 28);
		print "$$r_Line\n$Packet_header_data\n";
		my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
	  	print "\tMsg_sub_type = $Msg_sub_type\n";
	  	my $RC_flag= hex(substr($Packet_header_data,2,2));
	  	print "\tRC_flag = $RC_flag\n";
	  	my $Net_number= hex(substr($Packet_header_data,4,2));
	  	print "\tNet_number= $Net_number\n";
	  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
	  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
	  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
	  	print "\tNPG_number = $NPG_number\n";
	  	my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
	  	print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
	  	my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
	  	print "\tSTN = $STN\n";
	 	my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		print "\tWord_count = $Word_count\n";
		my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		print "\tLoopback_id = $Loopback_id\n";
		my $Msg_data= substr($Packet_header_data,28);
		print "\tMsg_data = $Msg_data\n";
		$Msg_data =~ s/(....)$//;
		if($Msg_sub_type == 2){
			# espacement par mot de 16 bit
		    	$Msg_data =~ s/(....)/$1 /g;
		    	#print "\t\t$Msg_data\n";
		    	# inversion des octets par mot de 16 bit
		    	$Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    	#print "\t\t$Msg_data\n";
		    	my $lengthFxm = $Word_count*2+4+14;
		    	my $lengthFxm = Conversion::toHexaString($lengthFxm);
		    	my $STN = substr(Conversion::toHexaString($STN),-4);
		    	my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            	my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
			# Format JI message
			my $header_version = "0000";
			my $rx_mode = "0000";
		       	$rx_mode = "0002" if($NPG_number > 511);
		    	$Msg_data= "$header_version $rx_mode $STN $NPG_number_high$NPG_number_low FFFF 0000 0000 $Msg_data";
		    	#print "\t\t$Msg_data\n";
			$Msg_data = "$lengthFxm 0E000000 $Msg_data\n";
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
