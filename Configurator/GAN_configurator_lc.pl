#!/usr/bin/perl -w
# configurateur du systeme logiciel GAN en ligne de commande
# 
use strict;
use Getopt::Std;

use ConfiguratorCSV;

getopts("f:h");

if($opt_h){
	print " usage $0 -f <ficher .csv de configuration GAN>\n";
	exit 0;
}

if($opt_f &&  $opt_h){
    my $PROJECT_DIR = 'D:\\Users\\t0028369\\Documents\\Mes outils personnels\\perlprog\\Configurator';
	my $PROJECT_FILE = $opt_f;
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
	ConfiguratorCSV::init_data(	\$PROJECT_DIR,
								\$PROJECT_FILE,
								\$PROJECT_NAME,
								\$PROJECT_VERSION,
								\@process_list,
								\%configurator_data,
								);
							
	ConfiguratorFile::init_data(\$PROJECT_DIR,
								\$PROJECT_FILE,
								\$PROJECT_NAME,
								\$PROJECT_VERSION,
								\@process_list,
								\%configurator_data,
								);
}
else {
	print " usage $0 -f <ficher .csv de configuration GAN>\n";
}
exit 0;












