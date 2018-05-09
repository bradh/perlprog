#!/usr/bin/perl -w
 use IO::Socket;
 use Net::hostent;      # for OOish version of gethostbyaddr



 my ($host, $port, $kidpid, $handle, $line, $byte);

 unless (@ARGV == 5) { die "usage: $0 host1 port1 port2 port3 port4" }
 ($host1, $port1, $port2, $port3, $port4) = @ARGV;

 # Creation des serveurs 2, 3, 4                            
 #server Input
 $server2 = IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => $port2,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
 # server Spy Input
 $server3 = IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => $port3,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
 # server Spy Output
 $server4= IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => $port4,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
                                   
 die "can't setup server 2" unless $server2;
 die "can't setup server 3" unless $server3;
 die "can't setup server 4" unless $server4;
 #print "[Server $0 accepting clients]\n";
 


 	

 	
 # create a tcp connection to the specified host and port
 while(1){
 	print "trying to connect to server $host1 sur port $port1\n";
 	eval {
 		$client1 = IO::Socket::INET->new(Proto     => "tcp",
                                 PeerAddr  => $host1,
                                 PeerPort  => $port1)
               || die "can't connect to port $port1 on $host1: $!";
 	};
 	if($@ =~ /can't connect/){
 		next;
 	}

 	# Attente de la connextion du client TCP
 	print "Waiting for connection of client on port $port2\n";
 	$client2 = $server2->accept();
 	print "Accept client2 \n";
 	$client2->autoflush(1);
 	print $client2 "Welcome to $0;\n";
 	$hostinfo = gethostbyaddr($client2->peeraddr);
 	printf "[Connect from %s sur port %s]\n", $hostinfo, $port1;
 	
 	# Creation du Thread 1
 	die "can't fork: $!" unless defined($kidpid1 = fork());
	 # Thread T0 continue
 	if($kidpid1){
   		while (1){
 			die "can't fork: $!" unless defined($kidpid2 = fork());  
 			# Thread T0 continue
 			if($kidpid2){
 				my $cnx6 = 0;
 				while (1){
 					
 					# Cnx to server 6
 					eval {
 						if ( ! $cnx6){
 							$client6 = IO::Socket::INET->new(Proto     => "tcp",
                                 PeerAddr  => "localhost",
                                 PeerPort  => 22223) 
               				|| die "can't connect to port localhost on 22223: $!";
 						}
 					};	
 					if ( $@ !~ /can't connect/){
 						$cnx6 = 1;
 						#$client6->autoflush(1);
 						#print "Cnx interne 6 OK\n";
 					}
 					else {
 						#print "Cnx interne 6 KO\n";
 					}
        			# Lecture du server 
        			#eval {
        				if(sysread($client1, $byte2, 1) == 1) {
           					#print "$byte2\n";
           					syswrite STDOUT, $byte2;
           					syswrite $client2, $byte2;
           					syswrite $client6, $byte2 if ($cnx6);
        				}
        			#	die "no read";
        			#};
        			
        			#if ($@ =~ /no read/){
        				#close $client6;
        			#	print "$@\n";
        			#	last;
        			#}
        		}
        		kill("TERM", $kidpid2);   # send SIGTERM to child
        		last;
 			}
        	 # Thread T2
        	else {
        		
        		# Attente connexion to Spy input
        		print "Waiting for connection of client on port $port3\n";
 				$client31 = $server3->accept();
 				print "Accept client3 \n";
 				$client31->autoflush(1);
 				# ouverture du server 6
 				# server interne 6
 				$server61= IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => 22223,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
                die "can't setup server 6" unless $server61;
                # Attente connexion interne 6
        		print "Waiting for connection of client on port 22223\n";
 				$client61 = $server61->accept();
 				$client61->autoflush(1);
 				print "Accept client61 \n";
 				while (1){
 					#eval{
 						if(sysread($client61, $byte6, 1) == 1) {
           					#print "$byte2\n";
           					syswrite STDOUT, $byte6;
           					syswrite $client31, $byte6;
           			#		die "no read";
 						}
        			#};
        			#if ($@ =~ /no read/){
        			#	close $server61;
        			#	close $client61;
        			#	last;
        			#} 
        		}
        		
        	}
        }
        
        kill("TERM", $kidpid1);   # send SIGTERM to child
        
  	}
 	
  	# Thread T1
  	# cote client ; the else{} block runs only in the child process
  	else {
  			die "can't fork: $!" unless defined($kidpid3 = fork());  
 			# Thread T1 continue
 			if($kidpid3){
 				my $cnx5 = 0;
 				while (1){
 					# Cnx to server 5
 					eval {
 						if ( ! $cnx5){
 							$client5 = IO::Socket::INET->new(Proto     => "tcp",
                                 PeerAddr  => "localhost",
                                 PeerPort  => 22222) 
               				|| die "can't connect to port localhost on 22222: $!";
 						}
 					};	
 					if ( $@ !~ /can't connect/){
 						$cnx5 = 1;
 						#$client6->autoflush(1);
 						#print "Cnx interne 6 OK\n";
 					}
 					else {
 						#print "Cnx interne 6 KO\n";
 					}
  		   			#eval {
       				if(read($client2, $byte3, 1) == 1) {
           				#print "$byte2\n";
           				syswrite STDOUT, $byte3;
           				syswrite $client1, $byte3;
           				syswrite $client5, $byte3 if($cnx5);
           		#		die "no read";
       				}
       			#};
       			#if ($@ =~ /no read/){
       			#	print "$@\n";
       			#}
       		}
       		last;                # just in case
  		}
  		# Thread 1.1
  		else {
  			# Attente connexion to Spy input
        	print "Waiting for connection of client on port $port3\n";
 			$client41 = $server4->accept();
 			print "Accept client4 \n";
 			$client41->autoflush(1);
 				# ouverture du server 6
 				# server interne 6
 				$server51= IO::Socket::INET->new( Proto     => "tcp",
                                  LocalPort => 22222,
                                  Listen    => SOMAXCONN,
                                  Reuse     => 1);
                die "can't setup server 5" unless $server51;
                # Attente connexion interne 6
        		print "Waiting for connection of client on port 22222\n";
 				$client51 = $server51->accept();
 				$client51->autoflush(1);
 				print "Accept client51 \n";
 				while (1){
 					#eval{
 						if(sysread($client51, $byte5, 1) == 1) {
           					#print "$byte5\n";
           					syswrite STDOUT, $byte5;
           					syswrite $client41, $byte5;
           			#		die "no read";
 						}
        			#};
        			#if ($@ =~ /no read/){
        			#	close $server61;
        			#	close $client61;
        			#	last;
        			#} 
        		}
  		}
 	}
 }

sub titi {
	# Attente de la connexion ddu client SPY	
 			$client3 = $server3->accept();
 			print "Accept client3 \n";
 			$client3->autoflush(1);
 			print $client3 "Welcome to $0; type help for command list.\n";
 			$hostinfo = gethostbyaddr($client3->peeraddr);
 			printf "[Connect from %s]\n", $port3;
}

sub toto {
	# Attente de la connexion ddu client SPY	
 	$client4 = $server4->accept();
 	print "Accept client4 \n";
 	$client4->autoflush(1);
 	print $client4 "Welcome to $0; type help for command list.\n";
 	$hostinfo = gethostbyaddr($client4->peeraddr);
 	printf "[Connect from %s]\n", $port4;
}
