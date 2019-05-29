    #!/usr/bin/perl -w
    use strict;
    use IO::Socket;
    my ($host, $port, $kidpid, $handle, $line, $byte);
    my $byte_count = 0;

    unless (@ARGV == 2) { die "usage: $0 host port" }
    ($host, $port) = @ARGV;
	#($host, $port) = ("localhost", 2345);
    # create a tcp connection to the specified host and port
    while(1){
    	print "Try to connect to server $host on port $port\n";
    	sleep 1;
    	eval {
    		$handle = IO::Socket::INET->new(Proto     => "tcp",
                                    PeerAddr  => $host,
                                    PeerPort  => $port)
        	or die "can't connect to port $port on $host: $!";
    	};
    	next if($@ =~ /can't connect/);

    	$handle->autoflush(1);       # so output gets there right away
    	print STDERR "[Connected to $host:$port]\n";

    	# split the program into two processes, identical twins
    	die "can't fork: $!" unless defined($kidpid = fork());

    	# the if{} block runs only in the parent process
    	if ($kidpid) {
        	# copy the socket to standard output
        	while (1){
        		eval{
        			my $byte1;
        			$byte = read($handle, $byte1, 1) or die "no read";
        			#print "$byte1\n";
        			process_rxdata($byte);
        			syswrite STDOUT,  $byte1;
        		};
        		last if($@ =~ /no read/);
        	}
        	kill("TERM", $kidpid);   # send SIGTERM to child
    	}
    	# the else{} block runs only in the child proces

    	else {
    		my $i = 0;
        	# copy standard input to the socket
        	while (1){
        		$line = "Ici client from port $port $i\n";
        		$i += 1;
            	#print $handle $line;
            	print $line;
            	sleep 3;
        	}
        	exit(0);                # just in case
    	}
    }
    
    sub process_rxdata(){
    	my $byte = shift;
    	
    	while($byte_count < 4){
    		# calcul de la longueur
    		$message_length = $byte . $message_length ;
    		if ($byte_count == 3){
    			print "message length = $message_length\n";
    			exit 0;
    		}
    	}
    	while($byte_count > 3 && $byte_count < $message_length){
    		$message_data = $byte . $message_data;
    	}
    	if ( $byte_count = $message_length -1 && $byte_count > 3){
    		decode_message ($message_data);
    		$byte_count = 0;
    		$message_data = "";
    		$message_length = "";
    	}
    	else {
    		$byte_count += 1;
    	}
    }
    
    
    sub decode_message {
    	my $message_data = shift;
    	my ($spare, $time_tag_message, $category_id, $jreap_comp_message) = unpack('H4H2H8H4a*', $message_data );
    	print "category id = $category_id\n";
    	my ($jreap_in_out, $jre_designator_id,  $jreap_message) = unpack('H2H2a*', $jreap_comp_message );
    	print "jreap in out = $jreap_in_out\n";
    	print "jre designator id = $jre_designator_id\n";
    }
    	
