package ConfiguratorProject;

use ConfiguratorMenu;

my $dir = "/media/stephane/TRANSCEND/Tools/perlprog/Configurator";
my $mw;
my $mw2;
my $pbox;
my $notebook;
my $project_notebook;
my $IP_address_notebook;
my $TCP_port_notebook;
my $DLIP_notebook;
my $dlip_mct_main_cfg_frame;
#my $dlip_mct_main_trc1_frame;
#my $dlip_mct_main_trc2_frame;
my $TDL_ROUTER_notebook;
my $tdl_router_main_frame;
my $l16_param_frame;
my $mids_registration_frame;
my $standalone_frame;
my $simple_if_frame;
my $jrep_internal_frame;
my $jrep_configuration_frame;
my $jrep_parameters_frame;
my $Supervisor_notebook;
my $Supervisor_main_frame;
my $Supervisor_dlip_frame;
my $Supervisor_tdl_router_frame;
my $Supervisor_jrep_frame;
my $Supervisor_jrem_frame;
my $Supervisor_tlcmgr_frame;
my $Supervisor_osim_frame;

my $rprojectName;
my $rproject_param;
my $rIP_address;
my $rTCP_port;
my $rprocess_list;
my $rDLIP_mct_main_cfg;
#my $rDLIP_mct_main_trc1;
#my $rDLIP_mct_main_trc2;
my $rTDL_ROUTER_tdl_router_main;
my $rTDL_ROUTER_l16_param;
my $rTDL_ROUTER_mids_registration;
my $rTDL_ROUTER_standalone;
my $rTDL_ROUTER_simple_if;
my $rJREP_internal_parameters;
my $rJREP_configuration_parameters;
my $rJREP_parameters;
my $rSupervisor_main;
my $rSupervisor_dlip;
my $rSupervisor_tdl_router;
my $rSupervisor_jrep;
my $rSupervisor_jrem;
my $rSupervisor_tlcmgr;
my $rSupervisor_osim;


sub init{
	$rprojectName =shift;
	$rproject_param = shift;
	$rIP_address = shift;
	$rTCP_port = shift;
	$rprocess_list = shift;
	$rDLIP_mct_main_cfg= shift;
	#$rDLIP_mct_main_trc1 = shift;
	#$rDLIP_mct_main_trc2 = shift;
	$rTDL_ROUTER_tdl_router_main = shift; 
	$rTDL_ROUTER_l16_param = shift;
	$rTDL_ROUTER_mids_registration = shift;
	$rTDL_ROUTER_standalone = shift;
	$rTDL_ROUTER_simple_if = shift;
	$rJREP_internal_parameters = shift;
	$rJREP_configuration_parameters = shift;
	$rJREP_parameters = shift;
	$rSupervisor_main = shift;
	$rSupervisor_dlip = shift;
	$rSupervisor_tdl_router = shift;
	$rSupervisor_jrep = shift;
	$rSupervisor_osim = shift;
	$rSupervisor_tlcmgr = shift;
	$rSupervisor_jrem = shift;
	
	$mw = Tkx::widget->new(".");
	$mw->g_wm_title("Toplink Configurator");
	$mw->g_wm_geometry("600x600+300+200");

	# Create menu
	$mw->configure(-menu => ConfiguratorMenu::mk_menu($mw, \&selectProject, \&updateFiles, \&saveProject));
	
	# create notebook
	initNotebook();
	
	Tkx::MainLoop();
}

sub updateFiles {
	ConfiguratorFile::update_DLIP_files();
	ConfiguratorFile::update_TDL_ROUTER_files();
	ConfiguratorFile::update_JREP_files();
	ConfiguratorFile::update_Supervisor_files();
}

sub selectProject {
	my $projectName;
	# open popup windows
	$mw2 = $mw->new_toplevel();
	$mw2->g_wm_title("Select a project" );
	$mw2->g_wm_geometry("+500+350");
	my @projectList = ConfiguratorProject::getProjectList();
	my $list = join " ", (@projectList);
	my $frame = $mw2->new_ttk__frame();
	my $label = $frame->new_ttk__label(-text => "Project name : ");
	$pbox = $frame->new_ttk__combobox(-textvariable => $rprojectName);	
	$pbox->configure(-value => "$list");
	$frame->g_grid();
	$label->g_grid();								
	$pbox->g_grid(-column => 2, -row => 1);
	$pbox->g_bind("<<ComboboxSelected>>",  sub {initConfigurator()});
	#print "$$rprojectName\n";
	return $pbox;
}

sub saveProject {
	
	
	ConfiguratorCSV::saveProjectData();
	
	ConfiguratorMenu::acquittementAction("$rproject_param->[1][1] project saved ?");
}

sub initConfigurator(){
	print "Project Name : $$rprojectName\n";
	my $toto = 50;
	#my $p = $mw->new_ttk__progressbar();
	#my $p= $mw2->new_ttk__progressbar(-orient => 'horizontal', -maximum => 100, -variable => \&toto, -mode => 'determinate' );
	#$p->start();
	ConfiguratorCSV::init_data(	$rprojectName, 
								$rproject_param, 
								$rIP_address, 
								$rTCP_port,
								$rDLIP_mct_main_cfg,
								#$rDLIP_mct_main_trc1,
								#$rDLIP_mct_main_trc2,
								$rTDL_ROUTER_tdl_router_main,
								$rTDL_ROUTER_l16_param,
								$rTDL_ROUTER_mids_registration,
								$rTDL_ROUTER_standalone,
								$rTDL_ROUTER_simple_if,
								$rJREP_internal_parameters,
								$rJREP_configuration_parameters,
								$rJREP_parameters,
								$rSupervisor_main,
								$rSupervisor_dlip,
								$rSupervisor_tdl_router,
								$rSupervisor_jrep,
								$rSupervisor_osim,
								$rSupervisor_tlcmgr,
								$rSupervisor_jrem);
	#ConfiguratorMenu::acquittementAction("fin init_data");
	$mw2->g_destroy();							
	initProjectNotebook();
	ConfiguratorMenu::acquittementAction("finish project notebook");
	initIPNotebook();
	ConfiguratorMenu::acquittementAction("finish ip notebook");	
	initTCPportNotebook();
	initDLIPNotebook();
	ConfiguratorMenu::acquittementAction("finish dlip notebook");
	initTDLROUTERNotebook();
	ConfiguratorMenu::acquittementAction("finish tdl router notebook");
	initJREPNotebook();
	initSupervisorNotebook();
	ConfiguratorMenu::acquittementAction("finish initialisation notebook");
}

sub initNotebook {
	clearNotebook();
	$notebook = $mw->new_ttk__notebook();
	$project_notebook = $notebook->new_ttk__frame();
	$notebook->add($project_notebook, -text => "Project");
	
	$IP_address_notebook = $notebook->new_ttk__frame();
	$notebook->add($IP_address_notebook, -text => "IP address");


	$TCP_port_notebook = $notebook->new_ttk__frame();
	$notebook->add($TCP_port_notebook, -text => "TCP port");
	
	$DLIP_frame = $notebook->new_ttk__frame();
	$notebook->add($DLIP_frame, -text => "DLIP");
	
		$DLIP_notebook = $DLIP_frame->new_ttk__notebook();	
		
		$dlip_mct_main_cfg_frame = $DLIP_notebook->new_ttk__frame();
		$DLIP_notebook->add($dlip_mct_main_cfg_frame, -text => "mct_main.cfg");
		#$dlip_mct_main_trc1_frame = $DLIP_notebook->new_ttk__frame();
		#$DLIP_notebook->add($dlip_mct_main_trc1_frame, -text => "mct_main trc1");
		#$dlip_mct_main_trc2_frame = $DLIP_notebook->new_ttk__frame();
		#$DLIP_notebook->add($dlip_mct_main_trc2_frame, -text => "mct_main trc1");
	
	$TDL_ROUTER_frame = $notebook->new_ttk__frame();
	$notebook->add($TDL_ROUTER_frame, -text => "TDL_ROUTER");
		
		$TDL_ROUTER_notebook = $TDL_ROUTER_frame->new_ttk__notebook();	
		
		$tdl_router_main_frame = $TDL_ROUTER_notebook->new_ttk__frame();
		$TDL_ROUTER_notebook->add($tdl_router_main_frame, -text => "tdl router main");
		$l16_param_frame = $TDL_ROUTER_notebook->new_ttk__frame();
		$TDL_ROUTER_notebook->add($l16_param_frame, -text => "l16 param");
		$mids_registration_frame = $TDL_ROUTER_notebook->new_ttk__frame();
		$TDL_ROUTER_notebook->add($mids_registration_frame, -text => "mids registration");
		$standalone_frame = $TDL_ROUTER_notebook->new_ttk__frame();
		$TDL_ROUTER_notebook->add($standalone_frame, -text => "standalone");
		$simple_if_frame = $TDL_ROUTER_notebook->new_ttk__frame();
		$TDL_ROUTER_notebook->add($simple_if_frame, -text => "simple if");
	
	$JREP_frame = $notebook->new_ttk__frame();
	$notebook->add($JREP_frame, -text => "JREP");
	
		$JREP_notebook = $JREP_frame->new_ttk__notebook();	
		$jrep_internal1_frame = $JREP_notebook->new_ttk__frame();
		$JREP_notebook->add($jrep_internal1_frame, -text => "internal1");
		$jrep_internal2_frame = $JREP_notebook->new_ttk__frame();
		$JREP_notebook->add($jrep_internal2_frame, -text => "internal2");
		$jrep_configuration_frame = $JREP_notebook->new_ttk__frame();
		$JREP_notebook->add($jrep_configuration_frame, -text => "configuration");
		$jrep_parameters_frame = $JREP_notebook->new_ttk__frame();
		$JREP_notebook->add($jrep_parameters_frame, -text => "parameters");
		
	$Supervisor_frame = $notebook->new_ttk__frame();
	$notebook->add($Supervisor_frame, -text => "Supervisor");
	
		$Supervisor_notebook = $Supervisor_frame->new_ttk__notebook();	
		$Supervisor_main_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_main_frame, -text => "main");
		$Supervisor_dlip_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_dlip_frame, -text => "dlip");
		$Supervisor_tdl_router_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_tdl_router_frame, -text => "tdl_router");
		$Supervisor_jrep_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_jrep_frame, -text => "jrep");
		$Supervisor_osim_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_osim_frame, -text => "osim");
		$Supervisor_tlcmgr_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_tlcmgr_frame, -text => "tlcmgr");
		$Supervisor_jrem_frame = $Supervisor_notebook->new_ttk__frame();
		$Supervisor_notebook->add($Supervisor_jrem_frame, -text => "jrem");
		
	
	$DLIP_notebook->g_grid();
	$TDL_ROUTER_notebook->g_grid();
	$JREP_notebook->g_grid();
	$Supervisor_notebook->g_grid();
	$notebook->g_grid();
}

sub clearNotebook(){
	$notebook->g_destroy() if (defined $notebook);
	return 1;
}

sub initProjectNotebook {
	foreach my $i (1..$#$rproject_param){
		#print "titi $i $rproject_param->[$i][0]\n";
		$label = $project_notebook->new_ttk__label(	-text => $rproject_param->[$i][0],
												-background => 'yellow');	
		$entry1 = $project_notebook->new_ttk__entry(-textvariable => \$rproject_param->[$i][1],
													-background => 'lightblue');	
		$entry2 = $project_notebook->new_ttk__entry(-textvariable => \$rproject_param->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}
}

sub initIPNotebook{
	# supprimer les widget existante
	foreach my $i (1..$#$rIP_address){
		#print "titi $i $rIP_address->[$i][0]\n";
		$label = $IP_address_notebook->new_ttk__label(	-text => $rIP_address->[$i][0],
												-background => 'yellow');	
		$entry1 = $IP_address_notebook->new_ttk__label(-text => $rIP_address->[$i][1],
													-background => 'lightblue');	
		$entry2 = $IP_address_notebook->new_ttk__entry(-textvariable => \$rIP_address->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}
	
}

sub initTCPportNotebook{
	# supprimer les widget existante
	foreach my $i (1..$#$rTCP_port){
		#print "titi $i $rTCP_port->[$i][0]\n";
		$label = $TCP_port_notebook->new_ttk__label(	-text => $rTCP_port->[$i][0],
												-background => 'yellow');	
		$entry1 = $TCP_port_notebook->new_ttk__label(-text => $rTCP_port->[$i][1],
													-background => 'lightblue');	
		$entry2 = $TCP_port_notebook->new_ttk__entry(-textvariable => \$rTCP_port->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initDLIPNotebook{
	
	initDLIP_mct_main_cfg_Notebook();
	#initDLIP_mct_main_trc1_Notebook();
	#initDLIP_mct_main_trc2_Notebook();
}

sub initDLIP_mct_main_cfg_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rDLIP_mct_main_cfg){
		print "$i $rDLIP_mct_main_cfg->[$i][0]\n";
		$label = $dlip_mct_main_cfg_frame->new_ttk__label(	-text => $rDLIP_mct_main_cfg->[$i][0],
												-background => 'yellow');	
		$entry1 = $dlip_mct_main_cfg_frame->new_ttk__label(-text => $rDLIP_mct_main_cfg->[$i][1],
													-background => 'lightblue');	
		$entry2 = $dlip_mct_main_cfg_frame->new_ttk__entry(-textvariable => \$rDLIP_mct_main_cfg->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}



sub initTDLROUTERNotebook{
	
	initTLDROUTERMAINNotebook();
	initL16PARAMNotebook();
	initMIDSREGISTRATIONNotebook();
	initSTANDALONENotebook();
	initSIMPLEIFNotebook();
}

sub initTLDROUTERMAINNotebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rTDL_ROUTER_tdl_router_main){
		#print "titi $i $rTDL_ROUTER_tdl_router_main->[$i][0]\n";
		$label = $tdl_router_main_frame->new_ttk__label(	-text => $rTDL_ROUTER_tdl_router_main->[$i][0],
												-background => 'yellow');	
		$entry1 = $tdl_router_main_frame->new_ttk__label(-text => $rTDL_ROUTER_tdl_router_main->[$i][1],
													-background => 'lightblue');	
		$entry2 = $tdl_router_main_frame->new_ttk__entry(-textvariable => \$rTDL_ROUTER_tdl_router_main->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initL16PARAMNotebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rTDL_ROUTER_l16_param){
		#print "titi $i $rTDL_ROUTER_l16_param->[$i][0]\n";
		$label = $l16_param_frame->new_ttk__label(	-text => $rTDL_ROUTER_l16_param->[$i][0],
												-background => 'yellow');	
		$entry1 = $l16_param_frame->new_ttk__label(-text => $rTDL_ROUTER_l16_param->[$i][1],
													-background => 'lightblue');	
		$entry2 = $l16_param_frame->new_ttk__entry(-textvariable => \$rTDL_ROUTER_l16_param->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initMIDSREGISTRATIONNotebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rTDL_ROUTER_mids_registration){
		#print "titi $i $rTDL_ROUTER_mids_registration->[$i][0]\n";
		$label = $mids_registration_frame->new_ttk__label(	-text => $rTDL_ROUTER_mids_registration->[$i][0],
												-background => 'yellow');	
		$entry1 = $mids_registration_frame->new_ttk__label(-text => $rTDL_ROUTER_mids_registration->[$i][1],
													-background => 'lightblue');	
		$entry2 = $mids_registration_frame->new_ttk__entry(-textvariable => \$rTDL_ROUTER_mids_registration->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initSTANDALONENotebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rTDL_ROUTER_standalone){
		#print "titi $i $rTDL_ROUTER_standalone->[$i][0]\n";
		$label = $standalone_frame->new_ttk__label(	-text => $rTDL_ROUTER_standalone->[$i][0],
												-background => 'yellow');	
		$entry1 = $standalone_frame->new_ttk__label(-text => $rTDL_ROUTER_standalone->[$i][1],
													-background => 'lightblue');	
		$entry2 = $standalone_frame->new_ttk__entry(-textvariable => \$rTDL_ROUTER_standalone->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initSIMPLEIFNotebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rTDL_ROUTER_simple_if){
		#print "titi $i $rTDL_ROUTER_simple_if->[$i][0]\n";
		$label = $simple_if_frame->new_ttk__label(	-text => $rTDL_ROUTER_simple_if->[$i][0],
												-background => 'yellow');	
		$entry1 = $simple_if_frame->new_ttk__label(-text => $rTDL_ROUTER_simple_if->[$i][1],
													-background => 'lightblue');	
		$entry2 = $simple_if_frame->new_ttk__entry(-textvariable => \$rTDL_ROUTER_simple_if->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initJREPNotebook{
	initJREP_internal1_parameters_Notebook();
	initJREP_internal2_parameters_Notebook();
	initJREP_configuration_parameters_Notebook();
	initJREP_parameters_Notebook();
}

sub initJREP_internal1_parameters_Notebook {
	# supprimer les widget existante
	foreach my $i (1..25){
		#print "titi $i $rJREP_internal_parameters->[$i][0]\n";
		$label = $jrep_internal1_frame->new_ttk__label(	-text => $rJREP_internal_parameters->[$i][0],
												-background => 'yellow');	
		$entry1 = $jrep_internal1_frame->new_ttk__label(-text => $rJREP_internal_parameters->[$i][1],
													-background => 'lightblue');	
		$entry2 = $jrep_internal1_frame->new_ttk__entry(-textvariable => \$rJREP_internal_parameters->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initJREP_internal2_parameters_Notebook {
	# supprimer les widget existante
	foreach my $i (26..$#$rJREP_internal_parameters){
		#print "titi $i $rJREP_internal_parameters->[$i][0]\n";
		$label = $jrep_internal2_frame->new_ttk__label(	-text => $rJREP_internal_parameters->[$i][0],
												-background => 'yellow');	
		$entry1 = $jrep_internal2_frame->new_ttk__label(-text => $rJREP_internal_parameters->[$i][1],
													-background => 'lightblue');	
		$entry2 = $jrep_internal2_frame->new_ttk__entry(-textvariable => \$rJREP_internal_parameters->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initJREP_configuration_parameters_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rJREP_configuration_parameters){
		#print "titi $i $rJREP_configuration_parameters->[$i][0]\n";
		$label = $jrep_configuration_frame->new_ttk__label(	-text => $rJREP_configuration_parameters->[$i][0],
												-background => 'yellow');	
		$entry1 = $jrep_configuration_frame->new_ttk__label(-text => $rJREP_configuration_parameters->[$i][1],
													-background => 'lightblue');	
		$entry2 = $jrep_configuration_frame->new_ttk__entry(-textvariable => \$rJREP_configuration_parameters->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initJREP_parameters_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rJREP_parameters){
		#print "titi $i $rJREP_parameters->[$i][0]\n";
		$label = $jrep_parameters_frame->new_ttk__label(	-text => $rJREP_parameters->[$i][0],
												-background => 'yellow');	
		$entry1 = $jrep_parameters_frame->new_ttk__label(-text => $rJREP_parameters->[$i][1],
													-background => 'lightblue');	
		$entry2 = $jrep_parameters_frame->new_ttk__entry(-textvariable => \$rJREP_parameters->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initSupervisorNotebook{
	
	initSupervisor_main_Notebook();
	initSupervisor_dlip_Notebook();
	initSupervisor_tdl_router_Notebook();
	initSupervisor_jrep_Notebook();
	initSupervisor_osim_Notebook();
	initSupervisor_tlcmgr_Notebook();
	initSupervisor_jrem_Notebook();
}

sub initSupervisor_main_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_main){
		#print "titi $i $rSupervisor_main->[$i][0]\n";
		$label = $Supervisor_main_frame->new_ttk__label(	-text => $rSupervisor_main->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_main_frame->new_ttk__label(-text => $rSupervisor_main->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_main_frame->new_ttk__entry(-textvariable => \$rSupervisor_main->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initSupervisor_dlip_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_dlip){
		#print "titi $i $rSupervisor_dlip->[$i][0]\n";
		$label = $Supervisor_dlip_frame->new_ttk__label(	-text => $rSupervisor_dlip->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_dlip_frame->new_ttk__label(-text => $rSupervisor_dlip->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_dlip_frame->new_ttk__entry(-textvariable => \$rSupervisor_dlip->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub initSupervisor_tdl_router_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_tdl_router){
		#print "titi $i $rSupervisor_tdl_router->[$i][0]\n";
		$label = $Supervisor_tdl_router_frame->new_ttk__label(	-text => $rSupervisor_tdl_router->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_tdl_router_frame->new_ttk__label(-text => $rSupervisor_tdl_router->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_tdl_router_frame->new_ttk__entry(-textvariable => \$rSupervisor_tdl_router->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initSupervisor_jrep_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_jrep){
		#print "titi $i $rSupervisor_jrep->[$i][0]\n";
		$label = $Supervisor_jrep_frame->new_ttk__label(	-text => $rSupervisor_jrep->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_jrep_frame->new_ttk__label(-text => $rSupervisor_jrep->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_jrep_frame->new_ttk__entry(-textvariable => \$rSupervisor_jrep->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initSupervisor_osim_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_osim){
		#print "titi $i $rSupervisor_osim->[$i][0]\n";
		$label = $Supervisor_osim_frame->new_ttk__label(	-text => $rSupervisor_osim->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_osim_frame->new_ttk__label(-text => $rSupervisor_osim->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_osim_frame->new_ttk__entry(-textvariable => \$rSupervisor_osim->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initSupervisor_tlcmgr_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_tlcmgr){
		#print "titi $i $rSupervisor_tlcmgr->[$i][0]\n";
		$label = $Supervisor_tlcmgr_frame->new_ttk__label(	-text => $rSupervisor_tlcmgr->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_tlcmgr_frame->new_ttk__label(-text => $rSupervisor_tlcmgr->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_tlcmgr_frame->new_ttk__entry(-textvariable => \$rSupervisor_tlcmgr->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}
sub initSupervisor_jrem_Notebook {
	# supprimer les widget existante
	foreach my $i (1..$#$rSupervisor_jrem){
		#print "titi $i $rSupervisor_jrem->[$i][0]\n";
		$label = $Supervisor_jrem_frame->new_ttk__label(	-text => $rSupervisor_jrem->[$i][0],
												-background => 'yellow');	
		$entry1 = $Supervisor_jrem_frame->new_ttk__label(-text => $rSupervisor_jrem->[$i][1],
													-background => 'lightblue');	
		$entry2 = $Supervisor_jrem_frame->new_ttk__entry(-textvariable => \$rSupervisor_jrem->[$i][2]);
		$label-> g_grid(-column => 1, -row => $i);									
		$entry1->g_grid(-column => 2, -row => $i);
		$entry2->g_grid(-column => 3, -row => $i);
		$i++;
	}	
}

sub getProjectName {
	#print "$rproject_param->[0][1]\n";
	#print "$$rprojectName\n";
	$$rprojectName = $rproject_param->[1][1];
	#print "$$rprojectName\n";
}

sub getProjectList{
	my @projectList;
	print "dir : $dir\n";
	opendir( DIR , $dir) || die "open dir not possible...";
	while(readdir DIR){
		my $file = $_;
		#print "$dir : $file\n";
		if( $file =~ /configurator_(\S*).csv$/){
			#print "$1\n";
			push @projectList, ($1);			
		}
	}
	#print "project list : @projectList";
	return (@projectList);
	
}

1