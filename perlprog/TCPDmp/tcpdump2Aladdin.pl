# Modif S. Mouchot le 11/05/2016 V5_4_6
# 	ajout de l'option -x pour pouvoir lancer l'outil en mode graphique ou en mode online
# 	Traitement de plusieurs messages XHD dans 1 et même trame


#use strict;
use Tkx;
use Getopt::Std;
use File::Basename;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(G:/Tools/perlprog/lib);
#use lib qw(C:/Perl64/lib);

use TcpDumpLog;
use Conversion;
use BOM;
use SimpleMsg;
use J_Msg;
#use Time_conversion;

#use xMessageFilter;

#getopts("d:f:i:p:t:rxh");
getopts("f:p:xh");

my $debug = 10;

# 4 pour JRE
# 7 pour xdh
# 5 pour les xhd
# 6 pour le SIMPLEFOM
# 8 pour le SIMPLEFIM
# 9 pour les FIM / FOM (techniques)
# 10 pour les MI / MO SIMPLE

my $Config_File = "TCPDump.cfg";

if($opt_f){
  $Config_File = "$opt_f";
  print "Config file = $Config_File\n";
}

my $processFIMFOM=0;
my $processXHDXDH=0;
my $processSIMPLE=0;
my $processSLP=0;
my $processNAVRX=0;
my $processC4TX=0;
my $processC4RX=0;

my $toRelative=0;
my $deltatime = 0;



my $TCPDumpDir = ".\\";
my $TCPDumpFile = "vol_09_06_24_001.cap";

my $OutputDir = ".\\";
my $OutputFile = "vol_09_06_24_001";

# TCP parameters for FIM/FOM flow (serveur side)
my $FIMFOM_IP_Address = "10.100.25.120";
my $FIMFOM_TCP_Port = "1024";

# TCP parameters for FIM/FOM techniques flow (serveur side)
my $FIMFOMTECH_IP_Address = "10.100.25.120";
my $FIMFOMTECH_TCP_Port = "1070";

# TCP parameters for XHD/XDH flow (server side)
my $XHD_IP_Address = "10.0.3.30";
my $XHD_TCP_Port = "10001";

# TCP parameters for SIMPLE flow (server side)
my $SIMPLE_IP_Address = "200.1.18.5";
my $SIMPLE_TCP_Port = "10301";

# UDP parameters for Nav interface
my $NAV_RECV_IP_Address = "172.25.7.160";
my $NAV_RECV_UDP_Port = "15000";

my $C4_SEND_IP_Address = "172.25.7.160";
my $C4_SEND_UDP_Port = "15000";

my $C4_RECEIVE_IP_Address = "172.25.7.100";
my $C4_RECEIVE_UDP_Port = "14000";

# TCP parameters for SLP flow (server side)
my $SLP_SERVER_IP_Address = "172.25.8.170";
my $SLP_SERVER_TCP_Port = "10200";

my $origin_seconds = 0;
my $origin_milli = 0;

my @time;
my $chrono;

# $tcp_data reprsente la trame sous forme hexadecimal : 1 octet est represente par 2 caracteres hexa
# $data_length_in_char est le double de $data_length_in_byte (1 byte = 2 char)

my $tcp_header;
my $tcp_data;
my $data_length_in_byte;
my $data_length_in_char;

# flux SIMPLE client = 8
my $tcp_data_8;
my $data_length_in_byte_8;
my $data_length_in_char_8;
my $SIMPLE_msg_8;
my $SIMPLE_length_8;
my $etatLectureSIMPLE_8;

# flux SIMPLE server = 9
my $tcp_data_9;
my $data_length_in_byte_9;
my $data_length_in_char_9;
my $SIMPLE_msg_9;
my $SIMPLE_length_9;
my $etatLectureSIMPLE_9;

# Initialisation des paramètres via le fichier de configuration tcpdump2Aladdin.cfg
if(-f "$Config_File"){
  print FoutLog "Config file = $Config_File\n";
  open Fin, "<$Config_File" or die "Impossible ouvrir $Config_File\n";
  while(<Fin>){
    my $line  =  $_ ;
    chomp $line;
    $TCPDumpDir = $1 if($line =~ /TCPDumpDir=(\S*)/);
    $TCPDumpFile = $1 if($line =~ /TCPDumpFile=(\S*)/);
    if($opt_p) {
    	$TCPDumpFile = $opt_p;
    }
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
  	$NAV_RECV_IP_Address = $1 if($line =~ /NAV_RECV_IP_Address=(\S*)/);
	$NAV_RECV_UDP_Port = $1 if($line =~ /NAV_RECV_UDP_Port=(\S*)/);
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
    $processNAVRX= $1 if($line =~ /processNAVRX=(\S*)/);
    $processC4TX= $1 if($line =~ /processC4TX=(\S*)/);
    $processC4RX= $1 if($line =~ /processC4RX=(\S*)/);
    $toRelative= $1 if($line =~ /TimeRelative=(\S*)/);
  }
  close Fin;
  if($debug ==10){

      print FoutLog " TCPDumpDir=$TCPDumpDir\n";
      print FoutLog " TCPDumpFile=$TCPDumpFile\n";
      print FoutLog "OutputDir = $OutputDir\n";
      print FoutLog "OutputFile = $OutputFile\n";
  }
}
else {
	die "$TCPDumpFile do not exist..."
}

if($opt_h){
	print "tcpdump2Aladdin.pl [-h]  -x\n";
	print "convertit un fichier tcpdump en fichier Aladdin...\n";
	exit -1;
}

if ($opt_x) {

	my $mw = Tkx::widget->new(".");
	$mw->g_wm_title("$0" );

	my $Vframe1 = $mw->new_ttk__frame->g_grid(-column => 2, -row => 0, -sticky => "w");
	$mw->new_ttk__label(-text => "tcpdump2Aladdin.pl [-h] convertit un fichier tcpdump en fichiers Aladdin...\n")
		->g_grid(-column => 0, -row => 0, -sticky => "e", -columnspan => 4);
	$mw->new_ttk__label(-text => "Input directory : ", -width => 20)
		->g_grid(-column => 1, -row => 1, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$TCPDumpDir, -width => 35)
		->g_grid(-column => 2, -row => 1, -sticky => "w");
	$mw->new_ttk__label(-text => 'TCPDump file : ', -width => 20)
		->g_grid(-column => 3, -row => 1, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$TCPDumpFile, -width => 35)
		->g_grid(-column => 4, -row => 1, -sticky => "w");
	$mw->new_ttk__label(-text => "Output directory : ", -width => 20)
		->g_grid(-column => 1, -row => 2, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$OutputDir, -width => 35)
		->g_grid(-column => 2, -row => 2, -sticky => "w");
	$mw->new_ttk__label(-text => 'Output file : ', -width => 20)
		->g_grid(-column => 3, -row => 2, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$OutputFile, -width => 35)
		->g_grid(-column => 4, -row => 2, -sticky => "w");


	my $Vframe2 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 3, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processFIMFOM, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 3, -sticky => "we");
	$mw->new_ttk__label(-text => "FIM/FOM  (server side) IP Address : ",  -width => 35)
		->g_grid(-column => 1, -row => 3, -sticky => "e");
	$mw->new_ttk__entry(-textvariable => \$FIMFOM_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 3, -sticky => "w");
	$mw->new_ttk__label(-text => 'TCP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 3, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$FIMFOM_TCP_Port,-width => 10)
		->g_grid(-column => 4, -row => 3, -sticky => "w");
	#
	my $Vframe3 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 4, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processXHDXDH, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 4, -sticky => "we");
	$mw->new_ttk__label(-text => "XHD/XDH (server side) IP Address : ", -width => 35)
		->g_grid(-column => 1, -row => 4, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$XHD_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 4, -sticky => "w");
	$mw->new_ttk__label(-text => 'TCP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 4, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$XHD_TCP_Port, -width => 10)
		->g_grid(-column => 4, -row => 4, -sticky => "w");

	my $Vframe4 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 5, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processSIMPLE, -command => \&radiobuttonproceed, -width => 1 )
		->g_grid(-column => 0, -row => 5, -sticky => "w");
	$mw->new_ttk__label(-text => "SIMPLE : ", -width => 35)
		->g_grid(-column => 1, -row => 5, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$SIMPLE_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 5, -sticky => "w");
	$mw->new_ttk__label(-text => 'TCP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 5, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$SIMPLE_TCP_Port, -width => 10)
		->g_grid(-column => 4, -row => 5, -sticky => "w");
		
	my $Vframe4_1 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 6, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processNAVRX, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 6, -sticky => "w");
	$mw->new_ttk__label(-text => "NAV RECV IP Address : ", -width => 35)
		->g_grid(-column => 1, -row => 6, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$NAV_RECV_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 6, -sticky => "w");
	$mw->new_ttk__label(-text => 'UDP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 6, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$NAV_RECV_UDP_Port, -width => 10)
		->g_grid(-column => 4, -row => 6, -sticky => "w");

	my $Vframe5 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 7, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processC4TX, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 7, -sticky => "w");
	$mw->new_ttk__label(-text => "C4 SEND IP Address : ", -width => 35)
		->g_grid(-column => 1, -row => 7, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$C4_SEND_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 7, -sticky => "w");
	$mw->new_ttk__label(-text => 'UDP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 7, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$C4_SEND_UDP_Port, -width => 10)
		->g_grid(-column => 4, -row => 7, -sticky => "w");

	my $Vframe6 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 8, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processC4RX, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 8, -sticky => "w");
	$mw->new_ttk__label(-text => "C4 RECEIVE IP Address : ", -width => 35)
		->g_grid(-column => 1, -row => 8, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$C4_RECEIVE_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 8, -sticky => "w");
	$mw->new_ttk__label(-text => 'UDP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 8, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$C4_RECEIVE_UDP_Port, -width => 10)
		->g_grid(-column => 4, -row => 8, -sticky => "w");

	my $Vframe7 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 9, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$processSLP, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 9, -sticky => "w");
	$mw->new_ttk__label(-text => "SLP server IP Address : ", -width => 35)
		->g_grid(-column => 1, -row => 9, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$SLP_SERVER_IP_Address, -width => 15)
		->g_grid(-column => 2, -row => 9, -sticky => "w");
	$mw->new_ttk__label(-text => 'TCP Port : ', -width => 10)
		->g_grid(-column => 3, -row => 9, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$SLP_SERVER_TCP_Port, -width => 10)
		->g_grid(-column => 4, -row => 9, -sticky => "w");

	my $Vframe7_2 = $mw->new_ttk__frame
		->g_grid(-column => 0, -row => 10, -sticky => "w");
	$mw->new_ttk__checkbutton( -variable => \$toRelative, -command => \&radiobuttonproceed, -width => 1)
		->g_grid(-column => 0, -row => 10, -sticky => "w");
	$mw->new_ttk__label(-text => "Relative Time", -width => 35)
		->g_grid(-column => 1, -row => 10, -sticky => "w");
	
	$mw->new_ttk__label(-text => 'Delta Time : ', -width => 10)
		->g_grid(-column => 1, -row => 10, -sticky => "w");
	$mw->new_ttk__entry(-textvariable => \$deltatime, -width => 10)
		->g_grid(-column => 2, -row => 10, -sticky => "w");
	my $ButtonTranslate=$mw->new_ttk__button(-text=>'Translate Time', -state => 'active', -command => \&translateTime, -width => 12)
		->g_grid(-column => 3, -row => 10, -sticky => "w");

	my $Vframe10 = $mw->new_ttk__frame
		->g_grid(-column => 1, -row => 12, -sticky => "w");
	my $buttonOpen = $mw->new_ttk__button(-text => "Open", -state => 'active', -command => \&openFile, -width => 12)
		->g_grid(-column => 1, -row => 12, -sticky => "w");
	my $ButtonSave=$mw->new_ttk__button(-text=>'Saving config.', -state => 'active', -command => \&saveConfig, -width => 12)
		->g_grid(-column => 2, -row => 12, -sticky => "w");
	my $ButtonExtract=$mw->new_ttk__button(-text=>'Extracting', -state => 'active', -command => \&extract2Aladdin, -width => 12)
		->g_grid(-column => 3, -row => 12, -sticky => "w");
	my $ButtonFilter=$mw->new_ttk__button(-text=>'Filtering', -state => 'active', -command => \&filterMessage, -width => 15)
		->g_grid(-column => 4, -row => 12, -sticky => "w");

	
	Tkx::MainLoop();
}
else {
	extract2Aladdin();
}
exit 0;

sub openFile {	
	print "open file...\n";
	my $openFile = Tkx::tk___getOpenFile();
	($TCPDumpFile, $TCPDumpDir, my $TCPDumpExt) = fileparse($openFile);
	$TCPDumpFile = $TCPDumpFile . $TCPDumpExt;
	$OutputDir = $TCPDumpDir;
}

sub translateTime{
	Time_conversion::translate_time("$OutputDir\\$OutputFile",$deltatime);
	return 0;
}

sub filterMessage{
  my $filterDir = "filter";
  my $filterFile = "filter";
# my @extList = ("xdh","xhd", "fim", "fom");
  my @extList = ("xhd", "xdh", "fim", "fom");
  my @input=($OutputDir, $OutputFile, $filterDir, $filterFile, \@extList);
  print FoutLog "@input\n" if($debug == 1);
  xMessageFilter->xMessageFilter(@input);
  return 0;
}

sub saveConfig{
    system("xcopy /Y $Config_File $Config_File.old");
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
    print Fout "NAV_RECV_IP_Address=$NAV_RECV_IP_Address\n";
    print Fout "NAV_RECV_UDP_Port=$NAV_RECV_UDP_Port\n";
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
    print Fout "processNAVRX=$processNAVRX\n";
    print Fout "processC4TX=$processC4TX\n";
    print Fout "processC4RX=$processC4RX\n";
    print Fout "TimeRelative=$toRelative\n";
    close Fout;
    return 0;
}

sub radiobuttonproceed {
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
	open FoutSIMPLE_CLIENT, ">$OutputDir$OutputFile.so" or die "Impossible ouvrir test.so" if($processSIMPLE);
	open FoutSIMPLE_SERVER, ">$OutputDir$OutputFile.si" or die "Impossible ouvrir test.si" if($processSIMPLE);
	open FoutSIMPLEFIM, ">$OutputDir$OutputFile.SIMPLE.fim" or die "Impossible ouvrir test.SIMPLE.fim" if($processSIMPLE);
	open FoutSIMPLEFOM, ">$OutputDir$OutputFile.SIMPLE.fom" or die "Impossible ouvrir test.SIMPLE.fom" if($processSIMPLE);
	open FoutSIMPLE_L11_SERVER, ">$OutputDir$OutputFile.SIMPLE.mi" or die "Impossible ouvrir test.SIMPLE.mi" if($processSIMPLE);
	open FoutSIMPLE_L11_CLIENT, ">$OutputDir$OutputFile.SIMPLE.mo" or die "Impossible ouvrir test.SIMPLE.mo" if($processSIMPLE);
	open FoutSIMPLEJI, ">$OutputDir$OutputFile.SIMPLE.ji" or die "Impossible ouvrir ..." if($processSIMPLE);
	open FoutNAV_RECV, ">$OutputDir$OutputFile.NAV.xhd" or die "Impossible ouvrir test_NAV.xhd" if($processNAVRX);
	open FoutNAV_SEND, ">$OutputDir$OutputFile.NAV.xdh" or die "Impossible ouvrir test_NAV.xdh" if($processNAVRX);
	open FoutC4_SEND, ">$OutputDir$OutputFile.C4.xdh" or die "Impossible ouvrir test_C4.xdh" if($processC4RX);
	open FoutC4_RECEIVE, ">$OutputDir$OutputFile.C4.xhd" or die "Impossible ouvrir test_C4.xhd" if($processC4TX);
	open FoutSLP, ">$OutputDir$OutputFile.SLP.ind_rep_apu" or die "Impossible ouvrir ind_rep_apu" if($processSLP);
	open FoutTI, ">$OutputDir$OutputFile.TI.dem_apu" or die "Impossible ouvrir dem_apu" if($processSLP);
	open FoutLog, ">$OutputDir/tcpdump2aladdin.log " or die "Impossible ouvrir tcpdump2aladdin.log";
	my $log = Net::TcpDumpLog->new(32);	# force 32-bits to match this file
	$log->read("$TCPDumpDir$TCPDumpFile");

	my ($length_orig,$length_incl,$drops,$secs,$msecs) = $log->header(0);
	my $origin_seconds = $secs;
	my $origin_milli = $msecs;

	my @Indexes = $log->indexes;

	my $etatLectureXDH = 0;
	# $etatLectureXDH definit l'état de lecture du message XDH octet par octet modif Meltem
	# = 0 : 1er octet de synchro trame non lu
	# = 1 : 1ème octet de synchro trame lu
	# = 2 : 2ème octet de synchro trame lu
	# = 3 : 1er octet de longueur lu
	# = 4 : 2ème octet de longueur lu
	my $XDH_msg = "";
	my $XDH_length = 0;
	my $XDH_current_length = 0;
	my $XDH_length_in_char;
	
	my $etatLectureSIMPLE_8 = 0;
	my $etatLectureSIMPLE_9 = 0;
	# $etatLectureSIMPLE definit l'état de lecture du message SIMPLE octet par octet modif SNCP TD
	# = 0 : 1er octet de synchro trame non lu
	# = 1 : 1ème octet de synchro trame lu
	# = 2 : 2ème octet de synchro trame lu
	# = 3 : 1er octet de longueur lu
	# = 4 : 2ème octet de longueur lu
	my $SIMPLE_msg_8 = "";
	my $SIMPLE_msg_9 = "";
	my $SIMPLE_length_8 = 0;
	my $SIMPLE_length_9 = 0;
#	my $SIMPLE_current_length = 0;
#	my $SIMPLE_length_in_char;

  	my $new_XHD= 1;
        my $XHD = "";
        my $XHD_length_in_char;
	my $XHD_current_length = 0;
    my $is_previous_packet_completed = 0;

	my $new_C4_SEND = 1;
	my $new_C4_RECEIVE= 1;
	my $C4_SEND = "";
	my $C4_RECEIVE = "";
	my $C4_SEND_current_length = 0;
	my $C4_RECEIVE_current_length = 0;
	my $C4_SEND_length_in_char;
	my $C4_RECEIVE_length_in_char;
	my $new_NAV_RECV = 1;
	my $NAV_RECV = "";
	my $NAV_RECV_current_length = 0;
	my $NAV_RECV_current_length = 0;
	my $NAV_RECV_length_in_char;
	my $NAV_RECV_length_in_char;

	my $etat_slp_msg = 0;
	my $slp_msg;

	# Creation du fichier .conf
	open Fout, ">$OutputDir$OutputFile.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n" ;
	if($processSIMPLE){
		print Fout "Simple_Output_File = $OutputFile.so\n";
		print Fout "Simple_Input_File = $OutputFile.si\n";
	}
	if($processFIMFOM){
		print Fout "Link_Output_File_1 = $OutputFile.fim\n";
		print Fout "Link_Input_File_1 = $OutputFile.fom\n";
		print Fout "Link_Id_1=1\n";
    	print Fout "Link_Type_1=L16\n";
    	print Fout "Link_Port_1=200\n";
    	print Fout "Link_Dictionary_File_1=C:\\Aladdin_V2\\Dictionaries\\FIM_FOM\\d_fxm_ah_l16_ed5_Altbmd1c_ML366_963.xml\n";
	}
	if($processXHDXDH){
		print Fout "Host_Output_File_1 = $OutputFile.xdh\n";
		print Fout "Host_Input_File_1 = $OutputFile.xhd\n";
		print Fout "Host_Output_File_2 = $OutputFile.C4.xdh\n";
		print Fout "Host_Input_File_2 = $OutputFile.C4.xhd\n";
		print Fout "Host_Input_File_3 = $OutputFile.NAV.xhd\n";
		print Fout "Host_Output_File_3 = $OutputFile.NAV.xdh\n";
		print Fout "Host_Port_1=2000\n";
    	print Fout "Host_Dictionary_File_1=C:\\Aladdin_V2\\Dictionaries\\Host\\d_ALTBMD_c2_v136_jb.xml\n";
    }
    if($processSIMPLE){
		print Fout "Simple_Output_File=$OutputFile.so\n";
		print Fout "Simple_Input_File=$OutputFile.si\n";
		print Fout "Link_Output_File_1=$OutputFile.SIMPLE.fom\n";
		print Fout "Link_Input_File_1=$OutputFile.SIMPLE.fim\n";
		print Fout "Link_Output_File_2=$OutputFile.SIMPLE.mo\n";
		print Fout "Link_Input_File_2=$OutputFile.SIMPLE.mi\n";       
	}
    
    print Fout "Data_Base=$OutputFile.xml\n";
	close Fout; 
	# Creation du fichier SIMPLE.conf
	if($processSIMPLE){
	                   open Fout, ">$OutputDir$OutputFile.SIMPLE.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n" ;
	                   #print Fout "Host_Input_File=$OutputDir$OutputFile.xhd\n";
	                   #print Fout "Host_Output_File=$OutputDir$OutputFile.xdh\n";
	                   print Fout "Simple_Output_File=$OutputFile.so\n";
	                   print Fout "Simple_Input_File=$OutputFile.si\n";
	                   print Fout "Link_Output_File_1=$OutputFile.SIMPLE.fom\n";
	                   print Fout "Link_Input_File_1=$OutputFile.SIMPLE.fim\n";
	                   print Fout "Link_Output_File_2=$OutputFile.SIMPLE.mo\n";
	                   print Fout "Link_Input_File_2=$OutputFile.SIMPLE.mi\n";
	                   close Fout;
	}

	# Creation du fichier FXM.conf
	if($processFIMFOM){
	                   open Fout, ">$OutputDir$OutputFile.FXM.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	                   print Fout "Link_Output_File_1 = $OutputFile.fom\n";
	                   print Fout "Link_Input_File_1 = $OutputFile.fim\n";
	                   close Fout;
	}
	# Creation du fichier XHD.conf
    if($processXHDXDH){
	                   open Fout, ">$OutputDir$OutputFile.XHD.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	                   print Fout "Host_Output_File_1 = $OutputFile.xdh\n";
	                   print Fout "Host_Input_File_1 = $OutputFile.xhd\n";
	                   print Fout "Host_Output_File_2 = $OutputFile.C4.xdh\n";
	                   print Fout "Host_Input_File_2 = $OutputFile.C4.xhd\n";
	                   close Fout;
    }
 
	foreach my $num  (0..$#Indexes){
		#retrieve for each tcpdump record header data
		my ($length_orig,$length_incl,$drops,$secs,$msecs) = $log->header($num);
		print "$secs,$msecs\n";
		my $zoneoffset = $log->zoneoffset();
		my $data = $log->data($num);
		my ($ether_dest,$ether_src,$ether_type,$ether_data) = getEtherParam(\$data);
		my $length = length($data);
		#print FoutLog "$ether_dest,$ether_src,$ether_type,$ether_data\n";
		# si le paquet ethernet est un paquet IP	
		if( hex($ether_type) == 0x800) {		
			# calcul de l'heure (suppression de la date)
			if($toRelative == 1){ 
				print FoutLog "origine : $origin_seconds, $origin_milli\n";
				print FoutLog "$secs, $msecs : avant\n";
				my ($heure, $minute, $seconde) = conv2Time($secs, $msecs);
				my $minute = int($secs/60) - $heure*60 ;
				my $seconde = $secs - $minute*60 - $heure*3600;
				print FoutLog " heure : $heure : $minute : $seconde\n" if ($debug == 8) ;
				($secs, $msecs) = Conversion::toRelative($secs, $msecs, $origin_seconds, $origin_milli);
				print FoutLog "$secs, $msecs : après\n";				
				#<>;
			}
			#transforme les micro seconde lu sous etherreal en millisecondes
			$msecs = Conversion::micro2Milli($msecs);
			# suppression de la date 
			$secs = ($secs % (24*3600));
			@time = (0,0,$secs,$msecs);
			$chrono = Conversion::toChrono(@time);
			print FoutLog " Chrono : $secs $msecs $chrono\n" if($debug == 8);
			#<> if($debug == 1);
			my ($ip_type, $trash, $ip_total_length,$trash_1,$ip_proto, $trash_2, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = getIPParam(\$ether_data);
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
				#print FoutLog "tcp header lentgh, src port, dest port : $tcp_head_length, $tcp_port_src, $tcp_port_dest\n" if ($debug == 8);
				my $length_tcp_head_in_char = $tcp_head_length*2;
				# Assuming ip header length is always 20, to withdraw trailing data
				$data_length_in_char = ($ip_total_length - 20 - $tcp_head_length)*2;
				print FoutLog "$length_tcp_head_in_char, $data_length_in_char \n" if ($debug == 8) ;
				#<>;
				if ($data_length_in_char != 0) {				
					($tcp_header, $tcp_data) = unpack ("H${length_tcp_head_in_char}H${data_length_in_char}", $ip_data);
					#print FoutLog "tcp header  : $tcp_header\n";					
                    # $tcp_data reprsente la trame sous forme hexadecimal : 1 octet est represente par 2 caracteres hexa
                    # $data_length_in_char est le double de $data_length_in_byte (1 byte = 2 char)
                   	$data_length_in_byte = int($data_length_in_char/2);

# Traitement des flux XDH
					# J-P. Coron, le 20 octobre 2009 - Debut modification
                    #if($ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port){
                    my @tab_ip_src = split (/\./,$ip_src);		    
                    my @tab_XHD_IP_Address = split (/\./,$XHD_IP_Address);
                    if ($ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port) {
                    # J-P. Coron, le 20 octobre 2009 - Fin modification		
                    	print FoutLog "tcp data    : $tcp_data\n" if ((length($ip_data) > $tcp_head_length)&& $debug == 1);
						print FoutLog "$ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port\n" if ($debug == 1);
                      for my $i (0..$data_length_in_byte-1){
                        # traitement 2 char par é char
                        my $char = substr($tcp_data, $i*2, 2);
                        #print FoutLog "$char, $i, $data_length_in_char\n" if($debug == 7);
                        # recherche du premier octet de synchro
                         if($etatLectureXDH == 0) {
                            if($char =~/44/){
                            #if($char =~ /00/){
                              $etatLectureXDH = 1;
                              #$XDH_msg = $char;
                              print FoutLog "passage a l'etat 1\n" if($debug == 7);
                              print FoutLog "$XDH_msg\n" if($debug == 7);
                              <> if($debug == 7);
                            }
                            next;
                          }
                          # recherche du 2ème octet de synchro trame
                          if($etatLectureXDH == 1) {
                            if($char =~ /48/){
                            #if($char =~ /00/){
                              #$XDH_msg .= $char;
                              $etatLectureXDH = 2;
                              print FoutLog "passage a l'etat 2\n" if($debug == 7);
                              print FoutLog "$XDH_msg\n" if($debug == 7);
                              #<> if($debug == 7);
                            }
                            else {
                              $XDH_msg = "";
                              $etatLectureXDH = 0;
                              print FoutLog "retour a l'etat 0\n" if($debug == 7);
                            }
                            next;
                          }
                          # recherche du 1er octet de longueur
                          if($etatLectureXDH == 2) {
                            $XDH_length = $char;
                            $XDH_msg .= $char;
                            $etatLectureXDH = 3;
                            print FoutLog "passage a l'etat 3 \n" if($debug == 7);
                            print FoutLog "$XDH_msg\n" if($debug == 7);
                            next;
                          }
                          # recherche du 2eme octet de longueur
                          if($etatLectureXDH == 3) {
                            $XDH_length .= $char;
                            $XDH_length = hex($XDH_length);
                            $XDH_msg .= $char;
                            $etatLectureXDH = 4;
                            print FoutLog "passage a l'etat 4 \n" if($debug == 7);
                            print FoutLog "$XDH_msg \n" if($debug == 7);
                            print FoutLog "XDH_length = $XDH_length \n" if($debug == 7);
                            next;
                          }
                      
                          if($etatLectureXDH == 4) {
                            $XDH_msg .= $char;
                            #print FoutLog "$XDH_length\n";
                            if(length($XDH_msg) == ($XDH_length*2)+4){
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
                            #print FoutLog "etat 4 \n" if($debug == 7);
                            print FoutLog "$XDH_msg \n" if($debug == 7);
                            next;
                          }
                        }
                        #print FoutLog "sortie analyse trame\n";
                        #<> if($debug == 7);
                    }    
# Le paquet TCP est un XHD					
					if($ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port){
						my $length = length($tcp_data); # length of hexa string : 2 for 1 octet
						while ($length > 0){
							#print FoutLog "$ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port\n" if ($debug == 5);
							#print FoutLog "XHD:$secs.$msecs:$tcp_data\n";
							#print FoutLog "Source :      $ip_src\t$tcp_port_src\n";
							#print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n";
							# Si le paquet est le debut d'un message
							if($tcp_data =~/^4844(....)/ && $new_XHD == 1){
							#if($tcp_data =~/^0000(....)/ && $new_XHD == 1){
								#print FoutLog "new XDH\n";
								$XHD=$tcp_data;
								$XHD_length_in_char = (hex($1)+4)*2; # la longueur lu en octet + 2 octet de lon
								# on extrait le 1er message
								$XHD=substr($tcp_data, 0, $XHD_length_in_char);
								$tcp_data = substr($tcp_data,$XHD_length_in_char, $length - $XHD_length_in_char);
								$length = length($tcp_data);
								print FoutLog "new XHD length in char = $XHD_length_in_char\n" if($debug == 5);
								print Foutlog "rest tcp_data = $tcp_data\n"  if($debug == 5);
								<> if($debug == 5);
								#print FoutLog "XDH:$XDH\n";
								$new_XHD = 0;
                                if ($length == 0){
                                    $is_previous_packet_completed = 1;
                                }
							}
							# Si le message est la continuation d'un message
							elsif($is_previous_packet_completed == 1){
                                $is_previous_packet_completed = 0;
                                my $first_part_XHD_length = length ($XHD);
                                $XHD=$XHD.substr($tcp_data, 0, $XHD_length_in_char - $first_part_XHD_length);
                                $tcp_data = substr($tcp_data,$XHD_length_in_char - $first_part_XHD_length);
                                $length = length($tcp_data);
								print FoutLog "XHD:$XHD\n" if($debug == 5);
							}
                            # Si le message n'est pas identifiable (code msg ou taille splité sur 2 packets)
                            else{
                                print FoutLog "message non identifie :$tcp_data\n" if($debug == 5); #YPE
                                $XHD = $tcp_data;
                                $is_previous_packet_completed = 1;
                                $length = 0; #Pour passer au packet suivant
                            }
							$XHD_current_length = length($XHD);
							if($XHD_current_length == $XHD_length_in_char){
								$new_XHD = 1;
								$XHD=substr($XHD, 4, $XHD_length_in_char-4);
								#print FoutLog "$XHD\n";
								$XHD =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
								$XHD =~ s/\s//g;
								$XHD =~ s/(....)/$1 /g;
								$XHD =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
								# conversion minuscules en majuscules
								$XHD = uc($XHD);
								my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
								print FoutXHD "$heure:$minute:$seconde.$milli $XHD\n";
								print FoutLog "$heure:$minute:$seconde.$milli $XHD\n" if($debug == 5);
								#<> if($debug == 5);
							}
						}
					}
# Le paquet TCP est un paquet SIMPLE entrant cote serveur
					#print FoutLog "SIMPLEFIM $ip_src eq $SIMPLE_IP_Address && $tcp_port_src eq $SIMPLE_TCP_Port\n" if ($debug == 8);
					if($ip_src eq $SIMPLE_IP_Address && $tcp_port_src eq $SIMPLE_TCP_Port){
						print FoutLog "extract_SIMPLE_Msg Server\n";
						print FoutLog "$tcp_data\n";
						extract_SIMPLE_Msg_Server();
						#<>;	
					} 	
								
# Le paquet TCP est un paquet SIMPLE entrant cote client
					#print FoutLog "$ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port\n" if ($debug == 9);
					if(($ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port)) {
						print FoutLog "extract_SIMPLE_Msg Client\n";
						print FoutLog "$tcp_data\n";
						extract_SIMPLE_Msg_Client();
						#<>;	
					} 	
                
		    # Le paquet est un fom
		    if($ip_src eq $FIMFOM_IP_Address && $tcp_port_src eq $FIMFOM_TCP_Port){
		    	my $length = length($tcp_data); # length of hexa string : 2 for 1 octet
				while ($length > 0){
					print FoutLog " $tcp_data\n" if ($debug == 9);
					print FoutLog "length data = $length\n" if ($debug == 9);
					print FoutLog "this is a F0M : $tcp_data\n" if ($debug == 9);
					# FOMlength is the nber of 16bit word without the BIM/BOM word
					my $FOMlength = fxmLength(\$tcp_data);
					# FOMlength_in_car is the nber of hexa char in the FOM
					my $FOMlength_in_car = $FOMlength*4+4;
					my $fom = substr($tcp_data, 0, $FOMlength_in_car);
					print FoutLog "new fom: $fom length : $FOMlength_in_car\n" if ($debug == 9);
					$length = $length - ($FOMlength_in_car);
					if($length > 0){
			    		$tcp_data = substr($tcp_data, $FOMlength_in_car, $length);
			    		print FoutLog "new tcp_data : $tcp_data new length : $length\n"  if ($debug == 9);
					}
					if (isFxm01($fom)){
						# add process to format FOM to the right length
						# Agile add inconsistant word
						my $fomLength = fomLength(\$fom);
						print FoutLog "length : $fomLength\n"if ($debug == 9);
						# Longeur en byte = BOM + FIM + J
						my $fomLengthByte = (1 + 5 + $fomLength*5 )*2; 
						my $fomLengthCar = $fomLengthByte * 2;
						$fom = substr($fom, 0, $fomLengthCar); 
						print FoutLog "fom : $fom\n"if ($debug == 9);
			  			$fom = fom2Aladdin($chrono, $fom);
			  			print FoutLog "fom01 : $fom \n"  if ($debug == 9);
			  			print FoutFOM "$fom\n";
			  			#exit 0;
					}
					else {
			  			my $fom = fomtech2Aladdin($chrono, $fom);
			  			if( length($fom) > 2){
			    			print FoutFOMTECH "$fom\n" ;
			    			print FoutLog "fom tech : $fom\n" if ($debug == 9);
			  			}
					}
		      	}
		      	print FoutLog "FOM:$secs.$msecs:$tcp_data\n"  if ($debug == 9);
		      	print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n\n\n"  if ($debug == 9);
		      	#<> if($debug == 9);
		    }
		    # Le paquet est un fim
		    if($ip_dest eq $FIMFOM_IP_Address && $tcp_port_dest eq $FIMFOM_TCP_Port){
		    	print FoutLog "FIM:$secs.$msecs:$tcp_data\n" if( $debug == 9);
		    	print FoutLog "Source :      $ip_src\t$tcp_port_src\n" if( $debug == 9);
		    	print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n" if( $debug == 9);
		    	# Decoupe du message en fim elementaire
		      	my $length = length($tcp_data);
		      	while ($length > 0){
					print FoutLog " $tcp_data\n" if ($debug == 9);
					print FoutLog "length data = $length\n" if ($debug == 9);
					print FoutLog "this is a FIM : $tcp_data\n" if ($debug == 9);
			  		my $FIMlength = fxmLength(\$tcp_data);
			  		# FIMlength is the nber of 16bit word without the BIM/BOM word
			  		# FIMlength_in_car is the nber of hexa char in the FIM
			  		my $FIMlength_in_car = $FIMlength*4+4;
			  		my $fim = substr($tcp_data, 0, $FIMlength_in_car);
			  		print FoutLog "new fim : $fim length : $FIMlength_in_car\n" if ($debug == 9);
			  		$length = $length - ($FIMlength_in_car);
			  		if($length > 0){
			    		$tcp_data = substr($tcp_data, $FIMlength_in_car, $length);
			    		print FoutLog "new tcp_data : $tcp_data new length : $length\n"  if ($debug == 9);
			  		}
			  		if (isFxm01($fim)){
			  			my $fim = fim2Aladdin($chrono, $fim);
			  			print FoutLog "fim : $fim \n"  if ($debug == 9);
			  			print FoutFIM "$fim\n";
			  		}
					else {
			  			my $fim = fimtech2Aladdin($chrono, $fim);
			  			if( length($fim) > 2){
			  				print FoutFIMTECH "$fim\n" ;
			  				print FoutLog "fim tech : $fim\n" if ($debug == 9);
			  			}
					}
		      	}
		      	#<> if($debug == 9);
		    }
		    # Le paquet est un fom technique  sur la liaison discrets FOM62
		    if($ip_src eq $FIMFOMTECH_IP_Address && $tcp_port_src eq $FIMFOMTECH_TCP_Port){
		      #print FoutLog "FOM:$secs.$msecs:$tcp_data\n";
		      ##print FoutLog "Source :      $ip_src\t$tcp_port_src\n";
		      ##print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n";
		      my $fom = fomtech2Aladdin($chrono, $tcp_data);
		      print FoutFOMTECH "$fom\n" if( length($fom) > 2);
		      print FoutLog "fom tech 2 : $fom\n"if( $debug == 9);
		    }
		    # Le paquet est un fim technique     sur la liaison discrets    FIM62 FIM63
		    if($ip_dest eq $FIMFOMTECH_IP_Address && $tcp_port_dest eq $FIMFOMTECH_TCP_Port){
		      print FoutLog "FIM:$secs.$msecs:$tcp_data\n" if( $debug == 9);
		      print FoutLog "Source :      $ip_src\t$tcp_port_src\n" if( $debug == 9);
		      print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n" if( $debug == 9);
		      my $fim = fimtech2Aladdin($chrono, $tcp_data);
		      print FoutLog "$fim\n"  if( $debug == 9);
		      #exit 0;
		      print FoutFIMTECH "$fim\n" if( $fim !~/^-1/);
		      print FoutLog "fim tech 2 : $fim\n" if( $debug == 9);
		      #close FoutFIMTECH;
		      #exit 0;
		    }
		# Le paquet est un message reçu de la SLP 
		if($ip_src eq $SLP_SERVER_IP_Address && $tcp_port_src eq $SLP_SERVER_TCP_Port){
						# réception champ par champ 
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
						#print FoutLog "FIM:$secs.$msecs:$tcp_data\n";
						#print FoutLog "Source :      $ip_src\t$tcp_port_src\n";
						#print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n";
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
				#print FoutLog "$ip_data\n";
				print "ip lentgh, ip src, ip dest  : $ip_total_length, $ip_src, $ip_dest\n" if($debug == 12);
				my ($udp_port_src, $udp_port_dest, $udp_length, $udp_cksum, $udp_data) = unpack('H4H4H4H4a*', $ip_data);
				$udp_port_src = hex($udp_port_src);
				$udp_port_dest = hex($udp_port_dest);
				#print FoutLog "udp port src, port dst : $udp_port_src, $udp_port_dest\n";
				$data_length_in_byte = hex($udp_length) - 8;
				print "udp data length in byte : $data_length_in_byte \n" if($debug == 12);
				if ($data_length_in_byte != 0) {
					$data_length_in_char = $data_length_in_byte * 2;
					# c est un msg C4 envoyé
					if($ip_src eq $C4_SEND_IP_Address && $udp_port_src eq $C4_SEND_UDP_Port){
						print FoutLog "$ip_src -> $C4_SEND_IP_Address $udp_port_src -> $C4_SEND_UDP_Port\n"if($debug == 12);
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						#00:04:22.058 0000001D 01000079 0000 0329 0079 0100 2375 C20A 0000 000A 0100 0000 0000 0210 00
						print FoutLog "C4 SEND : $secs.$msecs:$udp_data\n"if($debug == 3);
						#print FoutLog "Source :      $ip_src\t$udp_port_src\n";
						#print FoutLog "Destination : $ip_dest\t$udp_port_dest\n";
						if($udp_data =~/^4448(....)/ && $new_C4_SEND == 1){
							#print FoutLog "new XDH\n";
							$C4_SEND=$udp_data;
							$C4_SEND_length_in_char = (hex($1)+4)*2;
							print FoutLog "new C4 SEND length in char = $C4_SEND_length_in_char\n" if($debug == 3);
							<> if($debug == 3);
							#print FoutLog "C4 SEND:$C4_SEND\n";
							$new_C4_SEND = 0;
						}
						else{
							$C4_SEND=$C4_SEND.$udp_data;
							#print FoutLog "XDH:$XDH\n";
						}
						$C4_SEND_current_length = length($C4_SEND);
						print FoutLog "Current length : $C4_SEND_current_length\n" if($debug == 3);
						if($C4_SEND_current_length == $C4_SEND_length_in_char && $new_C4_SEND == 0){
							$new_C4_SEND = 1;
							$C4_SEND=substr($C4_SEND, 4, $C4_SEND_length_in_char-4);
							$C4_SEND =~s/^(.{4})(..)(.{6})/0000$1 01$3 /;
							# conversion minuscules en majuscules
							$C4_SEND = uc($C4_SEND);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_SEND "$heure:$minute:$seconde.$milli $C4_SEND\n";
							print FoutLog "$heure:$minute:$seconde.$milli $C4_SEND\n" if($debug == 3);
							<> if($debug == 3);
						}	
						# On memorise la longueur du message 
						# 
					}
					# c est un msg C4 recu
					if($ip_src eq $C4_RECEIVE_IP_Address && $udp_port_dest eq $C4_SEND_UDP_Port){
						print FoutLog "$ip_dest -> $C4_RECEIVE_IP_Address $udp_port_dest -> $C4_RECEIVE_UDP_Port\n" if ($debug == 2);
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						print FoutLog "C4 RECEIVE  :$secs.$msecs:$udp_data\n" if($debug == 2);
						#print FoutLog "Source :      $ip_src\t$tcp_port_src\n";
						#print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n";
						if($udp_data =~/^4844(....)/ && $new_C4_RECEIVE == 1){
							#print FoutLog "new C4_RECEIVE\n";
							$C4_RECEIVE=$udp_data;
							$C4_RECEIVE_length_in_char = (hex($1)+4)*2;
							print FoutLog "new C4 RECEIVE length in char = $C4_RECEIVE_length_in_char\n" if($debug == 2);
							<> if($debug == 2);
							$new_C4_RECEIVE = 0;
							#print FoutLog "C4 RECEIVE:$C4_RECEIVE\n";
						}
						else{
							$C4_RECEIVE=$C4_RECEIVE.$udp_data;
						}
						$C4_RECEIVE_current_length = length($C4_RECEIVE);
						print FoutLog "Current length : $C4_RECEIVE_current_length\n" if($debug == 2);
						if($C4_RECEIVE_current_length == $C4_RECEIVE_length_in_char && $new_C4_RECEIVE == 0 ){
							$new_C4_RECEIVE = 1;
							$C4_RECEIVE=substr($C4_RECEIVE, 4, $C4_RECEIVE_length_in_char-4);
							$C4_RECEIVE =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							# conversion minuscules en majuscules
							$C4_RECEIVE = uc($C4_RECEIVE);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_RECEIVE "$heure:$minute:$seconde.$milli $C4_RECEIVE\n";
							print FoutLog "$heure:$minute:$seconde.$milli $C4_RECEIVE\n" if($debug == 2);
							<> if($debug == 2);
						}
					}
					# c est un msg de NAV RECV
					if($ip_dest eq $NAV_RECV_IP_Address && $udp_port_dest eq $NAV_RECV_UDP_Port){
						print "$ip_dest -> $NAV_RECV_IP_Address $udp_port_dest -> $NAV_RECV_UDP_Port\n" if ($debug == 12);
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						print "NAV_RECV  :$secs.$msecs:$udp_data\n" if($debug == 12);
						#print FoutLog "Source :      $ip_src\t$tcp_port_src\n";
						#print FoutLog "Destination : $ip_dest\t$tcp_port_dest\n";
						if($udp_data =~/^4844(....)/ && $new_NAV_RECV == 1){
							#print FoutLog "new C4_RECEIVE\n";
							$NAV_RECV=$udp_data;
							$NAV_RECV_length_in_char = (hex($1)+4)*2;
							print FoutLog "new NAV_RECV length in char = $NAV_RECV_length_in_char\n" if($debug == 12);
							<> if($debug == 12);
							$new_NAV_RECV = 0;
							#print FoutLog "C4 RECEIVE:$C4_RECEIVE\n";
						}
						else{
							$NAV_RECV=$NAV_RECV.$udp_data;
						}
						$NAV_RECV_current_length = length($NAV_RECV);
						print FoutLog "Current length : $NAV_RECV_current_length\n" if($debug == 12);
						if($NAV_RECV_current_length == $NAV_RECV_length_in_char && $new_NAV_RECV == 0 ){
							$new_NAV_RECV = 1;
							$NAV_RECV=substr($NAV_RECV, 4, $NAV_RECV_length_in_char-4);
							$NAV_RECV =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							# conversion minuscules en majuscules
							$NAV_RECV = uc($NAV_RECV);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutNAV_RECV "$heure:$minute:$seconde.$milli $NAV_RECV\n";
							print "$heure:$minute:$seconde.$milli $NAV_RECV\n" if($debug == 12);
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
	close FoutNAV_RECV;
	close FoutNAV_SEND;
	close FoutC4_SEND;
	close FoutC4_RECEIVE;
	close FoutSIMPLE_SERVER;
	close FoutSIMPLE_CLIENT;
	close FoutSIMPLEFIM;
	close FoutSIMPLEFOM;
	close FoutSIMPLE_L11_CLIENT;
	close FoutSIMPLE_L11_SERVER;
	close FoutSIMPLEJI;
	close FoutSLP;
	close FoutTI;
	close FoutLog;
	return 0;
}

sub getEtherParam{
	my $r_data = shift;
	my ($ether_dest,$ether_src,$ether_type,$ether_data) = unpack('H12H12H4a*',$$r_data);
	return ($ether_dest,$ether_src,$ether_type,$ether_data);
}

sub getIPParam{
	my $r_data = shift;
	my ($ip_type, $trash, $ip_total_length,$trash2,$ip_proto, $trash3, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = unpack('H2H2H4H10H2H4H2H2H2H2H2H2H2H2a*', $$r_data);
	return ($ip_type, $trash, $ip_total_length,$trash2,$ip_proto, $trash3, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data);
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
	



	
sub fom2Aladdin {
	my $Fom1MsgHeader = "04000001";
	my $time = shift;
	#print FoutLog "time : $time\n";
	my $fom = shift;
	if($fom =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;;
		if($BXM1 =~ /[08]2/){
		  # Calcul de la longueur du message Aladdin
		  my $bom = BOM::new(\$fom);
		  my $lengthFxm = $bom->getFOMLength();
		  $lengthFxm = (5+$lengthFxm*5)*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
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
	#print FoutLog "time : $time\n";
	my $fim = shift;
	if($fim =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print FoutLog "$FXM\n";
		#print FoutLog "C'est un FIM \n";
		if($BXM1 =~ /[08]2/){
		  #print FoutLog "C'est un FIM01 \n";
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
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
	#print FoutLog "time : $time\n";
	my $fom = shift;
	if($fom =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
  		my $isFOMTECH = 0;
    		 # FOM03
  		if($BXM1 =~ /[08]6/){
    			$FomMsgHeader = "04000003";
    			$isFOMTECH = 1;
    			#print FoutLog "$FXM\n";
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
		  #print FoutLog "$FXM \n";
		  # Suppression des FOM01 associés on suppose qu'il n'y a pas de FOM tech associé !
		  my $length = $lengthFxm*4;
		  $FXM = substr($FXM, 0, $length);
		  #print FoutLog "$FXM $length $lengthFxm \n";
		  #exit 0;
		  #<>;
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+6;
		  $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
		  # formattage des secondes ss.mmm
		  #$fom = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $FomMsgHeader $BXM2 $BXM1 $FXM";
		  $fom = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $FomMsgHeader $FXM";
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
	print FoutLog "time : $time\n" if( $debug == 9);
	my $fim = shift;
	if($fim =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print FoutLog "$FXM\n";
		#print FoutLog "C'est un FIM \n";
  		my $isFIMTECH = 0;
  		# FIM62
  		if($BXM1 =~ /fc/ ){
    			$FimMsgHeader = "0600003E";
    			$isFIMTECH = 1;
			print FoutLog "0600003E $FXM\n" if ($debug == 9);
			#exit 0 ;
  		}
 		 # FIM63
  		if($BXM1 =~ /fe/){
    			$FimMsgHeader = "0600003F";
    			$isFIMTECH = 1;
			print FoutLog "0600003F $FXM\n"if ($debug == 9);
			#exit 0;
  		}
  		if( $isFIMTECH ){
		  print FoutLog "C'est un FIM tech \n" if( $debug == 9);
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  $FXM =~ s/\s*//g;
		  my $length = $lengthFxm*4;
		  $FXM = substr($FXM, 0, $length);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+6;
		  $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
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
			#print FoutLog "true\n";
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

# fomLength la longueur du fom à partir du champ length de l'entête du fom
sub fomLength {
		my $r_fom = shift;
		my $bom = BOM::new($r_fom);
		my $length = $bom->getFOMLength();
		#print FoutLog "Longueur du FOM $length\n"; 
		return $length;
}

# fxmLength calcule la logueur du fim/fom à partir de la taille donnee par l'octet du BIM/BOM
sub fxmLength {
	my $r_fxm = shift;
	if($$r_fxm =~ /(..)(..)(.*)\s*/){
		my $BXM2 = $2 ;
		return hex($BXM2);
	}
	else {
		return -1;
	}
}

sub slp2Aladdin {
	my $SlpMsgHeader = "09000000"; # en réception de la SLP
	my $time = shift;
	#print FoutLog "time : $time\n";
	my $slp_msg = shift;
	#print FoutLog "tcp_data : $slp_msg\n";
	if($slp_msg =~ /(....)(....)(....)(......)(.*)/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $length = $1;
		my $code_prim = $2;
		my $num_seq = $3;
		my $res_h = $4;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $slp_msg=$5;
		# suppresion des blancs
		#$slp_msg =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$slp_msg =~ s/(....)/$1 /g;
		my $lengthSlpMsg = hex($length);
		# Calcul de la longueur du message Aladdin
		$lengthSlpMsg = $lengthSlpMsg+4;
		$lengthSlpMsg = Conversion::toHexaString($lengthSlpMsg, 8);
		# formattage des secondes ss.mmm
		$slp_msg = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthSlpMsg $SlpMsgHeader $length $code_prim $num_seq $res_h $slp_msg";
		#print FoutLog "$slp_msg\n";
		#<>;
		return $slp_msg;
	}
}

sub ti2Aladdin {
	my $tiMsgHeader = "08000000"; # en réception de la SLP
	my $time = shift;
	#print FoutLog "time : $time\n";
	my $ti_msg = shift;
	#print FoutLog "tcp_data : $ti_msg\n";
	if($ti_msg =~ /(....)(....)(....)(......)(.*)/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print FoutLog " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $length = $1;
		my $code_prim = $2;
		my $num_seq = $3;
		my $res_h = $4;
		#print FoutLog "BXM1 : $BXM1\n";
		#print FoutLog "BXM2 : $BXM2\n";
		my $ti_msg=$5;
		# suppresion des blancs
		#$ti_msg =~ s/\s//g;
		# séparation par paire d'octet XXXX XXXX ...
		$ti_msg =~ s/(....)/$1 /g;
		my $lengthSlpMsg = hex($length);
		# Calcul de la longueur du message Aladdin
		$lengthSlpMsg = $lengthSlpMsg+4;
		$lengthSlpMsg = Conversion::toHexaString($lengthSlpMsg, 8);
		# formattage des secondes ss.mmm
		$ti_msg = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthSlpMsg $tiMsgHeader $length $code_prim $num_seq $res_h $ti_msg";
		#print FoutLog "$ti_msg\n";
		#<>;
		return $ti_msg;
	}
}

sub conv2Time {
	my $chrono = shift;
	my $milli = 0;
	#print FoutLog "chron : $chrono \n";
	my $heure = int $chrono/3600;
	#print FoutLog "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);	
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	#print FoutLog "$heure $minute $seconde\n";
	$milli = int(($seconde-int($seconde))*1000);
	$seconde = int( $seconde);
	#print FoutLog "$heure $minute $seconde $milli\n";
	$heure = substr('00'.$heure, -2);
	#print FoutLog "$heure\n";
	$minute = substr('00'.$minute, -2);
	#print FoutLog "$minute\n";
	$seconde = substr('00'.$seconde, -2);
	$milli = substr('00'.$milli, -3);
	print FoutLog "$heure $minute $seconde $milli\n" if($debug == 1);
	return ($heure, $minute, $seconde, $milli);
}

sub extract_SIMPLE_Msg_Server (){
	my $length_in_hexa;
	$etatLectureSIMPLE_9 = 0;
	$SIMPLE_msg_9 = "";
	for my $i (0..$data_length_in_byte-1){
		# traitement 2 char par 2 char
        my $char = substr($tcp_data, $i*2, 2);
        #print FoutLog "$char, $i, $data_length_in_char\n" if($debug == 8);
 		# recherche du premier octet de synchro
		if($etatLectureSIMPLE_9 == 0) {
			if($char =~/49/){
				$SIMPLE_msg_9 .= $char;
				#print FoutLog " etatlecture = 1\n" if($debug == 8);
				$etatLectureSIMPLE_9 = 1;
			}
			next;
		}
		# recherche du 2ème octet de synchro trame
		if($etatLectureSIMPLE_9 == 1) {
			if($char =~ /36/){
				$SIMPLE_msg_9 .= $char;
				$etatLectureSIMPLE_9 = 2;
				#print FoutLog "passage a l'etat 2\n" if($debug == 8);
				#print FoutLog "$SIMPLE_msg_9\n" if($debug == 8);
				#<> if($debug == 8);
			}
			else {
				$SIMPLE_msg_9 = "";
				$etatLectureSIMPLE_9 = 0;
				#print FoutLog "retour a l'etat 0\n" if($debug == 6);
			}
			next;
		}
		# recherche du 1er octet de longueur
		if($etatLectureSIMPLE_9 == 2) {
			$length_in_hexa = $char;
			$SIMPLE_length_9 = hex($length_in_hexa);
			$length_in_hexa = Conversion::toHexaString($SIMPLE_length_9 + 4, 8);
			$SIMPLE_msg_9 .= $char;
			$etatLectureSIMPLE_9 = 4;
			#print FoutLog "passage a l'etat 4 \n" if($debug == 8);
			#print FoutLog "$SIMPLE_msg_9\n" if($debug == 8);
			#print FoutLog "SIMPLE_length_9 = $SIMPLE_length_9 \n" if($debug == 8);
			next;
		}
		# recherche du 2eme octet de longueur
		if($etatLectureSIMPLE_9 == 3) {
			$SIMPLE_length_9 .= $char;
            $SIMPLE_length_9 = hex($SIMPLE_length_9);
			$etatLectureSIMPLE_9 = 4;
			#print FoutLog "passage a l'etat 4 \n" if($debug == 8);
			#print FoutLog "$SIMPLE_msg_9 \n" if($debug == 8);
			#print FoutLog "SIMPLE_length_9 = $SIMPLE_length_9 \n" if($debug == 8);
 			next;
		}
		if($etatLectureSIMPLE_9 == 4) {
			$SIMPLE_msg_9 .= $char;
			if(length($SIMPLE_msg_9) == ($SIMPLE_length_9*2)){
				#	conversion minuscules en majuscules
				$SIMPLE_msg_9 = uc($SIMPLE_msg_9);
	      	}
	        #print FoutLog "etat 4 \n" if($debug == 9);
	       	#print FoutLog "Msg Client : $SIMPLE_msg_9 \n" if($debug == 8);
	     	next;
		}
	}
	my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
	print FoutLog "Msg Client : $chrono, $SIMPLE_msg_9 \n" if($debug == 8);
	#<>;
	#Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
	my $packetType = get_SIMPLE_packetType($SIMPLE_msg_9);
	print FoutLog " packet Type : $packetType\n";
	#<>;
	if($packetType == 0){
		decodeSIMPLE_L11($SIMPLE_msg_9);
	}
	if($packetType == 1){
		#Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
		my $SIMPLE_msg = decodeSIMPLE_L11(0, $SIMPLE_msg_9);
		$SIMPLE_msg = uc ($SIMPLE_msg);
		print FoutLog "SIMPLE msg client : $SIMPLE_msg" if($debug == 8);
		print FoutSIMPLEFOM "$heure:$minute:$seconde.$milli $SIMPLE_msg" ;
	}
	elsif ($packetType == 2) {
		my $MI = decodeSIMPLE_L11(0, $SIMPLE_msg_9); 
		print FoutLog "MI server : $MI\n" if($debug == 8);
		print FoutSIMPLE_L11_SERVER "$heure:$minute:$seconde.$milli $MI \n" if($MI ne "0") ;
		print FoutSIMPLE_SERVER "$heure:$minute:$seconde.$milli $length_in_hexa 1C000000 $SIMPLE_msg_9\n";
		#<>;
	}
	else {
		print "msg technique SIMPLE Server\n";
		print FoutLog "msg server SIMPLE technique\n";
		print FoutSIMPLE_SERVER "$heure:$minute:$seconde.$milli $length_in_hexa 1C000000 $SIMPLE_msg_9\n";
		#<>;
	}
}

sub extract_SIMPLE_Msg_Client (){
	my $length_in_hexa;
	$etatLectureSIMPLE_8 = 0;
	$SIMPLE_msg_8 = "";
	for my $i (0..$data_length_in_byte-1){
		# traitement 2 char par 2 char
        my $char = substr($tcp_data, $i*2, 2);
        #print FoutLog "$char, $i, $data_length_in_char\n" if($debug ==10);
 		# recherche du premier octet de synchro
		if($etatLectureSIMPLE_8 == 0) {
			if($char =~/49/){
				$SIMPLE_msg_8 .= $char;
				#print FoutLog " etatlecture = 1\n" if($debug ==10);
				$etatLectureSIMPLE_8 = 1;
			}
			next;
		}
		# recherche du 2ème octet de synchro trame
		if($etatLectureSIMPLE_8 == 1) {
			if($char =~ /36/){
				$SIMPLE_msg_8 .= $char;
				$etatLectureSIMPLE_8 = 2;
				#print FoutLog "passage a l'etat 2\n" if($debug ==10);
				#print FoutLog "$SIMPLE_msg_8\n" if($debug ==10);
				#<> if($debug ==10);
			}
			else {
				$SIMPLE_msg_8 = "";
				$etatLectureSIMPLE_8 = 0;
				#print FoutLog "retour a l'etat 0\n" if($debug == 6);
			}
			next;
		}
		# recherche du 1er octet de longueur
		if($etatLectureSIMPLE_8 == 2) {
			$length_in_hexa = $char;
			$SIMPLE_length_8 = hex($length_in_hexa);
			$length_in_hexa = Conversion::toHexaString($SIMPLE_length_8 + 4, 8);
			$SIMPLE_msg_8 .= $char;
			$etatLectureSIMPLE_8 = 4;
			#print FoutLog "passage a l'etat 4 \n" if($debug ==10);
			#print FoutLog "$SIMPLE_msg_8\n" if($debug ==10);
			#print FoutLog "SIMPLE_length_8 = $SIMPLE_length_8 \n" if($debug ==10);
			next;
		}
		# recherche du 2eme octet de longueur
		if($etatLectureSIMPLE_8 == 3) {
			$SIMPLE_length_8 .= $char;
            $SIMPLE_length_8 = hex($SIMPLE_length_8);
			$etatLectureSIMPLE_8 = 4;
			#print FoutLog "passage a l'etat 4 \n" if($debug ==10);
			#print FoutLog "$SIMPLE_msg_8 \n" if($debug ==10);
			#print FoutLog "SIMPLE_length_8 = $SIMPLE_length_8 \n" if($debug ==10);
 			next;
		}
		if($etatLectureSIMPLE_8 == 4) {
			$SIMPLE_msg_8 .= $char;
			if(length($SIMPLE_msg_8) == ($SIMPLE_length_8*2)){
				#	conversion minuscules en majuscules
				$SIMPLE_msg_8 = uc($SIMPLE_msg_8);
	      	}
	        #print FoutLog "etat 4 \n" if($debug == 9);
	       	#print FoutLog "Msg Client : $SIMPLE_msg_8 \n" if($debug ==10);
	     	next;
		}
	}
	my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
	print FoutLog "Msg Client : $chrono, $SIMPLE_msg_8 \n" if($debug ==10);
	#<>;
	#Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
	my $packetType = get_SIMPLE_packetType($SIMPLE_msg_8);
	print FoutLog " packet Type : $packetType\n";
	#<>;
	if($packetType == 0){
		decodeSIMPLE_L11($SIMPLE_msg_8);
	}
	if($packetType == 1){
		#Si la reference retournee n est pas nulle alors c est un msg SIMPLE de type 1 L16
		my $SIMPLE_msg = decodeSIMPLE_L11(1, $SIMPLE_msg_8);
		$SIMPLE_msg = uc ($SIMPLE_msg);
		print FoutLog "SIMPLE msg client : $SIMPLE_msg" if($debug ==10);
		print FoutSIMPLEFOM "$heure:$minute:$seconde.$milli $SIMPLE_msg" ;
	}
	elsif ($packetType == 2) {
		my $MI = decodeSIMPLE_L11(1, $SIMPLE_msg_8); 
		print FoutLog "MI client : $MI\n" if($debug ==10);
		print FoutSIMPLE_L11_CLIENT "$heure:$minute:$seconde.$milli $MI \n" if($MI ne "0") ;
		print FoutSIMPLE_CLIENT "$heure:$minute:$seconde.$milli $length_in_hexa 1D000000 $SIMPLE_msg_8\n";
		#<>;
	}
	else {
		print "msg technique SIMPLE Client\n";
		print FoutLog "msg client SIMPLE technique\n";
		print FoutSIMPLE_CLIENT "$heure:$minute:$seconde.$milli $length_in_hexa 1D000000 $SIMPLE_msg_8\n";
		#<>;
	}
}

sub get_SIMPLE_packetType(){
	my $Line = shift;
	#print FoutLog "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	print FoutLog "$Line\n";
		my @Entete = split (" ",$Line);
		print FoutLog "Sync : $Entete[0]$Entete[1]\n" if($debug == 9);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print FoutLog "$Length\n";		
		$Length = hex($Length);
		print FoutLog "Length = $Length\n"if($debug == 9);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print FoutLog "Seq_number = $Seq_number\n"if($debug == 9);
		my $Source_node = hex($Entete[6]);
		print FoutLog "Source node = $Source_node\n"if($debug == 9);
		my $Source_sub_node = hex($Entete[7]);
		print FoutLog "Source subnode = $Source_sub_node\n"if($debug == 9);
		my $Dest_node = hex($Entete[8]);
		print FoutLog "Dest node = $Dest_node\n"if($debug == 9);
		my $Dest_sub_node = hex($Entete[9]);
		print FoutLog "Dest_sub_node = $Dest_sub_node\n"if($debug == 9);
		my $Packet_size = hex($Entete[10]);	
		print FoutLog "Packet size = $Packet_size\n"if($debug == 9);
		my $Packet_type = hex($Entete[11]);
		print FoutLog "Packet type = $Packet_type\n"if($debug == 9);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print FoutLog "Transmit time = $Transit_time\n"if($debug == 9);	
		return $Packet_type;
}

sub decodeSIMPLE_L11 {
	my $client = shift;
	my $Line = shift;
	my $Msg_data ="";
	print FoutLog "decodeSIMPLE_L11 : $Line\n";
	#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print FoutLog "$Line\n";
	my @Entete = split (" ",$Line);
	my $num = $#Entete;
	#print FoutLog "num : $num\n";
	print FoutLog "Sync : $Entete[0]$Entete[1]\n" if($debug ==10 || $debug == 9);
	my $Length = "$Entete[3]"."$Entete[2]";
	#print FoutLog "$Length\n";		
	$Length = hex($Length);
		print FoutLog "Length = $Length\n"if($debug ==10 || $debug == 9);
	my $Seq_number = "$Entete[5]"."$Entete[4]";
	$Seq_number = hex ($Seq_number);
		print FoutLog "Seq_number = $Seq_number\n"if($debug ==10 || $debug == 9);
	my $Source_node = hex($Entete[6]);
		print FoutLog "Source node = $Source_node\n"if($debug ==10 || $debug == 9);
	my $Source_sub_node = hex($Entete[7]);
		print FoutLog "Source subnode = $Source_sub_node\n"if($debug ==10 || $debug == 9);
	my $Dest_node = hex($Entete[8]);
		print FoutLog "Dest node = $Dest_node\n"if($debug ==10 || $debug == 9);
	my $Dest_sub_node = hex($Entete[9]);
		print FoutLog "Dest_sub_node = $Dest_sub_node\n"if($debug ==10 || $debug == 9);
	my $Packet_size = hex($Entete[10]);	
		print FoutLog "Packet size = $Packet_size\n"if($debug ==10 || $debug == 9);
	my $Packet_type = hex($Entete[11]);
		print FoutLog "Packet type = $Packet_type\n"if($debug ==10 || $debug == 9);
	my$Transit_time = "$Entete[13]"."$Entete[12]";
	$Transit_time = hex($Transit_time);
		print FoutLog "Transmit time = $Transit_time\n"if($debug ==10 || $debug == 9);
	if($Packet_type == 2){
		my $Msg_sub_type = "$Entete[14]";
		$Msg_sub_type = hex($Msg_sub_type);
	  		print FoutLog "\tMsg_sub_type = $Msg_sub_type\n" if($debug ==10 || $debug == 9);
	  	my $PU_Number= "$Entete[15]";
	  	$PU_Number = hex($PU_Number);
	  		print FoutLog "\tPU Number = $PU_Number\n" if($debug ==10 || $debug == 9);
	  	my $Word_Count= "$Entete[16]";
	  	$Word_Count = hex($Word_Count);
	  		print FoutLog "\tWord_Count = $Word_Count\n" if($debug ==10 || $debug == 9);
	  	my $Sequence_Number = "$Entete[17]";
	  		print FoutLog "\tSequence Number = $Sequence_Number\n" if($debug ==10 || $debug == 9);
	  	if (($Msg_sub_type  == 2 || $Msg_sub_type  == 0 || $Msg_sub_type  == 4) && ($Word_Count != 0)) {	
	  		$Word_Count = $Word_Count /2; # nombre d'octet
	  		my $i = 0;
		  		while ( $i != $Word_Count ){
	  				#print FoutLog "$i $i\n";
	  				$Msg_data = "$Entete[20 + $i*4]"."$Entete[19 + $i*4]"."$Entete[18 + $i*4]"."$Msg_data";
	  				#<>;
	  				$i++;
	  		} 
	  		$Msg_data = "0000000A 0B000001 " . "$Msg_data" if($client) ;
	  		$Msg_data = "0000000A 0A000001 " . "$Msg_data" if(! $client) ;
	  		print FoutLog "Msg_Data : $Msg_data\n"; 
	  		return $Msg_data;
	  	}
	  	elsif ($Msg_sub_type  == 1 ) {
	  		my $Msg_data = "00000004 0B000400" if($client);
	  		$Msg_data = "00000004 0A000400" if(! $client);
	  		return $Msg_data;
	  	}
	  	else {
	  		return 0;
	  	}
	  	# on ajoute un message de start (commenté)
	  	# on decode les message mi
	  	# si le sub type == 0 message intermediaire
	  	# on decode les message mi
	  	# si le sub type == 4 message de stop
	  	# on ajoute un message de stop (commenté)
	  	#my $Msg_data= substr($Packet_header_data,28);
	  	#print FoutLog "\tMsg_data = $Msg_data\n"if($debug == 9);
	  	#$Msg_data =~ s/(....)$//;
	  	
	}
	
	else {
		return $Line;
	}
	#<>;
	return 0;
}

sub decodeSIMPLEFOM {
	my $Line = shift;
	#print FoutLog "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	print FoutLog "$Line\n";
		my @Entete = split (" ",$Line);
		print FoutLog "Sync : $Entete[0]$Entete[1]\n" if($debug == 6);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print FoutLog "$Length\n";		
		$Length = hex($Length);
		print FoutLog "Length = $Length\n"if($debug == 6);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print FoutLog "Seq_number = $Seq_number\n"if($debug == 6);
		my $Source_node = hex($Entete[6]);
		print FoutLog "Source node = $Source_node\n"if($debug == 6);
		my $Source_sub_node = hex($Entete[7]);
		print FoutLog "Source subnode = $Source_sub_node\n"if($debug == 6);
		my $Dest_node = hex($Entete[8]);
		print FoutLog "Dest node = $Dest_node\n"if($debug == 6);
		my $Dest_sub_node = hex($Entete[9]);
		print FoutLog "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
		my $Packet_size = hex($Entete[10]);	
		print FoutLog "Packet size = $Packet_size\n"if($debug == 6);
		my $Packet_type = hex($Entete[11]);
		print FoutLog "Packet type = $Packet_type\n"if($debug == 6);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print FoutLog "Transmit time = $Transit_time\n"if($debug == 6);
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print FoutLog "$Line\n$Packet_header_data\n"if($debug == 6);
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print FoutLog "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print FoutLog "\tRC_flag = $RC_flag\n"if($debug == 6);
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print FoutLog "\tNet_number= $Net_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print FoutLog "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  	print FoutLog "\tNPG_number = $NPG_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  	print FoutLog "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
		  	my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  	print FoutLog "\tSTN = $STN\n"if($debug == 6);
		  	my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  	print FoutLog "\tWord_count = $Word_count\n"if($debug == 6);
		  	my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  	print FoutLog "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		  	my $Msg_data= substr($Packet_header_data,28);
		  	print FoutLog "\tMsg_data = $Msg_data\n"if($debug == 6);
		  	$Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    print FoutLog "\t\t$Msg_data\n"if($debug == 6);
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    print FoutLog "\t\t$Msg_data\n"if($debug == 6);
		    my $lengthFxm = $Word_count*2+4+10;
		    $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
		    my $STN = Conversion::toHexaString($STN,4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number,4),-4,2);
	        my $NPG_number_low = substr(Conversion::toHexaString($NPG_number,4),-2,2);
	        print FoutLog "NPG High = $NPG_number_high; NPG Low = $NPG_number_low \n";
		    my $Msg_data= "0000 $STN $NPG_number_low$NPG_number_high 0000 0000"." $Msg_data";
		    print FoutLog "\t\t$Msg_data\n"if($debug == 6);
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
	#print FoutLog "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print FoutLog "$Line\n";
		my @Entete = split (" ",$Line);
		print FoutLog "Sync : $Entete[0]$Entete[1]\n"if($debug == 6);
		my $Length = "$Entete[3]"."$Entete[2]";
		#print FoutLog "$Length\n";		
		$Length = hex($Length);
		print FoutLog "Length = $Length\n"if($debug == 6);
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print FoutLog "Seq_number = $Seq_number\n"if($debug == 6);
		my $Source_node = hex($Entete[6]);
		print FoutLog "Source node = $Source_node\n"if($debug == 6);
		my $Source_sub_node = hex($Entete[7]);
		print FoutLog "Source subnode = $Source_sub_node\n"if($debug == 6);
		my $Dest_node = hex($Entete[8]);
		print FoutLog "Dest node = $Dest_node\n"if($debug == 6);
		my $Dest_sub_node = hex($Entete[9]);
		print FoutLog "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
		my $Packet_size = hex($Entete[10]);	
		print FoutLog "Packet size = $Packet_size\n"if($debug == 6);
		my $Packet_type = hex($Entete[11]);
		print FoutLog "Packet type = $Packet_type\n"if($debug == 6);
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print FoutLog "Transmit time = $Transit_time\n"if($debug == 6);
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print FoutLog "$Line\n$Packet_header_data\n"if($debug == 6);
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print FoutLog "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print FoutLog "\tRC_flag = $RC_flag\n"if($debug == 6);
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print FoutLog "\tNet_number= $Net_number\n"if($debug == 6);
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print FoutLog "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print FoutLog "\tNPG_number = $NPG_number\n"if($debug == 6);
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print FoutLog "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print FoutLog "\tSTN = $STN\n"if($debug == 6);
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print FoutLog "\tWord_count = $Word_count\n"if($debug == 6);
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print FoutLog "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		  my $Msg_data= substr($Packet_header_data,28);
		  print FoutLog "\tMsg_data = $Msg_data\n"if($debug == 6);
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print FoutLog "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    #print FoutLog "\t\t$Msg_data\n";
		    my $lengthFxm = $Word_count*2+4+16;
		    $lengthFxm = Conversion::toHexaString($lengthFxm, 8);
		    my $STN = substr(Conversion::toHexaString($STN, 4),-4,4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number, 4),-4,2);
	        my $NPG_number_low = substr(Conversion::toHexaString($NPG_number, 4),-2,2);
		    my $Msg_data= "0000 0000 0000 0000 0000 0000 $NPG_number_low$NPG_number_high $STN"." $Msg_data";
		    #print FoutLog "\t\t$Msg_data\n";
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
	#print FoutLog "$Line\n";
	#$Line = s/\s//g;
	$$r_Line =~ s/(..)/$1 /g;
	#print FoutLog "$Line\n";
	my @Entete = split (" ",$$r_Line);
	print FoutLog "Sync : $Entete[0]$Entete[1]\n"if($debug == 6);
	my $Length = "$Entete[3]"."$Entete[2]";
	#print FoutLog "$Length\n";		
	$Length = hex($Length);
	#print FoutLog "Length = $Length\n";
	my $Seq_number = "$Entete[5]"."$Entete[4]";
	$Seq_number = hex ($Seq_number);
	print FoutLog "Seq_number = $Seq_number\n"if($debug == 6);
	my $Source_node = hex($Entete[6]);
	print FoutLog "Source node = $Source_node\n";
	my $Source_sub_node = hex($Entete[7]);
	print FoutLog "Source subnode = $Source_sub_node\n"if($debug == 6);
	my $Dest_node = hex($Entete[8]);
	print FoutLog "Dest node = $Dest_node\n"if($debug == 6);
	my $Dest_sub_node = hex($Entete[9]);
	print FoutLog "Dest_sub_node = $Dest_sub_node\n"if($debug == 6);
	my $Packet_size = hex($Entete[10]);	
	print FoutLog "Packet size = $Packet_size\n"if($debug == 6);
	my $Packet_type = hex($Entete[11]);
	print FoutLog "Packet type = $Packet_type\n"if($debug == 6);
	my$Transit_time = "$Entete[13]"."$Entete[12]";
	$Transit_time = hex($Transit_time);
	print FoutLog "Transmit time = $Transit_time\n"if($debug == 6);
	if($Packet_type == 1){
		$$r_Line =~ s/\s*//g;
		my $Packet_header_data = substr($$r_Line, 28);
		print FoutLog "$$r_Line\n$Packet_header_data\n"if($debug == 6);
		my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
	  	print FoutLog "\tMsg_sub_type = $Msg_sub_type\n"if($debug == 6);
	  	my $RC_flag= hex(substr($Packet_header_data,2,2));
	  	print FoutLog "\tRC_flag = $RC_flag\n";
	  	my $Net_number= hex(substr($Packet_header_data,4,2));
	  	print FoutLog "\tNet_number= $Net_number\n"if($debug == 6);
	  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
	  	print FoutLog "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n"if($debug == 6);
	  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
	  	print FoutLog "\tNPG_number = $NPG_number\n"if($debug == 6);
	  	my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
	  	print FoutLog "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n"if($debug == 6);
	  	my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
	  	print FoutLog "\tSTN = $STN\n"if($debug == 6);
	 	my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		print FoutLog "\tWord_count = $Word_count\n"if($debug == 6);
		my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		print FoutLog "\tLoopback_id = $Loopback_id\n"if($debug == 6);
		my $Msg_data= substr($Packet_header_data,28);
		print FoutLog "\tMsg_data = $Msg_data\n"if($debug == 6);
		$Msg_data =~ s/(....)$//;
		if($Msg_sub_type == 2){
			# espacement par mot de 16 bit
		    	$Msg_data =~ s/(....)/$1 /g;
		    	#print FoutLog "\t\t$Msg_data\n";
		    	# inversion des octets par mot de 16 bit
		    	$Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    	#print FoutLog "\t\t$Msg_data\n";
		    	my $lengthFxm = $Word_count*2+4+14;
		    	$lengthFxm = Conversion::toHexaString($lengthFxm, 8);
		    	my $STN = substr(Conversion::toHexaString($STN),-4,4);
		    	my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            	my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
			# Format JI message
			my $header_version = "0000";
			my $rx_mode = "0000";
		       	$rx_mode = "0002" if($NPG_number > 511);
		    	$Msg_data= "$header_version $rx_mode $STN $NPG_number_high$NPG_number_low FFFF 0000 0000 $Msg_data";
		    	#print FoutLog "\t\t$Msg_data\n";
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
