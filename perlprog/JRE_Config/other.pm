package other;
my @label;
my @entry;
my @Hframe;
sub displayLinkL16JREPConfig {
	my $mw = shift;
	$Hframe[17]=$mw->new_ttk__frame(-borderwidth => 5, -relief => "sunken");
	$label[117]= $Hframe[17]->new_ttk__label(-text =>"Link Name : ");
	$label[217]= $Hframe[17]->new_ttk__label(-text =>"Link L16 ");
	
	$label[17]= $Hframe[17]->new_ttk__label(-text =>"Designator ID : ");

	$entry[17]=$Hframe[17]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'jrep_dlip_link'}->{'link_designator'}, -width => 10);
   	$Hframe[18]=$mw->new_ttk__frame(-borderwidth => 5, -relief => "sunken");
	$label[18]= $Hframe[18]->new_ttk__label(-text =>"Local JREP : ");
  	$Hframe[118]=$mw->new_ttk__frame(-borderwidth => 5);
	$label[118]= $Hframe[18]->new_ttk__label(-text =>"Local JREP : ");
	$entry[118]=$Hframe[18]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'jrep_sender_id'}, -width => 10);			   
    $Hframe[19]=$mw->new_ttk__frame(-borderwidth => 5, -relief => "sunken");
	$label[19]= $Hframe[19]->new_ttk__label(-text =>"Remote JREP : ");
	$entry[19]=$Hframe[19]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'jrep_sender_id'}, -width => 10);			   
}   		
sub displayIdentJREPConfig {
	my $mw = shift;
	$Hframe[1]=$mw->new_ttk__frame(-borderwidth => 5);
	$label[1]= $Hframe[1]->new_ttk__label(-text =>"Designator : ",-anchor => 'e', -width => 25);
	$entry[1]=$Hframe[1]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'jrep_designator'}, -width => 10);
   	$Hframe[2]=$mw->new_ttk__frame(-borderwidth => 5);
	$label[2]= $Hframe[2]->new_ttk__label(-text =>"Sender ID : ",-anchor => 'e', -width => 25);
	$entry[2]=$Hframe[2]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'jrep_sender_id'}, -width => 10);			
}

sub displaySecTNJREPConfig {
	my $mw = shift;
	for my $i (0..$SecTN_Nber-1){
		$Hframe[$i+3]=$mw->new_ttk__frame(-borderwidth => 5);
		$label[$i+3]= $Hframe[$i+3]->new_ttk__label(-text =>"Sec TN # $i : ",-anchor => 'e', -width => 25);
		$entry[$i+3]=$Hframe[$i+3]->new_ttk__entry(-textvariable => \$jrep_config->{'config_jrep'}->{'secondary_tn_list'}->{'track_number'}->[$i], -width => 8);	
	}
}
1