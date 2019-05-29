#!/usr/bin/perl -w
# S. Mouchot le 8/11/17
# proxy_MIDS_V5.pl permet une reconnexion automatique à une resource MIDS sans perte de la connexion hôte
# (pas de détection de la coupure avec la ressource MIDS)
 
use strict;

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);
use lib qw(/home/stephane/Informatique/perlprog_repo/perlprog/proxy_MIDS/lib);
use lib qw(./lib);
use lib qw(../lib);

use threads;
use threads::shared;

#use POSIX ":sys_wait_h"; # for nonblocking read
use IO::Socket;
use IO::Socket::INET;
use IO::Select;
use bxm_processing;
use fom04_processing;
use Conversion;
 
my $fom;
my $fom_id;
my $fom_length = 0;
my $bom;
my $bom_id;
my $bom_length = 0;
my $bom_byte_received_nber=0;
my $fxm_id_h = 14;
my $fxm_id_l = 9;
my $fxm_length_h = 8;
my $fxm_length_l = 0;

my $fim;
my $fim_id;
my $fim_length = 0;
my $bim;
my $bim_id;
my $bim_length = 0; 
my $bim_byte_received_nber=0;

my $fim55;
my $fim56;

my $Commonly_Controlled_PGs_Transmission_Queue_Status = 0;
my $fom04_151_input_file = "fom04_151.fom";
my @fom04_151;
    
my %children;

my $socket_dlip;
my $child_dead = 0;
my ($host, $port, $kidpid, $line, $byte);

my $cnx_dlip;
my $cnx_mids;
my $first_mids_cnx = 1;

unless (@ARGV == 3) { die "usage: $0 host1 port1 port2" }
my ($host1, $port1, $port2) = @ARGV;

# definition des signaux
$SIG{INT} = \&got_int;
$SIG{ALRM} = sub { die "timeout" };

# initialisation de la variable (au départ le kid n'est pas lance)
my $kidAlive = 0;


# initialisation de la variable testant la recpetion du FOM03
my $fom03Present = 1;

my $fom03Received = 0;

my $selection = IO::Select->new();

# ouverture du serveur vers DLIP
open_dlip_cnx();
print "cnx dlip $cnx_dlip OK\n";

open_mids_cnx();
print "cnx mids $cnx_mids OK\n";

$first_mids_cnx = 0;
my @ready;
#print "enter loop select\n";
while(@ready = $selection->can_read()) {
	#print "read ready\n";
	foreach my $handle (@ready) {
		#print "handle : $handle\n";
		if( $handle == $cnx_mids ) {	
			read_mids_cnx();
		}
		if( $handle == $cnx_dlip ) {
			read_dlip_cnx();
		}
	}
		#print "fin handle\n";
	#}
	#else{
	#	$selection->remove($cnx_mids);
	#	$cnx_mids->close;
	#	print "cnx mids closed\n";
	#	#exit 0;
	#}
		
}

print "fin du programme $0\n";
exit 0;

while(1){
	eval {
		alarm(2);		    
	    #print "waiting 2s...\n";
	    sleep 10;
	    alarm(0);
	};
	if ($@ =~ /timeout/) {
    	#print "check FOM03\n";
    	if($fom03Received){
    		$fom03Present = 1;
    		$fom03Received = 0;
    	}
    	else{
    		$fom03Present = 0;
    		$fom03Received = 1;
    	}  			                            # timed out; do what you will here
		#print "timeout 3s\n";
	}
    else {
        alarm(0);           # clear the still-pending alarm
        die;                # propagate unexpected exception
    } 
    alarm(0);	
}
 
sub got_int {
	print " I'm got interrupt, bye !\n";
	exit 0;
}

# Creation du serveur                           
#server Input

sub open_dlip_cnx{
		$socket_dlip = IO::Socket::INET->new( Proto     => "tcp",
	                                  LocalPort => $port2,
	                                  Listen    => SOMAXCONN,
	                                  Reuse     => 1);		                                 
		die "can't setup server 2" unless $socket_dlip;
		print "[Waiting DLIP connection ]\n";
		$cnx_dlip = $socket_dlip->accept();	
		print "[Accept client dlip]\n";
		$cnx_dlip->autoflush(1);
		print "[DLIP connected on port $port2]\n";   
		$selection->add($cnx_dlip);
}

sub read_dlip_cnx {	
		eval {
			sysread($cnx_dlip, my $byte, 1) or die "no read";
			#print "dlip -> mids $byte\n";
			my $bim = processed_bim($byte);
           		#print "waiting to complete FIM...\n";
           		if($bim ne  '0'){
           			$fim55 = $bim if($fim_id == 55);
           			$fim56 = $bim if($fim_id == 56);
	           		print "transmitting FIM $fim_id...\n";      			
	           		syswrite $cnx_mids, $bim;
	           		#$cnx_mids->send($byte);
           		}
		};
		if($@ =~ /no read/){
			print "close dlip cnx \n";
			#$selection->remove($cnx_mids);
			close_mids_cnx();
		}

}
			
sub close_dlip_cnx {
	$selection->remove($cnx_dlip);
	close $cnx_dlip;
	close $socket_dlip;
	print "connection dlip closed, non read\n";
}
		
sub open_mids_cnx {
	print "[Try to connect to MIDS on host $host1 and port $port1]\n";
	while(1){		
		eval {
			$cnx_mids = IO::Socket::INET->new(Proto     => "tcp",
	                                    PeerAddr  => $host1,
	                                    PeerPort  => $port1)
			|| die "can't connect to port $port1 on $host1: $!";							
	 	};
		if($@ =~ /can't connect/){
			print "connection mids not OK\n";
			next;
		}
		else {
			#print "connection $cnx_mids OK ?\n";
			$selection->add($cnx_mids);
			$cnx_mids->autoflush();       # so output gets there right away
			print "[Connected to MIDS $cnx_mids $host1:$port1]\n";
			last;
		}
	}
	if(! $first_mids_cnx){
		eval {
			print "transmitting FIM55...\n";
	        	syswrite $cnx_mids, $fim55 or die "no write";
		};
		if($@ =~ /no write/){
			print "close mids cnx \n";
			close_mids_cnx();
			open_mids_cnx();
		}
		eval{
			print "receiving FOM58...\n";
			my $bom = 0;
			while( $bom eq '0'){
				my $byte1;
				sysread($cnx_mids, $byte1, 1) or die "no read";
				$bom = processed_bom($byte1);
			}
		};
		if($@ =~ /no read/){
			print "close mids cnx \n";
			close_mids_cnx();
			open_mids_cnx();
		}
		eval {
			print "transmitting FIM56...\n";
	        	syswrite $cnx_mids, $fim56 or die "no write";
		};
		if($@ =~ /no write/){
			print "close mids cnx \n";
			close_mids_cnx();
			open_mids_cnx();
		}
		eval{
			print "receiving FOM59...\n";
			my $bom = 0;
			while( $bom eq '0'){
				my $byte1;
				sysread($cnx_mids, $byte1, 1) or die "no read";
				$bom = processed_bom($byte1);
			}
		};
		if($@ =~ /no read/){
			print "close mids cnx \n";
			close_mids_cnx();
			open_mids_cnx();
		}
	}
}

sub read_mids_cnx {
		eval{
			my $byte1;
			sysread($cnx_mids, $byte1, 1) or die "no read";
			my $bom = processed_bom($byte1);
			#print "waiting to complete FOM...\n";
           		if($bom ne '0'){
           			print "transmitting FOM $fom_id...\n";
	           		syswrite $cnx_dlip, $bom;
				#$cnx_dlip->send($bom);
           		}			
		};
		if($@ =~/no read/){
			print "close mids cnx \n";
			#$selection->remove($cnx_mids);
			close_mids_cnx();
			open_mids_cnx();
			
		}
}

sub close_mids_cnx {
	$selection->remove($cnx_mids);
	close $cnx_mids;
	print "connection mids closed, non read\n";
}

sub processed_bom {
	my $byte = shift;
	$bom_byte_received_nber += 1;
	my $debug = 0;
	$bom = '' if($bom_byte_received_nber == 1 );
	#print "bom byte received : $bom_byte_received_nber\n" if($debug);
	my $hexa_byte = unpack('H2', $byte);
	#print "byte en hexa  = $hexa_byte \n";	
	#print "byte in binary = ". unpack('B*', $byte) ."\n";
	$bom = $bom . $byte;
	#print "concactenation du bom " . unpack('B*', $bom) . "\n";

	if($bom_byte_received_nber == 2){
		# calcul le fom_id et sa longueur
		$fom_id = bxm_processing::get_fxm_id($bom);
		$fom_length = bxm_processing::get_fxm_length($bom);
		print "bin fom_length : $fom_length\n" if($debug);
		print "receiving fom $fom_id\n" if($debug);
		print "longueur attendue = $fom_length\n" if($debug);
	}
	# si on a recu le bom entier
	#my $toto = ($fom_length-1);
	#print "longueur attendu : $toto\n";
	if( $bom_byte_received_nber == ($fom_length+1)*2){		
		#$fom = processed_fom($bom, $fom_id);
		$bom_byte_received_nber = 0	;
		print "concactenation du bom " . unpack('B*', $bom) . "\n" if($debug);
		$bom = processed_fom($bom, $fom_id);
		return $bom;
	}
	else{
		return '0';
	}
}

sub processed_fom {
	my $bom = shift;
	my $fom_id = shift;
	my $debug = 1;
	if($fom_id == 3){
		print "processing fom03...\n" if($debug);
		$fom03Received = 1;
	}
	if($fom_id == 4){
		print "processing fom04...\n" if($debug);
		# extract fxm from bxm
		my $fom04 = bxm_processing::extract_fxm($bom);
		print "fom04 " . unpack('H*', $fom04) . "\n" if($debug);
		# creation d'un fom04
		fom04_processing::create($fom04);
		# check du starting data word
		my $starting_data_word_value = fom04_processing::get_field_value("starting_data_word");
		print"starting data word = $starting_data_word_value\n" if($debug);
		if($starting_data_word_value == 151){
			# on recupere la valeur du status
			print "*** commonly controlled PG TX Queue Status = $Commonly_Controlled_PGs_Transmission_Queue_Status \n"if($debug);
			my $PG_TX_status = get_current_pg_tx_status();
			print "*** curent Queue Status : $PG_TX_status\n"if($debug);
			$PG_TX_status = pack('n', $PG_TX_status);
			$PG_TX_status = unpack('H4', $PG_TX_status);
			print "*** curent Queue Status hexa : $PG_TX_status\n"if($debug);
			# on remplace le status dans le fom04 (dernier mot) methode a l arrache
			my $hexa_bom = unpack('H*', $bom);
			print "hexa bom : $hexa_bom\n" if($debug);
			substr($hexa_bom, -4, 4, $PG_TX_status);
			print "hexa bom modified : $hexa_bom\n"if($debug);
			$bom = pack('H*', $hexa_bom);
			$hexa_bom = unpack('H*', $bom);
			print "hexa bom (verif) : $hexa_bom\n"if($debug);
		}		
	}
	return $bom;
}

sub processed_bim {
	my $byte = shift;
	my $debug = 0;
	$bim_byte_received_nber += 1;
	$bim = '' if($bim_byte_received_nber == 1 );
	my $hexa_byte = unpack('H2', $byte);
	#print "bim byte received : $bim_byte_received_nber\n" if($debug);
	#print "byte en hexa  = $hexa_byte \n"if($debug);
	#print unpack('B*', $bim) ."\n"if($debug);
	$bim = $bim . $byte;
	#print "concactenation du bim " . unpack('B*', $bim) . "\n" if($debug);
	
	if($bim_byte_received_nber == 2){
		$fim_id = bxm_processing::get_fxm_id($bim);
		$fim_length = bxm_processing::get_fxm_length($bim);
		print "receiving fim $fim_id\n"if($debug);
		print "longueur attendue = $fim_length\n"if($debug);
	}
	# si on a recu le bim entier
	if( $bim_byte_received_nber == ($fim_length + 1)*2){	
		print "concactenation du bim " . unpack('B*', $bim) . "\n"if($debug);	
		$bim_byte_received_nber = 0	;
		return $bim;
	}
	else{
		return '0';
	}
}

sub process_rxdata {
    	my $byte = shift;
    	print "Client receiving : ";
    	syswrite STDOUT,  $byte;
    	print "\n";   	
}

sub get_current_pg_tx_status {
 	# Thread T2 continue mise 
 		my ($sec, $min, $hour ) = localtime();
 		my $current_chrono = Conversion::toChrono($hour, $min, $sec, 0);
 		print" execute fom04 simulation\n";
 		print "$current_chrono\n";
 		my $previous_Commonly_Controlled_PGs_Transmission_Queue_Status = 72;
 		foreach my $fom04 (@fom04_151) {					
 			my $chrono = $fom04->{'chrono'};
 			my $common_PG_Tx_Queue_Status = $fom04->{'Common_PG_TX_Queue_Status'};
 			#print "$chrono : $common_PG_Tx_Queue_Status \n";
 			if($current_chrono < $chrono ){
 				$Commonly_Controlled_PGs_Transmission_Queue_Status = $previous_Commonly_Controlled_PGs_Transmission_Queue_Status;
 				#print "Current PG TX status : $Commonly_Controlled_PGs_Transmission_Queue_Status\n";
 				last;
 			}
 			# sauvegarde de la precedente valeur
 			$previous_Commonly_Controlled_PGs_Transmission_Queue_Status = $common_PG_Tx_Queue_Status;
 		}
 		return $Commonly_Controlled_PGs_Transmission_Queue_Status;
 	}
