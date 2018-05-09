package Linksframe;

use Tkx;
use DataStructureXML;

my $notebookJREP;
my $frameLinks;
my (@entryLinks, @labelLinks, @buttonLinks);
my $buttonAddLink;
my $buttonDelLink;
my $links;

my $configLinkWindow;

sub new {
	$notebookJREP = shift;
	$frameLinks = $notebookJREP->new_ttk__frame; # first page, which would get widgets gridded into it
	$frameLinks->configure(-borderwidth => 5);
	$notebookJREP->add($frameLinks, -text => "Links");
	return $frameLinks;
}

sub displayNotebookLinks{
	my $i = 0;
	$links = shift;
	clearNotebookLinks();
	my (@jrepList) = DataStructureXML::getListJREP();
	my $jrepList = join " ", (@jrepList);
	foreach my $link (@$links) {
		$labelLinks[$i] = $frameLinks->new_ttk__label(-text =>"Links Designator :", -anchor => 'e', -width => 15);
		$entryLinks[$i] = $frameLinks->new_ttk__entry(-textvariable => \$link->{'link_id'}, -width => 6);		
		$labelLinks[$i+1] = $frameLinks->new_ttk__label(-text =>"JREP Designator 1:", -anchor => 'e', -width => 15);
		$entryLinks[$i+1] = $frameLinks->new_ttk__combobox(-textvariable => \$link->{'jrep1'}, -value => $jrepList, -width => 12);
		$entryLinks[$i+1]->g_bind("<FocusOut>", [\&updateSenderID1, $link]);
		$labelLinks[$i+2] = $frameLinks->new_ttk__label(-text =>"JREP Designator 2:", -anchor => 'e', -width => 15);
		$entryLinks[$i+2] = $frameLinks->new_ttk__combobox(-textvariable => \$link->{'jrep2'}, -value => $jrepList, -width => 12);
		$entryLinks[$i+2]->g_bind("<FocusOut>", [\&updateSenderID2, $link]);
		$buttonLinks[$i] = $frameLinks->new_ttk__button(-text => "Config.", -command => [\&displayLinkConfigWindow, $link]);
	
		
		$labelLinks[$i]->g_grid(-column => 0, -row => $i/3, -padx => 5, -pady => 5);
		$entryLinks[$i]->g_grid(-column => 1, -row => $i/3, -padx => 5, -pady => 5);
		$labelLinks[$i+1]->g_grid(-column => 2, -row => $i/3, -padx => 5, -pady => 5);
		$entryLinks[$i+1]->g_grid(-column => 3, -row => $i/3, -padx => 5, -pady => 5);
		$labelLinks[$i+2]->g_grid(-column => 4, -row => $i/3, -padx => 5, -pady => 5);
		$entryLinks[$i+2]->g_grid(-column => 5, -row => $i/3, -padx => 5, -pady => 5);
		$buttonLinks[$i]->g_grid(-column => 6, -row => $i/3, -padx => 5, -pady => 5);
		$i += 3;
	}
	$buttonAddLink = $frameLinks->new_ttk__button(-text => "Add Link", -command => \&addLink);
	$buttonDelLink = $frameLinks->new_ttk__button(-text => "Del Link", -command => \&delLink);
	$buttonAddLink->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$buttonDelLink->g_grid(-column => 4, -row => $i, -padx => 5, -pady => 5);
	return 0;
}

sub clearNotebookLinks {
	foreach my $i (0..scalar @labelJREP){
		#print "nettoyage ligne $i\n";
		if(defined $labelLinks[$i]){
			#print "nettoyage ligne $i\n";
			$labelLinks[$i]->g_grid_remove();
			$entryLinks[$i]->g_grid_remove();
			$buttonLiks[$i]->g_grid_remove()if(defined($buttonJREP[$i]));
		}		
	}
	$buttonAddLink->g_grid_remove()if(defined $buttonAddLink);
	$buttonDelLink->g_grid_remove()if(defined $buttonDelLink);
}

sub displayLinkConfigWindow {
	my $link = shift;
	my $ip_cnx_type = "SERVER CLIENT";
	my $ip_protocole = "TCP UDP";
	my $mw = Tkx::widget->new(".");
	my $configLinkWindow = $mw->new_toplevel();
	$configLinkWindow->g_wm_title("Link Configuration : $link->{'link_id'}" );
	my $newFrame = $configLinkWindow->new_ttk__frame();
	my (@label, @entry);
	my $i = 0;
	$label[$i]= $newFrame->new_ttk__label( -text =>'Link Designator :', -anchor => 'e',-width => 20);
	$entry[$i]= $newFrame->new_ttk__entry( -textvariable => \$link->{'link_id'},-state => 'readonly', -width => 6);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 2, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label_local = $newFrame->new_ttk__label( -text =>'Local', -anchor => 'center',-width => 15);
	$label_remote = $newFrame->new_ttk__label( -text =>'Remote', -anchor => 'center',-width => 20);
	$label_local->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$label_remote->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'JREP Name :', -anchor => 'e',-width => 15);
	$entry[$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'jrep1'},-state => 'readonly', -width => 20);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'Sender ID :', -anchor => 'e',-width => 15);
	$entry[$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'sender_id1'},-state => 'readonly', -width => 20);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'IP Address :',-anchor => 'e', -width => 15);
	$entry[$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'ip_address1'}, -width => 20);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'TCP Port :',-anchor => 'e', -width => 15);
	$entry[$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'tcp_port1'}, -width => 20);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'IP Connection Type :',-anchor => 'e', -width => 20);
	$entry[$i] = $newFrame->new_ttk__combobox( -textvariable => \$link->{'ip_cnx_type1'}, -value => $ip_cnx_type, -width => 20);
	$label[$i]->g_grid(-column => 0, -row => $i);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$label[$i] = $newFrame->new_ttk__label( -text =>'IP protocole :', -anchor => 'e',-width => 15);
	$entry[$i] = $newFrame->new_ttk__combobox( -textvariable => \$link->{'ip_protocol1'}, -value => $ip_protocole, -width => 6);
	$label[$i]->g_grid(-column => 0, -row => $i, -padx => 5, -pady => 5);
	$entry[$i]->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5, -sticky => 'w');
	$j = $i++;
	$i = 2;
	$entry[$j+$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'jrep2'},-state => 'readonly', -width => 20);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$entry[$j+$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'sender_id2'}, -state => 'readonly', -width => 20);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
#	$label[$j+$i] = $newFrame->new_ttk__label( -text =>'IP Address remote :',-anchor => 'e', -width => 20);
	$entry[$j+$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'ip_address2'}, -width => 20);
#	$label[$j+$i]->g_grid(-column => 3, -row => $i);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
#	$label[$j+$i] = $newFrame->new_ttk__label( -text =>'TCP Port remote :',-anchor => 'e', -width => 20);
	$entry[$j+$i] = $newFrame->new_ttk__entry( -textvariable => \$link->{'tcp_port2'}, -width => 20);
#	$label[$j+$i]->g_grid(-column => 3, -row => $i);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
	$entry[$j+$i] = $newFrame->new_ttk__combobox( -textvariable => \$link->{'ip_cnx_type2'}, -value => $ip_cnx_type, -width => 20);
#	$label[$j+$i]->g_grid(-column => 3, -row => $i);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5);
	$i++;
#	$label[$j+$i] = $newFrame->new_ttk__label( -text =>'IP protocole remote :', -anchor => 'e',-width => 20);
	$entry[$j+$i] = $newFrame->new_ttk__combobox( -textvariable => \$link->{'ip_protocol2'}, -value => $ip_protocole, -width => 6);
#	$label[$j+$i]->g_grid(-column => 3, -row => $i);
	$entry[$j+$i]->g_grid(-column => 3, -row => $i, -padx => 5, -pady => 5, -sticky => 'w');
	$i++;
	my $buttonJREPOK = $newFrame->new_ttk__button(-text => "OK", -command => [\&closeConfigWindow, $configLinkWindow]);
	$buttonJREPOK->g_grid(-column => 1, -row => $i, -padx => 5, -pady => 5);
	
	$newFrame->g_grid(-columnspan => 5, -rowspan => 13, -padx => 5, -pady => 5);
	
}
sub updateNotebookLinks{
	#clearNotebookLinks();
	displayNotebookLinks($links);
}
sub updateSenderID1 {
	my $link = shift;
	$link->{'sender_id1'} = ${DataStructureXML::getJREPsenderIDbyName($link->{'jrep1'})};
}
sub updateSenderID2 {
	my $link = shift;
	$link->{'sender_id2'} = ${DataStructureXML::getJREPsenderIDbyName($link->{'jrep2'})};
}

sub addLink {
	DataStructureLink::addLink();
	updateNotebookLinks();
}

sub closeConfigWindow{
	my $configLinkWindow = shift;
	DataStructureLink::updateStructureXML();
	$configLinkWindow->g_destroy;
}
sub delLink {
	
}

1