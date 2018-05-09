#!/usr/bin/perl -w
# proxy V1 pour le simulation de la saturation
 use IO::Socket;
 use Net::hostent;      # for OOish version of gethostbyaddr
# use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);
# use lib qw(G:/Tools/perlprog/lib);
 use lib qw(/h7_usr/sil2_usr/samptivq/tools/Scripts/admin/lib);
# use lib qw(D:/Users/t00283692/Documents/Mes\ outils\ personnels/perlprog/lib);
 use lib qw(../lib);
 
 use bxm_processing;
 use fom04_processing;
 use Conversion;

 my $debug = 1;
 
 my $stream;

 my ($host, $port, $kidpid, $handle, $line, $byte);
 
 my $fom;
 my $bom;
 my $fom_length = 0;
 my $fom_byte_received_nber=0;
 	my $fxm_id_h = 14;
	my $fxm_id_l = 9;
	my $fxm_length_h = 8;
	my $fxm_length_l = 0;

 my $fim;
 my $bim;
 my $fim_length = 0;
 my $fim_byte_received_nber=0;
 
 local $Commonly_Controlled_PGs_Transmission_Queue_Status = 0;
 local $fom04_151_input_file = "fom04_151.fom";

 unless (@ARGV == 3) { die "usage: $0 host1 port1 port2" }
 ($host1, $port1, $port2) = @ARGV;

 # lecture du fichier d'input fom04
 # creation et initialisation d'un tableau de hash contenant le chrono et la valeur 
 local @fom04_151;
 my ($start_sec, $start_min, $start_hour ) = localtime();
 my $start_chrono = Conversion::toChrono($start_hour,  $start_min, $start_sec, 0);
 open Fin, "<$fom04_151_input_file" or die "impossible ouvrir $fom04_151_input_file";
 while(<Fin>){
 	my $line = $_;
 	chomp $line;
	print "line $line\n";
 	if($line =~ /^(\d{2}):(\d{2}):(\d{2})\.\d{3}\s*Commonly_Controlled_PGs_Transmission_Queue_Status\s*=\s*(\d+)/){
 		my ($heure, $minute, $seconde, $common_PG_Tx_Queue_Status)= ($1, $2, $3, $4);
 		print"heure $heure\nminute $minute\nseconde $seconde\n Common_PG_TX_Queue_Status $common_PG_Tx_Queue_Status\n" if($debug);
 		my $chrono  = Conversion::toChrono($heure, $minute, $seconde, 0);
 		$chrono += $start_chrono ;
 		print " current chrono = $chrono\n" if($debug);
 		push @fom04_151, {'chrono' => $chrono,
 						  'Common_PG_TX_Queue_Status' => $common_PG_Tx_Queue_Status
 						}
 	}
 }
 close Fin;
 print "relecture tableau fom04 \n";
 foreach my $fom04 (@fom04_151){
 	print $fom04->{'chrono'} . "\n";
 	print $fom04->{'Common_PG_TX_Queue_Status'}. "\n";
 }
 	 # Creation du serveur                           
	 #server Input
	 $socket_dlip = IO::Socket::INET->new( Proto     => "tcp",
	                                  LocalPort => $port2,
	                                  Listen    => SOMAXCONN,
	                                  Reuse     => 1);
	                                 
	 die "can't setup server 2" unless $socket_dlip;
	 $socket_dlip->autoflush(1);
	 
	 #print "[Server $0 accepting clients]\n";
	 # create a tcp connection to the specified host and port
	 while(1){
	 	# Attente de la connextion du client TCP
	 	print "Waiting for connection of client on port $port2\n";
	 	$cnx_dlip = $socket_dlip->accept();
	 	print "Accept client dlip\n";
	 	$cnx_dlip->autoflush(1);
	 	#print $cnx_dlip "Welcome to $0;\n";
	 	$hostinfo = gethostbyaddr($cnx_dlip->peeraddr);
	 	printf "[Connect from %s sur port %s]\n", $hostinfo, $port1;
	 	
	 	# Tentative de connexion to remote server
	 	print "trying to connect to server $host1 sur port $port1\n";
	 	eval {
	 		$cnx_mids = IO::Socket::INET->new(Proto     => "tcp",
	                                 PeerAddr  => $host1,
	                                 PeerPort  => $port1)
	               || die "can't connect to port $port1 on $host1: $!";
	 	};
	 	
	 	if($@ =~ /can't connect/){
	 		next;
	 	}
	 	$cnx_mids->autoflush();
	 	# Creation du Thread 
	 	die "can't fork: $!" unless defined($kidpid = fork());
		# Thread T0 continue
	 	if($kidpid){
	 		my $byte;
	   		while (1){
	 			# Thread T0 continue					
	 			# Communication DLIP vers MIDS (FIM)
	        	eval {
	        		if(sysread($cnx_dlip, $byte, 1) == 1) {
	           			my $bim = processed_bim($byte);
					#print "waiting to complete FIM...\n";
	           			if($bim ne '0'){
		           			print "transmitting FIM...\n";
		           			syswrite $cnx_mids, $bim;
							
	           			}
	        		}
		       		if ($@ =~ /no read/){
	        			close $cnx_dlip;
	        			#print "$@\n";
	        			last;
	        		}   
	      		};		
	   		} 
	   		kill("TERM", $kidpid);   # send SIGTERM to child 
	  	}	
	  	# Thread T1
	  	# cote client ; the else{} block runs only in the child process
	  	# Communication MIDS vers DLIP (FOM)
	  	else {
	  		my $byte;
	  		while (1){
	  			# Thread T1 continue			
	  		   	eval {
	       			if(sysread($cnx_mids, $byte, 1) == 1) {      				
	           			my $bom = processed_bom($byte);
	           			#print "waiting to complete FOM...\n";
	           			if($bom ne  '0'){
		           			print "transmitting FOM...\n";      			
		           			syswrite $cnx_dlip, $bom;
	           			}
	       			}
	       			if ($@ =~ /no read/){
	       				close $cnx_mids;
	       				#	print "$@\n";
	       				last;
	       			}
	       		};
	       		                # just in case
	  		}
		}
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
		#	$hexa_bom = substr($hexa_bom, 0, -8, 4, $PG_TX_status);
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
