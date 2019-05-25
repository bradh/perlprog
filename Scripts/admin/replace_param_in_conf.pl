#!/bin/perl -w

use Getopt::Std;


getopts("hf:");

my $FIELD_TO_DELETE_1="SIMPLE_PROTOCOL=\"TCP_CLIENT\"";
my $FIELD_TO_DELETE_2="API_Recorder_TCP_Port";
my $FIELD_TO_DELETE_3="Host_UDP_Port_Min";
my $FIELD_TO_DELETE_4="Host_UDP_Port_Max";
my $FIELD_TO_DELETE_5="FOM14_Registration";
my $FIELD_TO_DELETE_6="Net_No";

my $FIELD_TO_DELETE_7="LLAPI links";
my $FIELD_TO_DELETE_8="COM_TCP_Port_";


my $FIELD_VALUE="/h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/d_sampt_c2.xml";

if ($opt_h) { 
	print "replace_param_in_conf \n";
}

if( ! $opt_h && $opt_f) {
  my $File = $opt_f;

  open Fin, "<$File" or die "impossible ouvrir $File\n";
  open Fout, ">tempxx" or die "impossible ouvrir tempxx\n";
  while (<Fin>){
    my $Line = $_;
    chomp $Line;
    print Fout "$Line\n";
  }
  print Fout "--rte.t0_for_traces_to_full_hour=true\n";
  print $File;
  close Fin;
  close Fout;
  print "mv tempxx $File\n";
  system("mv tempxx $File");
}					    
exit 0	  



