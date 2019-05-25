#!/usr/bin/perl -w
# genere des fichiers .cvs avec 
# l'état de staturation du MIDS 0/1
# l'état du DLIP
# l'envoi du TDH029


use strict;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(c:/perlprog/lib);
use Conversion;
use J_Msg;
use Time_conversion; 
use File::Basename;

my $inFileName = $ARGV[0];
print "$ARGV[0]\n";
#exit;

my $outFileName1 = "extract_NATO.csv";
my $outFileName2 = "extract_NEEDLINE.csv";
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

open Fin, "<$inFileName" or die "impossible open $inFileName ....\n";
open Fout1, ">$outFileName1" or die "impossible open $outFileName1 ....\n";
open Fout2, ">$outFileName2" or die "impossible open $outFileName2 ....\n";

print Fout1 "Chrono;Time;MIDS Status;DLIP Saturation;TDH079\n";
print Fout2 "Chrono;Time;MIDS Status;DLIP Saturation;TDH079\n";



 my $event = 1;
 


while(<Fin>){
	$line = $_;
	print "$line";
	chomp $line;
	$line =~ /^MARTHA :\s.*\s(\d+\.\d\d)/;
	$chrono = $1;
	print "$chrono\n";
	$time = Conversion::toTime($chrono);
	print "$time\n";
	
	if ( $line =~ /NATO Link Saturation State updated: Status/){
		$midsStatus1 = isSaturated();
		if($event){
			$tdh0291 = "0,5";
			$dlipStatus1 = "0,5";
		}					
		printFout1();
	}
	if( $line =~/ Saturation Status on link= 1/){
		
		$dlipStatus1 = isSaturated();
		if($event){
			$midsStatus1 = "0,5";
			$tdh0291 = "0,5";	
		}	
		printFout1();
	}
	if( $line =~/ sending TDH029 with link_id= 1/){
		$tdh0291 = isSaturated();	
		if($event){
			$midsStatus1 = "0,5";
			$dlipStatus1 = "0,5";	
		}	
		printFout1();
	}
	
	if( $line =~/MARTHA Link Saturation State updated: Status/){
		$midsStatus2 = isSaturated();
		if($event){
			$tdh0292 = "0,5";
			$dlipStatus2 = "0,5";
		}	
		printFout2();
	}
	if( $line =~/ Saturation Status on link= 2/){
		$dlipStatus2 = isSaturated();
		if($event){
			$midsStatus2 = "0,5";
			$tdh0292 = "0,5";	
		}	
		printFout2();
	}
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

sub isSaturated {
	$result = 0;
	if ($line =~/\sSATURATED/ || $line =~/INDICATOR_ON/){
		$result = 1;
	}
	return $result;
}
exit 0;