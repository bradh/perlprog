package DataStructureLink;
my @link_tab;
my @jrep_tab;
my (@ip_protocol) = ("TCP", "UDP");

sub addLink {
	my $indice_links = scalar @link_tab;
	$link_tab[$indice_links]->{'link_id'} = "000";
	$link_tab[$indice_links]->{'jrep1'} = "JREP1";	
	$link_tab[$indice_links]->{'sender_id1'} = "00000";
	$link_tab[$indice_links]->{'ip_cnx_type1'} = "SERVER";
	$link_tab[$indice_links]->{'ip_address1'} = "000.000.000.000";
	$link_tab[$indice_links]->{'tcp_port1'} = "00000";
	$link_tab[$indice_links]->{'ip_protocol1'} = "TCP";
	$link_tab[$indice_links]->{'jrep2'} = "JREP2";	
	$link_tab[$indice_links]->{'sender_id2'} = "00000";
	$link_tab[$indice_links]->{'ip_cnx_type2'} = "CLIENT";
	$link_tab[$indice_links]->{'ip_address2'} = "000.000.000.000";
	$link_tab[$indice_links]->{'tcp_port2'} = "00000";
	$link_tab[$indice_links]->{'ip_protocol2'} = "TCP";
	return 0;
}

sub initializeLinksTab {
	$jrep_tab = shift;
	foreach  $jrep (@$jrep_tab) {
		my $ip_link_tab = DataStructureXML::getIpLinkTab($jrep);
		my $jrep_designator = ${DataStructureXML::getJREPdesignator($jrep)};
		print "$jrep_designator...\n";
		#print $ip_link_tab
		foreach my $link (@$ip_link_tab) {
			my $link_id = ${DataStructureXML::getLinkDesignator($link)};#$link->{'link_designator'};
			my $indice_links = findIndiceLinkInTab($link_id);
			if(! ($indice_links < 0)){
				#print "init links $jrep_designator\n";
				$link_tab[$indice_links]->{'jrep2'} = $jrep_designator;	
				$link_tab[$indice_links]->{'sender_id2'} = ${DataStructureXML::getJREPsenderIDbyName($jrep_designator)};
				$link_tab[$indice_links]->{'ip_cnx_type2'} = $link->{'ip_cnx_type'};
				$link_tab[$indice_links]->{'ip_address2'} = $link->{'local_ip_address'};
				$link_tab[$indice_links]->{'tcp_port2'} = $link->{'local_ip_port'};
				$link_tab[$indice_links]->{'ip_protocol2'} = $link->{'ip_protocol'};	
			}
			else {
			# ajout dans le tableau
				my $i = scalar @link_tab;
				$link_tab[$i]={'link_id'  => $link_id, 'jrep1' => $jrep_designator};
				$link_tab[$i]->{'sender_id1'} = ${DataStructureXML::getJREPsenderIDbyName($jrep_designator)};
				$link_tab[$i]->{'ip_cnx_type1'} = $link->{'ip_cnx_type'};
				$link_tab[$i]->{'ip_address1'} = $link->{'local_ip_address'};
				$link_tab[$i]->{'tcp_port1'} = $link->{'local_ip_port'};
				$link_tab[$i]->{'ip_protocol1'} = $link->{'ip_protocol'};			
			}		
		}
	}
	return \@link_tab;
}

sub findIndiceLinkInTab {
	my $link_designator = shift;
	my $find = -1;
	for my $indice_links (0 .. (scalar @link_tab)-1) {
		if ($link_tab[$indice_links]->{'link_id'} eq $link_designator) {
			$find = $indice_links;
			last;
		}
	}
	return $find;
}
sub updateStructureXML {
	foreach my $link (@link_tab) {
		if(DataStructureXML::isJREPexisting($link->{'jrep1'})){
			#print "$link->{'jrep1'}"; exit 0;
			if(DataStructureXML::isLinkExisting($link->{'jrep1'}, $link->{'link_id'})){
				print "Modif d'un lien $link->{'link_id'} pour $link->{'jrep1'}\n";
				DataStructureXML::setLinkParameter(	$link->{'jrep1'}, 
													$link->{'link_id'},
													$link->{'ip_cnx_type1'},
													$link->{'ip_address1'},
													$link->{'tcp_port1'},
													$link->{'ip_protocol1'},
													$link->{'sender_id2'},
													$link->{'ip_address2'},
													$link->{'tcp_port2'} );
			}
			else {
				print "Ajout d'un lien $link->{'link_id'} pour $link->{'jrep1'}\n";
				DataStructureXML::addNewLink(		$link->{'jrep1'}, 
													$link->{'link_id'},
													$link->{'ip_cnx_type1'},
													$link->{'ip_address1'},
													$link->{'tcp_port1'},
													$link->{'ip_protocol1'},
													$link->{'sender_id2'},
													$link->{'ip_address2'},
													$link->{'tcp_port2'} );
			}
		}
		else {
			print "ERROR $link->{'jrep1'} does not exist !"; exit 0;
		}
		if(DataStructureXML::isJREPexisting($link->{'jrep2'})){
			if(DataStructureXML::isLinkExisting($link->{'jrep2'}, $link->{'link_id'})){
				print "Modif d'un lien $link->{'link_id'} pour $link->{'jrep2'}\n";
				DataStructureXML::setLinkParameter(	$link->{'jrep2'}, 
													$link->{'link_id'},
													$link->{'ip_cnx_type2'},
													$link->{'ip_address2'},
													$link->{'tcp_port2'},
													$link->{'ip_protocol2'},
													$link->{'sender_id1'},
													$link->{'ip_address1'},
													$link->{'tcp_port1'} );
			}
			else {
				print "Ajout d'un lien $link->{'link_id'} pour $link->{'jrep2'}\n";
				DataStructureXML::addNewLink(		$link->{'jrep2'}, 
													$link->{'link_id'},
													$link->{'ip_cnx_type2'},
													$link->{'ip_address2'},
													$link->{'tcp_port2'},
													$link->{'ip_protocol2'},
													$link->{'sender_id1'},
													$link->{'ip_address1'},
													$link->{'tcp_port1'} );
			}
		}
		else {
			print "ERROR $link->{'jrep2'} does not exist !"; exit 0;
		}
	}
	# pour chacun des liens
	# extraire les 2 les 2 jrep designator
	# pour chaque jrep
	# vérifier l'existance du JREP (en principe il existe cf la combobox)
	#si le JREP existe
	# vérifier si le lien ip existe
	# si oui mettre à jour les paramètres (y compris concernant le remote JREP)
	# si non ajouter le lien
	# si le JREP  n'existe pas : remonter une erreur ! 
}
1