#!/usr/bin/perl

my @TaskList = ("HOST_TD", "JREP");
my $SOLARIS_ROOT = "/export/home/thales";
my $SOLARIS_MACHINE_NAME = "JRE-Gateway";
my $CONFIG_ROOT_DIR = "E:\\CONFIGURATION\\";
my $CONFIG_DIR = "Default";
my @HOST_TD_CONFIG_FILE = ("host_test_driver.conf", "host_test_driver.trc", "tdl_router_init.xhd");
my @JREP_CONFIG_FILE = ( 	"jre_config.xsd", "jre_param.xsd", "jrep_configuration_file.xml", 
							"jrep_configuration_file.xml", "parameters.txt");
my $HOST_TD_NUM = 1;
local $HOST_TD = {	'NUM'		=> $HOST_TD_NUM, 
				'CONFIG_DIR' 	=> "$CONFIG_ROOT_DIR\\$CONFIG_DIR\\HOST_TD" ,
				'EXE_DIR'		=> "$SOLARIS_ROOT\\HOST_TD",
				'FILE_LIST' 	=> \@HOST_TD_CONFIG_FILE,
				'OPERATING_SYST'	=> "SOLARIS"
};
my $JREP_NUM = 2;
local $JREP = {	'NUM'		=> $JREP_NUM, 
				'CONFIG_DIR' 	=> "$CONFIG_ROOT_DIR\\$CONFIG_DIR\\JREP" ,
				'EXE_DIR'		=> "$SOLARIS_ROOT\\JREP\\conf",
				'FILE_LIST' 	=> \@JREP_CONFIG_FILE,
				'OPERATING_SYST'	=> "SOLARIS"
};

mkdir ($CONFIG_ROOT_DIR) if (! -d $CONFIG_ROOT_DIR);
chdir ($CONFIG_ROOT_DIR);
mkdir ("$CONFIG_DIR") if ( ! -d $CONFIG_DIR);
chdir ($CONFIG_DIR);
foreach my $task (@TaskList) {
	mkdir("$task") if ( ! -d $task);
	chdir ( $task ) ;
	foreach my $file ( @{$$task->{'FILE_LIST'}} ){
		my $dir = $ENV{PWD};
		print "$file $dir\n";
		if ( ! -f $file ) {
			print ("$SOLARIS_MACHINE_NAME:$SOLARIS_ROOT/$task/$file $dir\n");
			system( "pscp $SOLARIS_MACHINE_NAME:$SOLARIS_ROOT/$task/$file $CONFIG_ROOT_DIR\\$CONFIG_DIR\\$task");
		}
	}
	chdir("..");
}
exit 0;
#foreach my $task (@TaskList) {
	