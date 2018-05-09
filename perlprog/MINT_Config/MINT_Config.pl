#!/usr/bin/perl -w
#

use Getopt::Std;
getopts("hsgc:");

if($opt_h){
	print"usage :\n";
	print "MINT_Config.pl -g -c SAMPT : retrive config files inthe directory D:\\CONFIGURATION\\SAMPT\n";
	print "MINT_Config.pl -s -c SAMPT : set config files inthe directory D:\\CONFIGURATION\\SAMPT\n";	
}

if(!$opt_h){
	
	my $debug = 1;
	my @TaskList = ("HOST_TD", "JREP", "TDL_ROUTER", "JREM", "DLIPCOM", "DLTE_TDL", "SPYLINKS", "CONTEXT_BUILDER");
	my $SOLARIS_ROOT_DIR = "/export/home/thales";
	my $SOLARIS_MACHINE_NAME = "JRE-Gateway";
	my $WINDOWS_ROOT_DIR = "D:\\THALES";
	my $CONFIG_ROOT_DIR = "D:\\CONFIGURATION\\";
	my $CONFIG_DIR = "Default";
	$CONFIG_DIR = $opt_c if($opt_c);
	my @HOST_TD_CONFIG_FILE = ("host_test_driver.conf", "host_test_driver.trc", "tdl_router_init.xhd");
	my @JREP_CONFIG_FILE = ( 	"jre_config.xsd", "jre_param.xsd", "jrep_configuration_file.xml", 
							"jrep_internal_file.xml", "parameters.txt");
	my @TDL_ROUTER_CONFIG_FILE = ("tdl_router_main.cfg", "tdl_router_main.trc");
	my @JREM_CONFIG_FILE = ("JreMng.xml", "JreMng.xml", "JreNetworkConfFile.xsd", "JreProcessors.xml", "JreProcessors.xsd", "MapRessources.xml", "log4j.xml");
	my @DLIPCOM_CONFIG_FILE = ("DLIP_CONTEXT_DATA.XML", "DLIP_CONTEXT_DATA.xsd", "DLIP-COM-MNG_OPERATIONAL_CONFIG.XML", "DLIP-COM-MNG_OPERATIONAL_CONFIG.xsd",
							"DLIP-COM-MNG_SYSTEM_CONFIG.XML", "DLIP-COM-MNG_SYSTEM_CONFIG.xsd", "translations.properties");
	my @DLTE_TDL_CONFIG_FILE = ("dlte_s16_TDL.xml", "IHMConfig_TDL.xml", "launch_dltes16_TDL.bat", "launch_IHM_TDL.bat");
	my @SPYLINKS_CONFIG_FILE = ("SpyLinksConfig.xml", "Spy-Links.exe.config");
	my @CONTEXT_BUILDER_CONFIG_FILE = ("ContextFileBuilder.bat");
	my $HOST_TD_NUM = 1;
	local $HOST_TD = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "HOST_TD" ,
				'SOURCE_CONFIG_DIR'		=> "HOST_TD",
				'FILE_LIST' 	=> \@HOST_TD_CONFIG_FILE,
				'OPERATING_SYST'	=> "SOLARIS"
	};
	my $JREP_NUM = 2;
	local $JREP = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "JREP" ,
				'SOURCE_CONFIG_DIR'		=> "JREP\\conf",
				'FILE_LIST' 	=> \@JREP_CONFIG_FILE,
				'OPERATING_SYST'	=> "SOLARIS"
	};

	my $TDL_ROUTER_NUM = 3;
	local $TDL_ROUTER = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "TDL_ROUTER" ,
				'SOURCE_CONFIG_DIR'		=> "TDL_ROUTER",
				'FILE_LIST' 	=> \@TDL_ROUTER_CONFIG_FILE,
				'OPERATING_SYST'	=> "SOLARIS"
	};

	my $JREM_NUM = 4;
	local $JREM = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "JREM" ,
				'SOURCE_CONFIG_DIR'		=> "JREM\\properties",
				'FILE_LIST' 	=> \@JREM_CONFIG_FILE,
				'OPERATING_SYST'	=> "WINDOWS"
	};
	my $DLIP_COM_NUM = 5;
	local $DLIPCOM = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "DLIPCOM" ,
				'SOURCE_CONFIG_DIR'		=> "DLIPCOM\\properties",
				'FILE_LIST' 	=> \@DLIPCOM_CONFIG_FILE,
				'OPERATING_SYST'	=> "WINDOWS"
	};

	my $DLTE_TDL_NUM = 6;
	local $DLTE_TDL = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "DLTE_TDL" ,
				'SOURCE_CONFIG_DIR'		=> "DLTE_S16_TDL",
				'FILE_LIST' 	=> \@DLTE_TDL_CONFIG_FILE,
				'OPERATING_SYST'	=> "WINDOWS"
	};

	my $SPYLINKS_NUM = 7;
	local $SPYLINKS = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "TOPLINKSPY" ,
				'SOURCE_CONFIG_DIR'		=> "TOPLINKSPY\\TopLink-Spy",
				'FILE_LIST' 	=> \@SPYLINKS_CONFIG_FILE,
				'OPERATING_SYST'	=> "WINDOWS"
	};

	my $CONTEXT_BUILDER_NUM = 8;
	local $CONTEXT_BUILDER = {	'NUM'		=> 0, 
				'TARGET_CONFIG_DIR' 	=> "CONTEXT_BUILDER" ,
				'SOURCE_CONFIG_DIR'		=> "ContextFileBuilder",
				'FILE_LIST' 	=> \@CONTEXT_BUILDER_CONFIG_FILE,
				'OPERATING_SYST'	=> "WINDOWS"
	};

	getConfig()if($opt_g);
	setConfig()if($opt_s);
	return 0;
}

sub getConfig(){
	mkdir ($CONFIG_ROOT_DIR) if (! -d $CONFIG_ROOT_DIR);
	mkdir ("$CONFIG_ROOT_DIR\\$CONFIG_DIR") if ( ! -d "$CONFIG_ROOT_DIR\\$CONFIG_DIR");
	foreach my $task (@TaskList) {
		my $source_config_dir = $$task->{'SOURCE_CONFIG_DIR'};
		my $target_config_dir = $$task->{'TARGET_CONFIG_DIR'};
		$target_config_dir = "$CONFIG_ROOT_DIR\\$CONFIG_DIR\\$target_config_dir";
		mkdir("$target_config_dir") if ( ! -d $target_config_dir);
		foreach my $file ( @{$$task->{'FILE_LIST'}} ){
			my $dir = $ENV{PWD};
			print "$file $dir\n";
			if ( ! -f $file ) {				
				if($$task->{'OPERATING_SYST'}eq "SOLARIS"){
					my $ssource_config_dir = "$SOLARIS_MACHINE_NAME:$SOLARIS_ROOT_DIR/$source_config_dir";
					print ("pscp $ssource_config_dir/$file $target_config_dir\n");
					system( "pscp $ssource_config_dir/$file $target_config_dir");
				}
				if($$task->{'OPERATING_SYST'}eq "WINDOWS"){
					my $ssource_config_dir = "$WINDOWS_ROOT_DIR\\$source_config_dir";
					print "xcopy /I $ssource_config_dir\\$file $target_config_dir\n";					
					system( "xcopy /I $ssource_config_dir\\$file $target_config_dir") ;
				}
			}
		}
		chdir("..");
	}
	return 0;
}

sub setConfig(){
	(-d $CONFIG_ROOT_DIR) or die "$CONFIG_ROOT_DIR dont exist !\n";	
	(-d "$CONFIG_ROOT_DIR\\$CONFIG_DIR") or die "$CONFIG_DIR dont exist !\n"; ;
	foreach my $task (@TaskList) {
		my $source_config_dir = $$task->{'SOURCE_CONFIG_DIR'};
		my $target_config_dir = $$task->{'TARGET_CONFIG_DIR'};
		$target_config_dir = "$CONFIG_ROOT_DIR\\$CONFIG_DIR\\$target_config_dir";
		(-d $target_config_dir) or die ("$target_config_dir dont exist !\n");
		foreach my $file ( @{$$task->{'FILE_LIST'}} ){
			my $dir = $ENV{PWD};
			print "$target_config_dir\\$file $dir\n";
			if ( ! -f "$target_config_dir\\$file" ) {
				if($$task->{'OPERATING_SYST'}eq "SOLARIS"){
					my $ssource_config_dir = "$SOLARIS_MACHINE_NAME:$SOLARIS_ROOT_DIR/$source_config_dir";
					print ("pscp $target_config_dir/$file $ssource_config_dir\n");
					system( "pscp $target_config_dir/$file $ssource_config_dir")if($$task->{'OPERATING_SYST'}eq "SOLARIS" && ! $debug);
				}
				if($$task->{'OPERATING_SYST'}eq "WINDOWS"){
					my $ssource_config_dir = "$WINDOWS_ROOT_DIR\\$source_config_dir";
					print "xcopy /I $target_config_dir\\$file $ssource_config_dir\n";					
					system( "xcopy /I $target_config_dir\\$file $ssource_config_dir") if($$task->{'OPERATING_SYST'}eq "WINDOWS" && ! $debug) ;
				}
			}
		}
		chdir("..");
	}
	return 0;
}


	