#!/usr/bin/perl -w
use strict;
use Tkx;

use ConfiguratorProject;
use ConfiguratorCSV;

my $script_dir = $ENV{'PWD'};

$script_dir = "/media/stephane/TRANSCEND/Tools/perlprog/Configurator";
#$script_dir = "D:\Users\t0028369\Documents\Mes outils personnels\perlprog\Configurator";
my $osname = `uname -u`;
print "$osname, $script_dir\n";

my $project_dir;
my $project_file;

my $project_name;
my $project_version;
my @project_param;
my @IP_address;
my @TCP_port;
my @process_list;
my %configurator_data;
# $rconfigurator_data = { 'process_name' =>	{'configuration_file' => [
		#						  												[0, 1 , 2]				  												
		#						  											 ]
		#						  					}
		#	
							
# Main window Tak$e top and the bottom - now implicit top is in the middle
ConfiguratorProject::init(	\$script_dir,
							\$project_dir,
							\$project_file,
							\$project_name,
							\$project_version,
							\@process_list,
							\%configurator_data,
							);
							
















