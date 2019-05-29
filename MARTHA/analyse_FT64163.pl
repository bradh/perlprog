#!/usr/bin/perl -w
# genere des fichiers .cvs avec 
# l'état de staturation du MIDS 0/1
# l'état du DLIP
# l'envoi du TDH029
# SAT_IND_MGR_WITH_REPORT_TO_HOST
# SUPERVISION
# L16_CTRL

use strict;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
#use lib qw(c:/perlprog/lib);
use lib qw(D:\Users\t0028369\perlprog\lib);

use Conversion;
use J_Msg;
use Time_conversion; 
use File::Basename;

my $INPUT_FILE_DIR = ".";
my $inFileName = "martha_main.error_avec_saturation_V21R0E47-BN-0085.log";
#my $inFileName = $ARGV[0];
#print "$ARGV[0]\n";
#exit;

my $outFileName1 = "extract_NATO_MDa.csv";
my $outFileName2 = "extract_NEEDLINE_MDa.csv";
my $line;
my $result;
my $chrono = 0000.00;
my $time = "00:00:00.000";
my $midsStatus1 = 0;
my $dlipStatus1 = 0;
my $tdh0291 = 0;
my $midsStatus2 = 0;
my $dlipStatus2 = 0;
my $tdh0292 = 0;
my $delta;

open Fin, "<$INPUT_FILE_DIR\\$inFileName" or die "impossible open $inFileName ....\n";
open Fout1, ">$INPUT_FILE_DIR\\$outFileName1" or die "impossible open $outFileName1 ....\n";
open Fout2, ">$INPUT_FILE_DIR\\$outFileName2" or die "impossible open $outFileName2 ....\n";

print Fout1 "Chrono;Time;MIDS Status;DLIP Saturation;TDH029;retard (ms)\n";
print Fout2 "Chrono;Time;MIDS Status;DLIP Saturation;TDH029;retard (ms)\n";



 my $event = 1;
 


while(<Fin>){
	$line = $_;
	print "$line";
	chomp $line;
#	$line =~ /^MARTHA :\s.*\s(\d+\.\d\d)/;
	if($line =~ /^MARTHA : \+\+\s+(\d+\.\d\d\d\d)/){
			$chrono = $1;
		print "$chrono\n";
		$time = Conversion::toTime($chrono);
		print "$time\n";
	}
	else {
		next;
	}

	
	# analyse des messages lost
	if( $line =~/Log message\(s\) lost/){
		printFout4();
	}
	
	# analyse des retards 
	if ( $line =~/Delta between real and scheduled times of tx \(in ms\)= (\d+)/){
		$delta = $1;
		printFout3();
	}
	# test de l'etat de saturation du terminal MIDS sur L16NATO
	if ( $line =~ /NATO Link Saturation State updated: Status/){
		$midsStatus1 = isSaturated();
		if($event){
			$tdh0291 = "0,5";
			$dlipStatus1 = "0,5";
		}					
		printFout1();
	}
	# verification du retard de l'emission d'une piste J3_2 J3_5 L16 NATO
	if( $line =~/ Saturation Status on link= 1/){
		
		$dlipStatus1 = isSaturated();
		if($event){
			$midsStatus1 = "0,5";
			$tdh0291 = "0,5";	
		}	
		printFout1();
	}
	# etat de saturation renvoye a l hote via le TDH029 L16 NATO
	if( $line =~/ sending TDH029 with link_id= 1/){
		$tdh0291 = isSaturated();	
		if($event){
			$midsStatus1 = "0,5";
			$dlipStatus1 = "0,5";	
		}	
		printFout1();
	}
	# test de l'etat de saturation du terminal MIDS sur L16AT
	if( $line =~/MARTHA Link Saturation State updated: Status/){
		$midsStatus2 = isSaturated();
		if($event){
			$tdh0292 = "0,5";
			$dlipStatus2 = "0,5";
		}	
		printFout2();
	}
	# verification du retard de l'emission d'une piste J3_2 J3_5 L16AT
	if( $line =~/ Saturation Status on link= 2/){
		$dlipStatus2 = isSaturated();
		if($event){
			$midsStatus2 = "0,5";
			$tdh0292 = "0,5";	
		}	
		printFout2();
	}
	# etat de saturation renvoye a l hote via le TDH029 L16AT
	if( $line =~/ sending TDH029 with link_id= 2/){
		$tdh0292 = isSaturated();
		if($event){
			$midsStatus2 = "0,5";
			$dlipStatus2 = "0,5";	
		}		
		printFout2();
	}
}

close Fin;
close Fout1;
close Fout2;

sub printFout1 {
	print Fout1 "$chrono;$time;$midsStatus1;$dlipStatus1;$tdh0291\n";	
}

sub printFout2 {
	print Fout2 "$chrono;$time;$midsStatus2;$dlipStatus2;$tdh0292\n";	
}
sub printFout3 {
	print Fout1 "$chrono;$time;;;;$delta\n";
	print Fout2 "$chrono;$time;;;;$delta\n";	
}
sub printFout4 {
	print Fout1 "$chrono;$time;;;;;Log message(s) lost\n";
	print Fout2 "$chrono;$time;;;;;Log message(s) lost\n";
}

sub isSaturated {
	$result = 0;
	if ($line =~/\sSATURATED/ || $line =~/INDICATOR_ON/){
		$result = 1;
	}
	return $result;
}
exit 0;