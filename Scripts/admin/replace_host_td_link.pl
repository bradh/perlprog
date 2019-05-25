#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("he:");

my $Exe_name ="host_test_driver";
my $New_link = "/h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver";

if ($opt_h) { 
	print "replace_exe_link -e exe_path \n";
}

if( ! $opt_h && $opt_e ) {
	if( -f $New_link){
  		my $Exe_path = $opt_e;
		$Exe_path =~ s/($Exe_name)//;
		if ($Exe_path =~ /\/ATR\//){
			print "rm -f $Exe_path$Exe_name\n";
			system("rm -f $Exe_path$Exe_name");
			print "ln -s $New_link $Exe_path\n";
			system("ln -s $New_link $Exe_path\n");
		}
	}
}
exit 0;


