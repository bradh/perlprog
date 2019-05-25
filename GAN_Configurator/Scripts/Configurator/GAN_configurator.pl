#!/usr/bin/perl -w
use strict;
use Tkx;

use ConfiguratorProject;
use ConfiguratorCSV;

my $SCRIPT_DIR = $ENV{'PWD'};

#$SCRIPT_DIR = "/media/stephane/TRANSCEND/Tools/perlprog/Configurator";
$SCRIPT_DIR = '   ';
#my $osname = `uname -u`;
#print "$osname, $SCRIPT_DIR\n";

my $PROJECT_DIR = 'D:\\Users\\t0028369\\Documents\\Mes outils personnels\\perlprog\\Configurator';
my $PROJECT_FILE;

my $PROJECT_NAME;
my $PROJECT_VERSION;
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
ConfiguratorProject::init(	\$SCRIPT_DIR,
							\$PROJECT_DIR,
							\$PROJECT_FILE,
							\$PROJECT_NAME,
							\$PROJECT_VERSION,
							\@process_list,
							\%configurator_data,
							);
							
















