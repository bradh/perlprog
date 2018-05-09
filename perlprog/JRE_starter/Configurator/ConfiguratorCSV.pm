package ConfiguratorCSV;
# Read and populate the hash variable

my @project_data;
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


sub init_data {
	$rprojectName = shift;
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

	open Fin, "<configurator_$$rprojectName.csv" or die "file configurator_$$rprojectName.csv do not exist";
	#read first line
	#<Fin>;
	# read data
	my $i = 0;
	while(<Fin>){
		chomp;
		$project_data[$i] = $_;
		$i++;
	}
	close Fin;
	# init process list
	getProcessList();
	# get process list
	#print "process list 2 = @$rprocess_list\n";
	foreach my $process (@$rprocess_list){
		my @fileList;
		#print "$process\n";
		local @${process};
		ConfiguratorCSV::getFileList($process, \@fileList);
	}
	exit 0;
	# init project data
	my @line;
	foreach $i (0.. $#project_data){
		my $col = 0;
		#print "$project_data[$i]\n";
		@line = (split ";" , $project_data[$i]);
		#print "longueur ligne = $#line\n";
		insertProjectData($i, $col++, \@line);
		insertIPData($i, $col++, \@line);
		insertTCPData($i, $col++, \@line);
		insertDLIP_mct_main_cfg($i, $col++, \@line);
		#insertDLIP_mct_main_trc1($i, $col++, \@line);
		#insertDLIP_mct_main_trc2($i, $col++, \@line);
		insertTDL_ROUTER_tdl_router_main($i, $col++, \@line);
		insertTDL_ROUTER_l16_param($i, $col++, \@line);
		insertTDL_ROUTER_mids_registration($i, $col++, \@line);
		insertTDL_ROUTER_standalone($i, $col++, \@line);
		insertTDL_ROUTER_simple_if($i, $col++, \@line);
		insertJREP_internal_parameters($i, $col++, \@line);
		insertJREP_configuration_parameters($i, $col++, \@line);
		insertJREP_parameters($i, $col++, \@line);
		insertSupervisor_main($i, $col++, \@line);
		insertSupervisor_dlip($i, $col++, \@line);
		insertSupervisor_tdl_router($i, $col++, \@line);
		insertSupervisor_jrep($i, $col++, \@line);
		insertSupervisor_osim($i, $col++, \@line);
		insertSupervisor_tlcmgr($i, $col++, \@line);
		insertSupervisor_jrem($i, $col++, \@line);
	}
}

sub saveProjectData{
	# mettre à jour le nom du projet
	ConfiguratorProject::getProjectName();
	# ouvrir le fichier du nouveau projet
	#print "project name to save : $$rprojectName\n";
	open Fout, ">configurator_$$rprojectName.csv" or ConfiguratorMenu::acquittementAction("not posible create configurator_$$rprojectName .csv file !");
	# déterminer le nombre max de ligne 
	#print "taille tableau : $#$rproject_param ";
			
	my $max_number = $#project_data;
	#print "line number = $max_number\n";
	
	
	#pour chaque numero de ligne
	#créer la ligne
	my $project_part = "0;0;0";
	my $ip_part = "0;0;0";
	my $tcp_part = "0;0;0";
	my $DLIP_cfg_part = "0;0;0";
	my $DLIP_trc_part = "0;0;0";
	my $TDL_tdl_part = "0;0;0";
	my $TDL_l16_part = "0;0;0";
	my $TDL_mids_part = "0;0;0";
	my $TDL_standalone_part = "0;0;0";
	my $TDL_simple_part = "0;0;0";
	my $JREP_internal_part = "0;0;0";
	my $JREP_config_part ="0;0;0";
	my $JREP_param_part = "0;0;0";
	my $Supervisor_main = "0;0;0";
	my $Supervisor_dlip = "0;0;0";
	my $Supervisor_tdl_router = "0;0;0";
	my $Supervisor_jrep = "0;0;0";
	my $Supervisor_jrem = "0;0;0";
	my $Supervisor_tlcmgr = "0;0;0";
	my $Supervisor_osim = "0;0;0";
	
	
	foreach my $i (0.. $max_number){
		$line = "";
		if($i <= $#$rproject_param) {
			$line_part = "$rproject_param->[$i][0]; $rproject_param->[$i][1];$rproject_param->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line_part";
	# IP address
		if($i <= $#$rIP_address) {
			$line_part = "$rIP_address->[$i][0]; $rIP_address->[$i][1];$rIP_address->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
	#TCP port
		if($i <= $#$rTCP_port) {
			$line_part = "$rTCP_port->[$i][0]; $rTCP_port->[$i][1];$rTCP_port->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
	#DLIP
		if($i <= $#$rDLIP_mct_main_cfg) {
			$line_part = "$rDLIP_mct_main_cfg->[$i][0]; $rDLIP_mct_main_cfg->[$i][1];$rDLIP_mct_main_cfg->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		#if($i <= $#$rDLIP_mct_main_trc1) {
		#	$line_part = "$rDLIP_mct_main_trc1->[$i][0]; $rDLIP_mct_main_trc1->[$i][1];$rDLIP_mct_main_trc1->[$i][2]";
		#}
		#else{$line_part = "0;0;0";
		#}
		#$line = "$line;$line_part";
		#if($i <= $#$rDLIP_mct_main_trc2) {
		#	$line_part = "$rDLIP_mct_main_trc2->[$i][0]; $rDLIP_mct_main_trc2->[$i][1];$rDLIP_mct_main_trc2->[$i][2]";
		#}
		#else{$line_part = "0;0;0";
		#}
		#$line = "$line;$line_part";
	#TDL ROUTER
		if($i <= $#$rTDL_ROUTER_tdl_router_main) {
			$line_part = "$rTDL_ROUTER_tdl_router_main->[$i][0]; $rTDL_ROUTER_tdl_router_main->[$i][1];$rTDL_ROUTER_tdl_router_main->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rTDL_ROUTER_l16_param) {
			$line_part = "$rTDL_ROUTER_l16_param->[$i][0]; $rTDL_ROUTER_l16_param->[$i][1];$rTDL_ROUTER_l16_param->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rTDL_ROUTER_mids_registration) {
			$line_part = "$rTDL_ROUTER_mids_registration->[$i][0]; $rTDL_ROUTER_mids_registration->[$i][1];$rTDL_ROUTER_mids_registration->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rTDL_ROUTER_standalone) {
			$line_part = "$rTDL_ROUTER_standalone->[$i][0]; $rTDL_ROUTER_standalone->[$i][1];$rTDL_ROUTER_standalone->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rTDL_ROUTER_simple_if) {
			$line_part = "$rTDL_ROUTER_simple_if->[$i][0]; $rTDL_ROUTER_simple_if->[$i][1];$rTDL_ROUTER_simple_if->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
	#JREP
		if($i <= $#$rJREP_internal_parameters) {
			$line_part = "$rJREP_internal_parameters->[$i][0]; $rJREP_internal_parameters->[$i][1];$rJREP_internal_parameters->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rJREP_configuration_parameters) {
			$line_part = "$rJREP_configuration_parameters->[$i][0]; $rJREP_configuration_parameters->[$i][1];$rJREP_configuration_parameters->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rJREP_parameters) {
			$line_part = "$rJREP_parameters->[$i][0]; $rJREP_parameters->[$i][1];$rJREP_parameters->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
	#Supervisor
		if($i <= $#$rSupervisor_main) {
			$line_part = "$rSupervisor_main->[$i][0]; $rSupervisor_main->[$i][1];$rSupervisor_main->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_dlip) {
			$line_part = "$rSupervisor_dlip->[$i][0]; $rSupervisor_dlip->[$i][1];$rSupervisor_dlip->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_tdl_router) {
			$line_part = "$rSupervisor_tdl_router->[$i][0]; $rSupervisor_tdl_router->[$i][1];$rSupervisor_tdl_router->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_jrep) {
			$line_part = "$rSupervisor_jrep->[$i][0]; $rSupervisor_jrep->[$i][1];$rSupervisor_jrep->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_osim) {
			$line_part = "$rSupervisor_osim->[$i][0]; $rSupervisor_osim->[$i][1];$rSupervisor_osim->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_tlcmgr) {
			$line_part = "$rSupervisor_tlcmgr->[$i][0]; $rSupervisor_tlcmgr->[$i][1];$rSupervisor_tlcmgr->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		if($i <= $#$rSupervisor_jrem) {
			$line_part = "$rSupervisor_jrem->[$i][0]; $rSupervisor_jrem->[$i][1];$rSupervisor_jrem->[$i][2]";
		}
		else{$line_part = "0;0;0";
		}
		$line = "$line;$line_part";
		print Fout "$line\n";
	}
	#exit 0;
	#l'écrire dans le fichier
	# fermer le fichier
	close Fout;
}

sub insertProjectData(){
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "project data J = $col\n";
	#print "@$rline\n ";

	if($rline->[$col] ne "0" ) {
		$rproject_param->[$i] = [[],[],[]];
		$rproject_param->[$i][0] = $rline->[$col++];
		$rproject_param->[$i][1] = $rline->[$col++];
		$rproject_param->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rproject_param->[$i][0] : $rproject_param->[$i][1] : $rproject_param->[$i][2]\n";
	}
	return 1;
}
sub insertIPData{
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "IP J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rIP_address->[$i] = [[],[],[]];
		$rIP_address->[$i][0] = $rline->[$col++];
		$rIP_address->[$i][1] = cleanValue($rline->[$col++]);
		$rIP_address->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rIP_address->[$i][0] : $rIP_address->[$i][1] : $rIP_address->[$i][2]\n";
	}
	return 1;
}

sub insertTCPData {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "TCP J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rTCP_port->[$i] = [[],[],[]];
		$rTCP_port->[$i][0] = $rline->[$col++];
		$rTCP_port->[$i][1] = cleanValue($rline->[$col++]);
		$rTCP_port->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTCP_port->[$i][0] : $rTCP_port->[$i][1] : $rTCP_port->[$i][2]\n";
	}
	return 1;
}

sub insertDLIP_mct_main_cfg {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "mct_main.cfg J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rDLIP_mct_main_cfg->[$i] = [[],[],[]];
		$rDLIP_mct_main_cfg->[$i][0] = $rline->[$col++];
		$rDLIP_mct_main_cfg->[$i][1] = cleanValue($rline->[$col++]);
		$rDLIP_mct_main_cfg->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rDLIP_mct_main_cfg->[$i][0] : $rDLIP_mct_main_cfg->[$i][1] : $rDLIP_mct_main_cfg->[$i][2]\n";
		#<>;
	}
	return 1;
}
sub insertDLIP_mct_main_trc1 {
	#my $i = shift;
	#my $col = shift;
	#my $rline = shift;
	#$col = $col*3;
	#print "trc 1 J = $col\n";
	
	#if($rline->[$col] ne "0") {
		#$rDLIP_mct_main_trc1->[$i] = [[],[],[]];
		#$rDLIP_mct_main_trc1->[$i][0] = $rline->[$col++];
		#$rDLIP_mct_main_trc1->[$i][1] = $rline->[$col++];
		#$rDLIP_mct_main_trc1->[$i][2] = $rline->[$col++];
		#print "$rDLIP_mct_main_trc1->[$i][0] : $rDLIP_mct_main_trc1->[$i][1] : $rDLIP_mct_main_trc1->[$i][2]\n";
	#}
	return 1;
}
sub insertDLIP_mct_main_trc2 {
	#my $i = shift;
	#my $col = shift;
	#my $rline = shift;
	#$col = $col*3;
	#print "trc2 J = $col\n";
	
	#if($rline->[$col] ne "0") {
		#$rDLIP_mct_main_trc2->[$i] = [[],[],[]];
		#$rDLIP_mct_main_trc2->[$i][0] = $rline->[$col++];
		#$rDLIP_mct_main_trc2->[$i][1] = $rline->[$col++];
		#$rDLIP_mct_main_trc2->[$i][2] = $rline->[$col++];
		#print "$rDLIP_mct_main_trc2->[$i][0] : $rDLIP_mct_main_trc2->[$i][1] : $rDLIP_mct_main_trc2->[$i][2]\n";
	#}
	return 1;
}
sub insertTDL_ROUTER_tdl_router_main {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "tdl router J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rTDL_ROUTER_tdl_router_main->[$i] = [[],[],[]];
		$rTDL_ROUTER_tdl_router_main->[$i][0] = $rline->[$col++];
		$rTDL_ROUTER_tdl_router_main->[$i][1] = cleanValue($rline->[$col++]);
		$rTDL_ROUTER_tdl_router_main->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTDL_ROUTER_tdl_router_main->[$i][0] : $rTDL_ROUTER_tdl_router_main->[$i][1] : $rTDL_ROUTER_tdl_router_main->[$i][2]\n";
	}
	return 1;
}

sub insertTDL_ROUTER_l16_param {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "l16 param J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rTDL_ROUTER_l16_param->[$i] = [[],[],[]];
		$rTDL_ROUTER_l16_param->[$i][0] = $rline->[$col++];
		$rTDL_ROUTER_l16_param->[$i][1] = cleanValue($rline->[$col++]);
		$rTDL_ROUTER_l16_param->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTDL_ROUTER_l16_param->[$i][0] : $rTDL_ROUTER_l16_param->[$i][1] : $rTDL_ROUTER_l16_param->[$i][2]\n";
	}
	return 1;
}
sub insertTDL_ROUTER_mids_registration {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "mids registration J = $col\n";
	if($rline->[$col] ne "0") {
		$rTDL_ROUTER_mids_registration->[$i] = [[],[],[]];
		$rTDL_ROUTER_mids_registration->[$i][0] = $rline->[$col++];
		$rTDL_ROUTER_mids_registration->[$i][1] = $rline->[$col++];
		$rTDL_ROUTER_mids_registration->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTDL_ROUTER_mids_registration->[$i][0] : $rTDL_ROUTER_mids_registration->[$i][1] : $rTDL_ROUTER_mids_registration->[$i][2]\n";
	}
	return 1;
}
sub insertTDL_ROUTER_standalone {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "standalone J = $col\n";
	
	if($rline->[$col] ne "0") {
		$rTDL_ROUTER_standalone->[$i] = [[],[],[]];
		$rTDL_ROUTER_standalone->[$i][0] = $rline->[$col++];
		$rTDL_ROUTER_standalone->[$i][1] = $rline->[$col++];
		$rTDL_ROUTER_standalone->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTDL_ROUTER_standalone->[$i][0] : $rTDL_ROUTER_standalone->[$i][1] : $rTDL_ROUTER_standalone->[$i][2]\n";
	}
	return 1;
}
sub insertTDL_ROUTER_simple_if {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "simple if J = $col\n";
	if($rline->[$col] ne "0") {
		$rTDL_ROUTER_simple_if->[$i] = [[],[],[]];
		$rTDL_ROUTER_simple_if->[$i][0] = $rline->[$col++];
		$rTDL_ROUTER_simple_if->[$i][1] = cleanValue($rline->[$col++]);
		$rTDL_ROUTER_simple_if->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rTDL_ROUTER_simple_if->[$i][0] : $rTDL_ROUTER_simple_if->[$i][1] : $rTDL_ROUTER_simple_if->[$i][2]\n";
	}
	return 1;
}
sub insertJREP_internal_parameters {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP internal J = $col\n";
	if($rline->[$col] ne "0") {
		$rJREP_internal_parameters->[$i] = [[],[],[]];
		$rJREP_internal_parameters->[$i][0] = $rline->[$col++];
		$rJREP_internal_parameters->[$i][1] = cleanValue($rline->[$col++]);
		$rJREP_internal_parameters->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rJREP_internal_parameters->[$i][0] : $rJREP_internal_parameters->[$i][1] : $rJREP_internal_parameters->[$i][2]\n";
	}
	return 1;
}
sub insertJREP_configuration_parameters {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP config J = $col\n";
	if($rline->[$col] ne "0") {
		$rJREP_configuration_parameters->[$i] = [[],[],[]];
		$rJREP_configuration_parameters->[$i][0] = $rline->[$col++];
		$rJREP_configuration_parameters->[$i][1] = cleanValue($rline->[$col++]);
		$rJREP_configuration_parameters->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rJREP_configuration_parameters->[$i][0] : $rJREP_configuration_parameters->[$i][1] : $rJREP_configuration_parameters->[$i][2]\n";
	}
	return 1;
}
sub insertJREP_parameters {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rJREP_parameters->[$i] = [[],[],[]];
		$rJREP_parameters->[$i][0] = $rline->[$col++];
		$rJREP_parameters->[$i][1] = cleanValue($rline->[$col++]);
		$rJREP_parameters->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rJREP_parameters->[$i][0] : $rJREP_parameters->[$i][1] : $rJREP_parameters->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_main {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_main->[$i] = [[],[],[]];
		$rSupervisor_main->[$i][0] = $rline->[$col++];
		$rSupervisor_main->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_main->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_main->[$i][0] : $rSupervisor_main->[$i][1] : $rSupervisor_main->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_dlip {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_dlip->[$i] = [[],[],[]];
		$rSupervisor_dlip->[$i][0] = $rline->[$col++];
		$rSupervisor_dlip->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_dlip->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_dlip->[$i][0] : $rSupervisor_dlip->[$i][1] : $rSupervisor_dlip->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_tdl_router {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_tdl_router->[$i] = [[],[],[]];
		$rSupervisor_tdl_router->[$i][0] = $rline->[$col++];
		$rSupervisor_tdl_router->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_tdl_router->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_tdl_router->[$i][0] : $rSupervisor_tdl_router->[$i][1] : $rSupervisor_tdl_router->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_jrep {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_jrep->[$i] = [[],[],[]];
		$rSupervisor_jrep->[$i][0] = $rline->[$col++];
		$rSupervisor_jrep->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_jrep->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_jrep->[$i][0] : $rSupervisor_jrep->[$i][1] : $rSupervisor_jrep->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_osim {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_osim->[$i] = [[],[],[]];
		$rSupervisor_osim->[$i][0] = $rline->[$col++];
		$rSupervisor_osim->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_osim->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_osim->[$i][0] : $rSupervisor_osim->[$i][1] : $rSupervisor_osim->[$i][2]\n";
	}
	return 1;
}
sub insertSupervisor_tlcmgr {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_tlcmgr->[$i] = [[],[],[]];
		$rSupervisor_tlcmgr->[$i][0] = $rline->[$col++];
		$rSupervisor_tlcmgr->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_tlcmgr->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_tlcmgr->[$i][0] : $rSupervisor_tlcmgr->[$i][1] : $rSupervisor_tlcmgr->[$i][2]\n";
	}
	return 1;
}sub insertSupervisor_jrem {
	my $i = shift;
	my $col = shift;
	my $rline = shift;
	$col = $col*3;
	#print "JREP parameters J = $col\n";
	if($rline->[$col] ne "0") {
		$rSupervisor_jrem->[$i] = [[],[],[]];
		$rSupervisor_jrem->[$i][0] = $rline->[$col++];
		$rSupervisor_jrem->[$i][1] = cleanValue($rline->[$col++]);
		$rSupervisor_jrem->[$i][2] = cleanValue($rline->[$col++]);
		#print "$rSupervisor_jrem->[$i][0] : $rSupervisor_jrem->[$i][1] : $rSupervisor_jrem->[$i][2]\n";
	}
	return 1;
}

sub getProcessList(){
	my @line = (split ";" , $project_data[0]);
	my $i = 3;
	my $process = "null";
	while ( 3*$i < $#line ) {
		print "$process -> $line[$i*3],\n";
		push @$rprocess_list, $line[$i*3] if($process ne "$line[$i*3]" );
		$process = $line[$i*3];
		$i++;
	}
	#print "process list  = @$rprocess_list\n";
	return 1;
}

sub getFileList(){
	my $process = shift;
	my $rfile_list = shift;
	my @line = (split ";" , $project_data[0]);
	my $i = 3;
	while ( 3*$i < ($#line -1) ) {
		push @$rfile_list , $line[$i*3+1] if($process eq "$line[$i*3]" && $line[$i*3+1] !~ /^\s*$/);
		$i++;
	}
	#print " process file list  : $process :  @$rfile_list\n";
	return 1;
}

sub cleanValue(){
	my $value = shift;
	print "$value\n";
	$value =~ s/^\s*//;
	$value =~ s/\s*$//;
	$value =~ s/§/;/g;
	print "$value\n";
	return $value;
}

1