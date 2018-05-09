#!/usr/bin/perl -w
# configurateur du systeme logiciel GAN en ligne de commande
# 
use strict;
use Getopt::Std;

use ConfiguratorCSV;
use ConfiguratorFile;

our $opt_f;
our $opt_h;

getopts('hf:');

print "$opt_f\n";

my $debug = 1;

if(defined $opt_h){
	print " usage $0 -f <ficher .csv de configuration GAN>\n";
	exit 0;
}

if(defined $opt_f && ! defined $opt_h){
	
    # valable si un lien symbolique est fait entre le repertoire COnfiguration du projet dans le repertoire du script     
    my $PROJECT_DIR = $ENV{'PWD'};
#'/h7_usr/sil2_usr/ganivq/Scripts/Configurator';
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
	# exit 0;						
	ConfiguratorFile::init_data(\$PROJECT_DIR,
								\$PROJECT_FILE,
								\$PROJECT_NAME,
								\$PROJECT_VERSION,
								\@process_list,
								\%configurator_data,
				
								);
	#exit 0;
	print "ConfiguratorFile::applyConfiguration\n" if($debug);
	ConfiguratorFile::applyConfiguration();
	print "ConfiguratorFile::createVersionFile\n" if($debug);
	ConfiguratorFile::createVersionFile();
	ConfiguratorFile::createTargetFile();
}
else {
	print " usage $0 -f <ficher .csv de configuration GAN>\n";
}
exit 0;












