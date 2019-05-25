#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

my $fileInput;
my @hearderFieldsSelect = ("JRE_Sender_Id", "Data_Valid_Time");
my @subheaderFieldsSelect = ("JRE_Source_Track_Number", "Label", "Sublabel", "Codeword_Ids", "Ack_Protocol", "Sequence_Number", "Control_Response","Error_Code", "Originating_Sequence_Number", "Destination_Address ( 1)");

getopts("f:r:d:n:c:t:s:e:l:x:a:j:h:");

if(defined $opt_h){
	print "usage : JREcompact.pl : regroupe tous les champs sur 1 ligne\n
								-h 	help\n
								-f	<file> : ecrit dans un fichier file\n"
								;
}
if(defined($opt_f)){
	$fileInput = $opt_f;
	open FIN, "<$fileInput" or die "Impossible d'ouvrir $fileInput";
}
my $nberMsg =0;
my $msgDate;
my $msgTime;
my $msgLink; 
my $msgDirection;
my $msgName = "Round_Trip_Time_Delay";
my $msgState="wait";
my $msgHeader="HEADER";
my $msgSubheader="SUBHEADER";
my $msgJcodeword;
my $msgBody="BODY";
my $field;
my $value;


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
	     #\&$msgName();
		$msgState = "wait";
		# affiche dans la sortie standard
		my $msg = "$msgTime;$msgName;$msgLink;$msgDirection;$nberMsg;$msgHeader;$msgSubheader;$msgBody\n";
		print $msg;
		# ecrit dans le fichier si défini
		if(defined($fileInput)){
			print FIN "$msg";
		}
		print
		#print "$msgHeader\n";
		$msgHeader = "HEADER";
		#print "$msgSubheader\n";
		$msgSubheader = "SUBHEADER";
		#print "$msgBody\n";
		#print "\n";
		$msgBody = "BODY";
		#sleep 2;
	}
	if($msgState =~ /HEADER/ && $msgState !~ /SUBHEADER/){
		#print "$line\n";
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgHeader = "$msgHeader;$field=$value";
	}
	if($msgState =~ /SUBHEADER/){
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgSubheader = "$msgSubheader;$field=$value";
	}
	if($msgState =~ /BODY/){
		($field, $value) = getPair(\$line);
		#$field = substr($field, 0, 8);
		$msgBody = "$msgBody;$field=$value";
	}	
}
if(defined($fileInput)){
	close FIN;
}
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


