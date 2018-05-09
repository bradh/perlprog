#!/usr/bin/perl -w
 use IO::Socket;
 use Net::hostent;      # for OOish version of gethostbyaddr

 my $debug = 2;
 
 my $stream;

 my ($host, $port, $kidpid, $handle, $line, $byte);
 
 my $fom;
 my $bom = "";
 my $fom_length;
 my $fom_byte_received_nber=0;
 	my $fxm_id_h = 14;
	my $fxm_id_l = 9;
	my $fxm_length_h = 8;
	my $fxm_length_l = 0;

 my $fim;
 my $bim = "";
 my $fim_length;
 my $bim_byte_received_nber=0;
 my $cnx_mids;

 unless (@ARGV == 3) { die "usage: $0 host1 port1 port2" }
 ($host1, $port1, $port2) = @ARGV;

 # Creation du serveur                           
 #server Input
 $socket_dlip = IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => $port2,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
                                 
 die "can't setup server 2" unless $socket_dlip;
 
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
 	$cnx_mids->autoflush(1);
	#print $cnx_mids "Welcome to $0;\n";
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
           			#print "$byte\n";
           			my $bim = processed_bim($byte);
           			if($bim ne  '0'){
	           			syswrite STDOUT, $bim;
	           			syswrite $cnx_mids, $bim;
						print "fin ecriture socket mids \n";
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
           			#print "$byte2\n";
           			if($bom ne  '0'){
	           			syswrite STDOUT, $bom;          			
	           			syswrite $cnx_dlip, $bom;
           			}
       			}
       		};
       		if ($@ =~ /no read/){
       			close $cnx_mids;
       			#	print "$@\n";
       			last;
       		}
       	}
       		                # just in case
  	}
}

sub processed_bom {
	my $byte = shift;
	$fom_byte_received_nber += 1;
	print "fom byte received : $fom_byte_received_nber\n" if($debug);
	$fom = $fom . $byte;
	# reception de l entete du bom
	if($fom_byte_received_nber < 2){
		$bom = $bom .$byte;
	}
	if($fom_byte_received_nber == 2){
		# calcul le fom_id et sa longueur
		my $binairy_fom = unpack('B*', $fom);
		print "bin bom : $binairy_fom\n" if($debug);
		$fom_id = substr($binairy_fom,15-$fxm_id_h, $fxm_id_h-$fxm_id_l+1 );
		print "bin fom_id : $fom_id\n" if($debug);
		$fom_id = oct('0b'.$fom_id);
		$fom_length = substr($binairy_fom,15-$fxm_length_h, $fxm_length_h-$fxm_length_l+1 );
		print "bin fom_length : $fom_length\n" if($debug);
		$fom_length = oct('0b'.$fom_length);
		print "fom_id : $fom_id\n" if($debug);
		print "fom_length : $fom_length\n" if($debug);
		#mise à zero du fom
		$fom="";	
	}
	# si on a recu le fom entier
	my $toto = ($fom_length-1);
	print "longueur attendu : $toto\n";
	if( $fom_byte_received_nber == ($fom_length-1)){		
		#$fom = processed_fom($fom, $fom_id);
		$bom=$bom . $fom;
		$fom_byte_received_nber = 0	;
		return $bom;
	}
	else{
		return '0';
	}
	;
}

sub processed_bim {
	my $byte = shift;
	$bim_byte_received_nber += 1;
	my $hexa_byte = unpack('H*', $byte);
	print "hexa byte : $hexa_byte\n" if($debug);
	print "fim byte received : $bim_byte_received_nber\n" if($debug);
	my $binairy_bim = unpack('H*', $bim);
	print "hexa bim : $binairy_bim\n" if($debug);
	$bim = $bim . $byte;
	$binairy_bim = unpack('H*', $bim);
	print "hexa bim : $binairy_bim\n" if($debug);
	# reception de l entete du bim
	if($bim_byte_received_nber < 2){
		print " < 2\n";
		return '0';
	}
	if($bim_byte_received_nber == 2){
		print " == 2\n";
		# calcul le fim_id et sa longueur
		my $binairy_bim = unpack('B*', $bim);
		print "bin bim : $binairy_bim\n" if($debug);
		$fim_id = substr($binairy_bim,15-$fxm_id_h, $fxm_id_h-$fxm_id_l+1 );
		print "fim_id : $fim_id\n" if($debug);
		$fim_id = oct('0b'.$fim_id);
		$fim_length = substr($binairy_bim,15-$fxm_length_h, $fxm_length_h-$fxm_length_l+1 );
		print "fim_length : $fim_length\n" if($debug);
		$fim_length = oct('0b'.$fim_length);
		print "fim_id decimal : $fim_id\n" if($debug);
		print "fim_length decimal : $fim_length\n" if($debug);
		#mise à zero du fim
	}
	# si on a recu le fim entier
	print "longueur attendu : $fim_length\n" if($debug);
	
	if( $bim_byte_received_nber == ($fim_length+1)*2 && $bim_byte_received_nber > 2){
		print "fin reception bim \n";
		#$fim = processed_fim($fim, $fim_id);
		$fim_byte_received_nber = 0	;
		print "return bim : $bim\n";
		return $bim;
	}
	else{
		return '0';
	}
	;
}
sub processed_fom {
	my $fom_id = shift;
	if($fom_id == 4){
		
	}
}
