#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

my @hearderFieldsSelect = ("JRE_Sender_Id", "Data_Valid_Time");
my @subheaderFieldsSelect = ("JRE_Source_Track_Number", "Label", "Sublabel", "Codeword_Ids","Ack_Protocol", "Sequence_Number", "Control_Response","Error_Code", "Originating_Sequence_Number", "Destination_Address ( 1)");

getopts("f:rdnctselxajh");

if(defined $opt_h){
	print "usage : JREfilter.pl -h 	help\n
								-f	<file extension> : write in a file\n
								-r	: display RTTD msg\n
								-d	: display Direct Connexion List msg\n
								-n 	: display Network Connexion matrix\n
								-c	: display Connectivity Feedback\n
								-t	: display Common time Reference msg\n
								-s	: display Secondary TN List msg\n
								-e	: display Echo msg\n
								-l	: display Latency Threshold msg\n
								-x	: display Latency Exceeded msg\n
								-a	: display JJSA msg\n
								-j	: display J msg\n
								-h	: display this help msg\n";
}

my $fileInput = $opt_f;
#open FIN, "<$fileInput" or die "Impossible d'ouvrir $fileInput";
my $nberMsg =0;
my $msgDate;
my $msgTime;
my $msgLink; 
my $msgDirection;
my $msgName = "Round_Trip_Time_Delay";
my $msgState="wait";
my $msgHeader="";
my $msgSubheader="";
my $msgJcodeword;
my $msgBody="";
my $field;
my $value;

open FRTT, ">MT_MANAGEMENT_Round_Trip_Time_Delay$fileInput.txt" or die "impossible ouvrir MT_MANAGEMENT_Round_Trip_Time_Delay" if(defined($opt_r));
open FDCL, 	">MT_MANAGEMENT_Direct_Connection_List$fileInput.txt" or die "Impossible ouvrir MT_MANAGEMENT_Direct_Connection_List.csv" if(defined($opt_d));
open FNCM, 	">MT_MANAGEMENT_Network_Connectivity_Matrix$fileInput.txt" or die "Impossible ouvrir MT_MANAGEMENT_Network_Connectivity_Matrix.csv" if(defined($opt_n));
open FCFK, 	">MT_MANAGEMENT_Connectivity_Feedback$fileInput.txt"	or die "Impossible ouvrir MT_MANAGEMENT_Connectivity_Feedback.csv" if(defined($opt_c));
open FCTR,	">MT_MANAGEMENT_Common_Time_Reference$fileInput.txt" or die "Impossible ouvrir MT_MANAGEMENT_Common_Time_Reference.csv" if(defined($opt_t));
open FSTN, "> MT_MANAGEMENT_Secondary_Track_Number_List$fileInput.txt" or die if(defined($opt_s));
open FECH,	">MT_MANAGEMENT_Echo$fileInput.txt" or die "Impossible ouvrir MT_MANAGEMENT_Echo.csv"if(defined($opt_e));
open FLTH, 	">MT_MANAGEMENT_Latency_Threshold$fileInput.txt" or die if(defined($opt_l));
open FLEX, ">MT_MANAGEMENT_Latency_Exceeded$fileInput.txt" or die if(defined($opt_x));
open FJJSA,	">JREAP_J_Series_Acknowledgment$fileInput.txt" or die if(defined($opt_a));
open FJJS,	">JREAP_J_SERIES$fileInput.txt" or die "Impossible ouvrir MT_JREAP_J_SERIES.csv" if(defined($opt_j));

my $firstRound_Trip_Time_Delay = 1;
my $firstDirect_Connection_List = 1;
my $firstNetwork_Connectivity_Matrix = 1;
my $firstConnectivity_Feedback = 1;
my $Common_Time_Reference = 1;
my $firstSecondary_Track_Number_List = 1;
my $firstEcho = 1;
my $firstLatency_Threshold = 1;
my $firstLatency_Exceeded = 1;

while(<>){
	
	my $line = $_;
	chomp $line;
	#print $line;
		#-(\d{2}:\d{2}:\d{2}\.\d?)\s*(\S)\s*(\d*)\s*(\S*)
	if($line =~ /^(\d{2}:\d{2}:\d{2}\.\d*);([^;]*);([^;]*);([^;]*);/){
		#print $line;
		$msgState = "START";
		$msgTime = $1;
		$msgName = $2;
		$msgLink = $3;
		$msgDirection = $4;

		#print "$msgName\n";
		$nberMsg++;
		(my $msg, $msgBody) = (split ("BODY;", $line));
		#print "$line \n $msg \n $msgBody\n";
		($msg, $msgSubheader) = (split ("SUBHEADER;", $msg));
		($msg, $msgHeader) = (split("HEADER;", $msg));
		#print "HEADER : $msgHeader\n";
		#print "SUBHEADER : $msgSubheader\n";
		#print "BODY : $msgBody\n";
		#print "time : $msgTime; Name : $msgName; Link : $msgLink; Direction : $msgDirection; \n"; #etc : $nberMsg; $msgHeader; $msgSubheader; $msgBody\n";
		#sleep 1;
		\&$msgName();
	}
}

close FRTT if(defined($opt_r));
close FDCL if(defined($opt_d));
close FNCM if(defined($opt_n));
close FCFK if(defined($opt_c));
close FCTR if(defined($opt_t));
close FSTN if(defined($opt_s));
close FECH if(defined($opt_e));
close FLTH if(defined($opt_l));
close FLEX if(defined($opt_x));
close FJJSA if(defined($opt_a));
close FJJS if(defined($opt_j));

exit 0;

sub getPair{
	my $r_line = shift;
	my ($field, $value) = (split("=", $$r_line));
	$field =~ s/\s*//g;
	$value =~ s/\s*//g;
	#$field = substr($field, 0, 20);
	#$value = substr($value, 0, 10);
	return ($field, $value);
}


sub Round_Trip_Time_Delay{
		my $msg;
		#print "\n$msgTime; $msgLink; $msgDirection; Round_Trip_Time_Delay\n";
		$msg = "$msgTime;".fieldsSelect(\$msgHeader, \@hearderFieldsSelect). fieldsSelect(\$msgSubheader, \@subheaderFieldsSelect)."$msgBody\n";
		print "$msg"  if(defined($opt_r));
		print FRTT "$msg"  if(defined($opt_r));
		return;
}

sub Direct_Connection_List {
	#print "Direct_Connection_List\n";
	return;
}

sub Network_Connectivity_Matrix {
	#print "Network_Connectivity_Matrix\n";
	return;
}

sub Connectivity_Feedback {
	#print "Connectivity_Feedback\n";
	return;
}

sub Common_Time_Reference {
	#print "Common_Time_Reference\n";
	return;
}

sub Secondary_Track_Number_List {
	#print "Secondary_Track_Number_List\n";
	return;
}

sub Echo {
	#print "Echo\n";
	return;
}

sub JREAP_J_Series_Acknowledgment { 
	#print "JREAP_J_Series_Acknowledgment\n";
	return;
}

sub Latency_Threshold {
	#print "Latency_Threshold\n";
	return;
}

sub Latency_Exceeded {
	#print "Latency_Exceeded\n";
	return;
}

sub Internal_State_Info_Set {
  return 0;
}

sub MT_JREAP_J_SERIES {
	#print "MT_JREAP_J_SERIES\n";
	my $msg;
		#print "\n$msgTime; $msgLink; $msgDirection; Round_Trip_Time_Delay\n";
	$msg = $msgTime . fieldsSelect(\$msgHeader, \@hearderFieldsSelect). fieldsSelect(\$msgSubheader, \@subheaderFieldsSelect)."$msgBody\n";
	print "$msg" if(defined($opt_j));
	print FJJS "$msg"  if(defined($opt_j));
	#sleep 1;
	return;
}

sub fieldsSelect {
	my $r_msg = shift;
	my $r_fieldSelect = shift;
	my $select = "";
	my (@couple) = (split(";", $$r_msg));

	foreach my $fields (@$r_fieldSelect) {
		foreach my $couple (@couple){
			$select = $select.$couple.";\t" if($couple =~ /$fields/ );
		}
	}
	
	#print "$select\n";
	return $select;
}

sub subHeaderDisplay {
	
}
