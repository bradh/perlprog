package DataStructureXML;

use XML::Simple;
use Data::Dumper;


my $JRE_Network_Configuration;
my $jrep_tab;

sub readConfigFile{
	my $file_name = shift;
	$JRE_Network_Configuration = XMLin("$file_name", ForceArray => ['config_jrep', 'track_number', 'jrep_ip_link']);
	$jrep_tab = $JRE_Network_Configuration->{'config_jrep'};
  	print Dumper($JRE_Network_Configuration);
  	#$jrep_internal_config = XMLin(".\jre_internal_file.xml');
  	#print Dumper($jrep_internal_config);
  	return $JRE_Network_Configuration;
}

sub writeConfigFile{
	my $file_name = shift;
	open my $fs, ">$file_name" or die "Impossible open $file_name\n";
	print $fs "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	print $fs "<config_jre xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
	foreach my $jrep (@$jrep_tab){
		print $fs "  <config_jrep startup_mode=\"$jrep->{'startup_mode'}\" jrep_designator=\"$jrep->{'jrep_designator'}\">\n";
		print $fs "		<jrep_sender_id>$jrep->{'jrep_sender_id'}</jrep_sender_id>\n";
		print $fs "		<secondary_tn_list>\n";
		if (ref($jrep->{'secondary_tn_list'}->{'track_number'})eq "ARRAY"){
			foreach my $tn (@{$jrep->{'secondary_tn_list'}->{'track_number'}}){
			print $fs "   			<track_number>$tn</track_number>\n";
			}
		}
		else {
			print $fs "   			<track_number>$jrep->{'secondary_tn_list'}->{'track_number'}</track_number>\n";
		}
		print $fs "		</secondary_tn_list>\n";
		print $fs "		<jrep_dlip_link>\n";
      	print $fs "			<link_designator>$jrep->{'jrep_dlip_link'}->{'link_designator'}</link_designator>\n";
    	print $fs "		</jrep_dlip_link>\n";
    	my $ip_link_number = scalar @{$jrep->{'jrep_ip_link'}};
    	if($ip_link_number > 0){
			foreach my $link (@{$jrep->{'jrep_ip_link'}}){
				print   $fs  "	<jrep_ip_link ip_protocol=\"$link->{'ip_protocol'}\" ip_cnx_type=\"$link->{'ip_cnx_type'}\">\n";
				print $fs	"		<link_designator>$link->{'link_designator'}</link_designator>\n";
				print $fs	"		<sender_id>$link->{'sender_id'}</sender_id>\n";
      			print $fs	"		<local_ip_address>$link->{'local_ip_address'}</local_ip_address>\n";
      			print $fs	"		<local_ip_port>$link->{'local_ip_port'}</local_ip_port>\n";
      			print $fs 	"		<remote_ip_address>$link->{'remote_ip_address'}</remote_ip_address>\n";
      			print $fs	"		<remote_ip_port>$link->{'remote_ip_port'}</remote_ip_port>\n";
      			print $fs	"		<preselection>$link->{'preselection'}</preselection>\n";
    			print $fs	"	</jrep_ip_link>\n";
			}
    	}
    	else {
    		#print   $fs  "	<jrep_ip_link ip_protocol=\"TCP\" ip_cnx_type=\"SERVER\">\n";
    		#print $fs	"		<link_designator>000</link_designator>\n";
      		#print $fs	"		<sender_id>00000</sender_id>\n";
      		#print $fs	"		<local_ip_address>ADDR1</local_ip_address>\n";
      		#print $fs	"		<local_ip_port>PORT1</local_ip_port>\n";	
      		#print $fs 	"		<remote_ip_address>ADDR2</remote_ip_address>\n";
      		#print $fs	"		<remote_ip_port>PORT2</remote_ip_port>\n";
      		#print $fs	"		<preselection>false</preselection>\n";
    		#print $fs	"	</jrep_ip_link>\n";
    	}
	print $fs "	  </config_jrep>\n";
	}
	print $fs	"  </config_jre>\n";
#	XMLout($JRE_Network_Configuration, OutputFile => $fs, NoAttr => 1);
	close $fs;
	return 0;
}
  
sub displayHash{
    		my $r_hash = shift;
    		foreach my $param (keys %{$r_hash}) {
    	 		my $value =  $r_hash->{$param};
    	 		print "$i : $value\n";
    	 		if($value =~ /HASH/){
    	 			$Hframe[$i]=$pane->Frame->pack(-side => 'top');
    	 			$label[$i]=$Hframe[$i]->Label(-text =>"$param ",-anchor => 'e', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
    	 			$i=$i+1;
    	 			displayHash($value);
    	 		}
    	 		elsif ($value =~ /ARRAY/){
    	 			foreach my $value (@$value){
    	 				$Hframe[$i]=$pane->Frame->pack(-side => 'top');
    	 				$label[$i]=$Hframe[$i]->Label(-text =>"Sec. TN : ",-anchor => 'e', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
    	 				$entry[$i]=$Hframe[$i]->Entry(-text => "$value", -relief => 'sunken', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
    	 				
						$i=$i+1;
    	 			}
    	 		}
    	 		else {	
    				$Hframe[$i]=$pane->Frame->pack(-side => 'top');
   	 				$label[$i]=$Hframe[$i]->Label(-text =>"$param ",-anchor => 'e', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
 					$entry[$i]=$Hframe[$i]->Entry(-text => "$value", -relief => 'sunken', -width => 25)->pack(-side => 'left', -padx => 0, -anchor =>'n');
					$i=$i+1;
    	 		}
    		}
}

sub addNewJREP {
	push @$jrep_tab,  {'jrep_designator' => 'NEW',
							'jrep_sender_id'  =>  '00000',
							'startup_mode'    =>  'JRE_MNG',
							'jrep_dlip_link'  => {'link_designator' => '1'},
							'secondary_tn_list' => {'track_number' => ['00001']},
							'jrep_ip_link'    => []
							};
	return $jrep_tab;
}

sub addNewSTN {
	my $jrepName = shift;
	my $STN = shift;
	#print "$$jreName, $STN"; exit 0;
	foreach my $jrep (@$jrep_tab) {
		if ( $jrep->{'jrep_designator'} eq $$jrepName) {
			push @{$jrep->{'secondary_tn_list'}->{'track_number'}}, $STN;
		}
	}
}

sub addNewLink {
	my $jrepName = shift;
	my $link_designator = shift;
	my $ip_cnx_type = shift;
	my $local_ip_address = shift;
	my $local_ip_port = shift;
	my $ip_protocol = shift;
	my $sender_id = shift;
	print "sender ID = $sender_id\n";
	my $remote_ip_address = shift;
	my $remote_ip_port = shift;
	
	foreach my $jrep (@$jrep_tab){
		if($jrep->{'jrep_designator'} eq $jrepName){
			print "add link to jrep $jrepName\n";
			my $link_number = scalar @{$jrep->{'jrep_ip_link'}};
			print "add link to $link_number link number \n";
 			$jrep->{'jrep_ip_link'}->[$link_number] = { 'link_designator' => $link_designator,
													'ip_cnx_type' => $ip_cnx_type,
													'local_ip_address' => $local_ip_address,
													'local_ip_port' => $local_ip_port,
													'ip_protocol' => $ip_protocol,
													'sender_id' => $sender_id,
													'remote_ip_address' => $remote_ip_address,
													'remote_ip_port' => $remote_ip_port,
													'preselection' => "false" };
		}
	}
}

sub setLinkParameter {
	my $jrepName = shift;
	my $link_designator = shift;
	my $ip_cnx_type = shift;
	my $local_ip_address = shift;
	my $local_ip_port = shift;
	my $ip_protocol = shift;
	my $sender_id = shift;
	print "sender ID = $sender_id\n";
	my $remote_ip_address = shift;
	my $remote_ip_port = shift;
	foreach my $jrep (@$jrep_tab){
		if($jrep->{'jrep_designator'} eq $jrepName){
			foreach my $link (@{$jrep->{'jrep_ip_link'}}){
				print "update Link  $link $jrep\n";
				if ($link->{'link_designator'} eq $link_designator){
					$link->{'ip_cnx_type'} = $ip_cnx_type;
					$link->{'local_ip_address'} = $local_ip_address;
					$link->{'local_ip_port'} = $local_ip_port;
					$link->{'ip_protocol'} = $ip_protocol;
					$link->{'sender_id'} = $sender_id;
					$link->{'remote_ip_port'} = $remote_ip_port;
					$link->{'remote_ip_address'} = $remote_ip_address;
					last;	
				}
			}
			last;
		}
	}
	return 0;
}

sub isJREPexisting {
	my $jrepName = shift;
	foreach my $jrep (@$jrep_tab){
		return 1 if($jrep->{'jrep_designator'} eq $jrepName);
	}
	return 0;
}

sub isLinkExisting{
	my $jrepName = shift;
	my $link_designator = shift;
	foreach my $jrep (@$jrep_tab){
		if($jrep->{'jrep_designator'} eq $jrepName){
			foreach my $link (@{$jrep->{'jrep_ip_link'}}){
				return 1 if ($link->{'link_designator'} eq $link_designator);
			}
		}
	}
	return 0;
}

sub getListJREP{
	my $indice = scalar @$jrep_tab;
	my @jrepList;
	foreach my $jrep (@$jrep_tab){
		push @jrepList, $jrep->{'jrep_designator'};
	}
	print "JREP list : @jrepList\n";
	return (@jrepList);
}

sub getLinkDesignator{
	my $link = shift;
	return \$link->{'link_designator'};
}

sub getIpLinkTab{
	my $jrep = shift;
	return $jrep->{'jrep_ip_link'};
}

sub getJREPdesignator{
	my $jrep = shift;
	return \$jrep->{'jrep_designator'};
}

sub getJREPsenderIDbyName {
	$jrepName = shift;
	foreach my $jrep (@$jrep_tab){
		if ($jrep->{'jrep_designator'} eq $jrepName){
			return \$jrep->{'jrep_sender_id'};
		}
	}
	return -1;
}

sub getJREPstartupMode {
	$jrep_tab = shift;
	$jrepName = shift;
	foreach my $jrep (@$jrep_tab){
		if ($jrep->{'jrep_designator'}eq $jrepName){
			return \$jrep->{'startup_mode'};
		}
	}
	return -1;
}

sub getJREPdlipLink {
	$jrep_tab = shift;
	$jrepName = shift;
	foreach my $jrep (@$jrep_tab){
		if ($jrep->{'jrep_designator'}eq $jrepName){
			return \$jrep->{'jrep_dlip_link'}->{'link_designator'};
		}
	}
	return -1;
}

sub getJREPsecondaryTNlist {
	$jrep_tab = shift;
	$jrepName = shift;
	foreach my $jrep (@$jrep_tab){
		if ($jrep->{'jrep_designator'}eq $jrepName){
			if(ref($jrep->{'secondary_tn_list'}->{'track_number'}) eq "ARRAY"){
				return $jrep->{'secondary_tn_list'}->{'track_number'};
			}
			else{
				return $jrep->{'secondary_tn_list'}->{'track_number'};
			}
		}
	}
	return -1;
}
1