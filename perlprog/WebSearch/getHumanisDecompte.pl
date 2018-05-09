        use Net::FTP;
        
        my $ftp_serveur = "sante-espaceparticuliers.humanis.com";
        
        $ftp = Net::FTP->new("$ftp_serveur", Debug => 0)
          or die "Cannot connect to some.host.name: $@";
        print "Try to connect to $ftp_serveur\n";
        $ftp->login("anonymous",'-anonymous@')
          or die "Cannot login ", $ftp->message;
 #       $ftp->cwd("/pub")
 #         or die "Cannot change working directory ", $ftp->message;
 #       $ftp->get("that.file")
 #         or die "get failed ", $ftp->message;
        $ftp->quit;
        exit 0;