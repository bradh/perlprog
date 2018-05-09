#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

my @hearderFieldsSelect = ("JRE_Sender_Id", "Data_Valid_Time");
my @subheaderFieldsSelect = ("Ack_Protocol", "Sequence_Number", "Control_Response","Error_Code", "Originating_Sequence_Number", "Destination_Address ( 1)");

getopts("f:r:d:n:c:t:s:e:l:x:a:j:h:");

if(defined $opt_h){
	print "usage : JREfilter.pl -h 	help\n
								-f	<file>\n
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

#my $fileInput = $opt_f;
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

open FRTT, ">MT_MANAGEMENT_Round_Trip_Time_Delay.csv" or die "impossible ouvrir MT_MANAGEMENT_Round_Trip_Time_Delay";
open FDCL, 	">MT_MANAGEMENT_Direct_Connection_List.csv" or die "Impossible ouvrir MT_MANAGEMENT_Direct_Connection_List.csv";
open FNCM, 	">MT_MANAGEMENT_Network_Connectivity_Matrix.csv" or die "Impossible ouvrir MT_MANAGEMENT_Network_Connectivity_Matrix.csv";
open FCFK, 	">MT_MANAGEMENT_Connectivity_Feedback.csv"	or die "Impossible ouvrir MT_MANAGEMENT_Connectivity_Feedback.csv";
open FCTR,	">MT_MANAGEMENT_Common_Time_Reference.csv" or die "Impossible ouvrir MT_MANAGEMENT_Common_Time_Reference.csv";
open FSTN, "> MT_MANAGEMENT_Secondary_Track_Number_List" or die ;
open FECH,	">MT_MANAGEMENT_Echo.csv" or die "Impossible ouvrir MT_MANAGEMENT_Echo.csv";
open FLTH, 	">MT_MANAGEMENT_Latency_Threshold.csv" or die;
open FLEX, ">MT_MANAGEMENT_Latency_Exceeded.cvs" or die;
open FJJSA,	">JREAP_J_Series_Acknowledgment.csv" or die;

open FJJS,	">MT_JREAP_J_SERIES.csv" or die "Impossible ouvrir MT_JREAP_J_SERIES.csv";

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
	if($line =~ /^(\d{4}\/\d{2}\/\d{2})-(\d{2}:\d{2}:\d{2}\.\d*)\s*(\S)\s*(\d*)\s*(\S*)/){
		#print $line;
		$msgState = "START";
		$msgDate = $1;
		$msgTime = $2;
		$msgDirection = $3;
		$msgLink = $4;
		$msgName = $5;
		#print "$msgName\n";
		$nberMsg++;
	} 
	next if($msgState =~/wait/);
	if($line =~ /-\sHEADER /){
		$msgState = "HEADER" ;
		next;
	}
	if($line =~ /-\sSUBHEADER/){
		$msgState = "SUBHEADER";
		next;
	}
	if($line =~ /-\sBODY/){
		$msgState = "BODY";
		next;
	}
	if($line =~ /Fin de Traitement/){
		$msgJcodeword = $msgName;
		$msgName = "MT_JREAP_J_SERIES" if($msgName =~ /J\d+\./); 
		 # appel de la fonction d'affichage dont le nom est contenu dans la
		 # variable $msgName
		 \&$msgName();
		$msgState = "wait";
		print "$msgTime; $msgName ; $msgLink; $msgDirection; $nberMsg; $msgHeader; $msgSubheader; $msgBody";
		#print "$msgHeader\n";
		$msgHeader = "HEADER; ";
		#print "$msgSubheader\n";
		$msgSubheader = "SUBHEADER; ";
		#print "$msgBody\n";
		#print "\n";
		$msgBody = "BODY; ";
		#sleep 2;
	}
	if($msgState =~ /HEADER/ && $msgState !~ /SUBHEADER/){
		#print "$line\n";
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgHeader = "$msgHeader;\t$field=$value";
	}
	if($msgState =~ /SUBHEADER/){
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgSubheader = "$msgSubheader;\t$field=$value";
	}
	if($msgState =~ /BODY/){
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgBody = "$msgBody;\t$field=$value";
	}	
}
close FIN;
close FRTT;
close FDCL;
close FNCM;
close FCFK;
close FCTR;
close FSTN;
close FECH;
close FLTH;
close FLEX;
close FJJSA;
close FJJS;

exit 0;

sub getPair{
	my $r_line = shift;
	my ($field, $value) = (split("=", $$r_line));
	$field =~ s/\s*//g;
	$value =~ s/\s*//g;
	$field = substr($field, 0, 20);
	$value = substr($value, 0, 10);
	return ($field, $value);
}


sub Round_Trip_Time_Delay{
	my $msg;
	#print "\n$msgTime; $msgLink; $msgDirection; Round_Trip_Time_Delay\n";
	$msg = fieldsSelect(\$msgHeader, \@hearderFieldsSelect);
	#print "Header : $msg\n"; 
	$msg = fieldsSelect(\$msgSubheader, \@subheaderFieldsSelect);
	#print "Subheader : $msg\n";
	#print "$msgBody\n"; # if(defined $opt_r);
	#print FRTT $msg; # if(defined $opt_f);
	sleep 1;
}

sub Direct_Connection_List {
	#print "Direct_Connection_List\n";
}

sub Network_Connectivity_Matrix {
	#print "Network_Connectivity_Matrix\n";
}

sub Connectivity_Feedback {
	#print "Connectivity_Feedback\n";
}

sub Common_Time_Reference {
	#print "Common_Time_Reference\n";
}

sub Secondary_Track_Number_List {
	#print "Secondary_Track_Number_List\n";
}

sub Echo {
	#print "Echo\n";
}

sub JREAP_J_Series_Acknowledgment { 
	#print "JREAP_J_Series_Acknowledgment\n";
}

sub Latency_Threshold {
	#print "Latency_Threshold\n";
}

sub Latency_Exceeded {
	#print "Latency_Exceeded\n";
}

sub MT_JREAP_J_SERIES {
	#print "MT_JREAP_J_SERIES\n";
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
