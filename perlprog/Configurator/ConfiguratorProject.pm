package ConfiguratorProject;

use File::Basename;

use ConfiguratorMenu;
use ConfiguratorFile;

my $dir = "/media/stephane/TRANSCEND/Tools/perlprog/Configurator";
#my $dir = "H:\\Tools\\perlprog\\Configurator";
my $rproject_dir;
my $rproject_file;

my $param_max = 35; # par onglet
my $mw;
my $mw2;
my $pbox;
my $notebook;
my @frame1;
my @notebook2;
my @frame2;
my @frame;
my $project_notebook;
my $IP_address_notebook;
my $TCP_port_notebook;

my $rscript_dir;
my $rproject_name;
my $rproject_version;
my $rproject_param;
my $rIP_address;
my $rTCP_port;
my $rprocess_list;
my $rconfigurator_data;

sub init{
	$rscript_dir = shift;
	$rproject_dir =shift;
	$rproject_file =shift;
	$rproject_name =shift;
	$rproject_version = shift;
	$rprocess_list = shift;
	$rconfigurator_data = shift;
	
	$mw = Tkx::widget->new(".");
	$mw->g_wm_title("Toplink Configurator");
	$mw->g_wm_geometry("700x750+300+200");

	# Create menu
	$mw->configure(-menu => ConfiguratorMenu::mk_menu($mw, \&selectProject, \&saveProject, \&saveasProject, \&applyConfiguration));
	
	# create notebook
	
	Tkx::MainLoop();
}

sub applyConfiguration  {
	print "apply configuration ...\n";
	$$rproject_name = getProjectName();
	$$rproject_version = getProjectVersion();
	ConfiguratorFile::applyConfiguration();
}

sub updateFiles {
	#Configurator::saveProject();
	return 0;

}

sub selectProject {
	my $project_file = Tkx::tk___getOpenFile();
	$project_file =~ s/\//\\\\/g;
	print "$project_file\n";
	chomp $project_file;
	($$rproject_file, $$rproject_dir) = fileparse($project_file);
	print "$$rproject_file,$$rproject_dir\n";
	#exit 0; 
	#$filename = Tkx::tk___getSaveFile();
	#$dirname = Tkx::tk___chooseDirectory();
	print "$$rproject_file\n";
	initConfigurator();	
}

sub saveasProject {
	$$rproject_name = getProjectName();
	$$rproject_version = getProjectVersion();
	ConfiguratorCSV::saveasProject();
}

sub saveProject {
	ConfiguratorCSV::saveProject();
}

sub initConfigurator{
	#print "Project Name : $$rproject_name\n";
	my $toto = 50;
	#my $p = $mw->new_ttk__progressbar();
	#my $p= $mw2->new_ttk__progressbar(-orient => 'horizontal', -maximum => 100, -variable => \&toto, -mode => 'determinate' );
	#$p->start();
	ConfiguratorCSV::init_data(	$rproject_dir,
								$rproject_file,
								$rproject_name,
								$rproject_version,
								$rprocess_list,
								$rconfigurator_data);
								
	print "process list : @$rprocess_list\n";	
	$$rproject_name = getProjectName();
	print "Project Name : $$rproject_name\n";
	$$rproject_version = getProjectVersion();
	print "Project Version : $$rproject_version\n";
		
	ConfiguratorFile::init_data(	
								$rscript_dir,
								$rproject_dir,
								$rproject_file,
								$rproject_name,
								$rproject_version,
								$rprocess_list,
								$rconfigurator_data);
	
	initNotebook();							
}

sub initNotebook {
	clearNotebook();
	$notebook1 = $mw->new_ttk__notebook();
	
	my $notebook1_index = 0;
	
	$process = "Projet";
	print "notebook Project \n";
	$frame1[$notebook1_index] = $notebook1->new_ttk__frame();
	$notebook1->add($frame1[$notebook1_index], -text => "$process");
	foreach my $param (1.. $#{$rconfigurator_data->{$process}->{'NULL'}}){
					#print "$i $rDLIP_mct_main_cfg->[$i][0]\n";
					$label = $frame1[$notebook1_index]->new_ttk__label(	-text => $rconfigurator_data->{$process}->{'NULL'}->[$param]->[0],
															-background => 'yellow');
																
					$entry1 = $frame1[$notebook1_index]->new_ttk__entry(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[1],
																-background => 'lightblue');	
					$entry2 = $frame1[$notebook1_index]->new_ttk__entry(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[2]);
					$label-> g_grid(-column => 1, -row => $param);									
					$entry1->g_grid(-column => 2, -row => $param);
					$entry2->g_grid(-column => 3, -row => $param);
	}
	$notebook1_index++;
	$process = "IP@";
	print "notebook IP@\n";
	$frame1[$notebook1_index] = $notebook1->new_ttk__frame();
	$notebook1->add($frame1[$notebook1_index], -text => "$process");
	foreach my $param (1.. $#{$rconfigurator_data->{$process}->{'NULL'}}){
					#print "$i $rDLIP_mct_main_cfg->[$i][0]\n";
					$label = $frame1[$notebook1_index]->new_ttk__label(	-text => $rconfigurator_data->{$process}->{'NULL'}->[$param]->[0],
															-background => 'yellow');
																
					$entry1 = $frame1[$notebook1_index]->new_ttk__label(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[1],
																-background => 'lightblue');	
					$entry2 = $frame1[$notebook1_index]->new_ttk__entry(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[2]);
					$label-> g_grid(-column => 1, -row => $param);									
					$entry1->g_grid(-column => 2, -row => $param);
					$entry2->g_grid(-column => 3, -row => $param);
	}
	$notebook1_index++;
	$process = "TCP port";
	print "notebook Project \n";
	$frame1[$notebook1_index] = $notebook1->new_ttk__frame();
	$notebook1->add($frame1[$notebook1_index], -text => "$process");
	foreach my $param (1.. $#{$rconfigurator_data->{$process}->{'NULL'}}){
					#print "$i $rDLIP_mct_main_cfg->[$i][0]\n";
					$label = $frame1[$notebook1_index]->new_ttk__label(	-text => $rconfigurator_data->{$process}->{'NULL'}->[$param]->[0],
															-background => 'yellow');
																
					$entry1 = $frame1[$notebook1_index]->new_ttk__label(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[1],
																-background => 'lightblue');	
					$entry2 = $frame1[$notebook1_index]->new_ttk__entry(-textvariable => \$rconfigurator_data->{$process}->{'NULL'}->[$param]->[2]);
					$label-> g_grid(-column => 1, -row => $param);									
					$entry1->g_grid(-column => 2, -row => $param);
					$entry2->g_grid(-column => 3, -row => $param);
	}
	$notebook1_index++;
	
	foreach my $process (@$rprocess_list){
		print "notebook $process \n";
		my $notebook2_index = 0;
		$frame1[$notebook1_index] = $notebook1->new_ttk__frame();
		$notebook1->add($frame1[$notebook1_index], -text => "$process");
		$notebook2 = $frame1[$notebook1_index]->new_ttk__notebook();
		$notebook1_index++;
				
		my @file_list = (keys %{$rconfigurator_data->{$process}});
		@file_list = sort @file_list;
		print "file list : @file_list\n";
		
		foreach my $file (@file_list){
			
			my $param_nber = $#{$rconfigurator_data->{$process}->{$file}};
			print "process $process, param nber $param_nber\n";
			my $param_count = 1;
			my $i = 1;
			while ($param_count <= $param_nber){
				$frame2 [$notebook2_index] = $notebook2->new_ttk__frame();
				$notebook2->add($frame2[$notebook2_index], -text => "$file ($i)");
				my $param_count_max = $param_count + $param_max-1;
				$param_count_max = $param_nber if($param_nber < $param_count_max);
				foreach my $param ($param_count.. $param_count_max){
					#print "$i $rDLIP_mct_main_cfg->[$i][0]\n";
					$label = $frame2[$notebook2_index]->new_ttk__label(	-text => $rconfigurator_data->{$process}->{$file}->[$param]->[0],
															-background => 'yellow');
																
					$entry1 = $frame2[$notebook2_index]->new_ttk__label(-text => $rconfigurator_data->{$process}->{$file}->[$param]->[1],
																-background => 'lightblue');	
					$entry2 = $frame2[$notebook2_index]->new_ttk__entry(-textvariable => \$rconfigurator_data->{$process}->{$file}->[$param]->[2]);
					$label-> g_grid(-column => 1, -row => $param);									
					$entry1->g_grid(-column => 2, -row => $param);
					$entry2->g_grid(-column => 3, -row => $param);
				}
				$notebook2_index++;
				$param_count = $param_count_max + 1;
				$i++;
			}
		}
		$notebook2->g_grid;
		$notebook1_index++;
	}
	
	$notebook1->g_grid();
}


sub getProjectName {
	return $rconfigurator_data->{'Projet'}->{'NULL'}->[1][1];
}

sub getProjectVersion {
	return $rconfigurator_data->{'Projet'}->{'NULL'}->[1][2];
}

sub getProcessVersion {
	my $process_name = shift;
	my $version = 0;
	print "get version : $process_name\n";
	#print "$rconfigurator_data->{'Projet'}->{'NULL'} \n";
	foreach my $rprocess (@{$rconfigurator_data->{'Projet'}->{'NULL'}}){
		#print "$rprocess\n";
		my $process = $rprocess->[0];
		if($process_name eq $process){
			$version = $rprocess->[1] ;
			print "version  : $version \n";
		}
	}
	return $version;
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
sub clearNotebook(){
	$notebook->g_destroy() if (defined $notebook);
	return 1;
}

1