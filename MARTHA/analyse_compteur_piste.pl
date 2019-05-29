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



my $INPUT_FILE_DIR = 'D:\Users\t0028369\Documents\MARTHA_MCO\ESSAI_MDM_2016_10_04\2016_10_06\aprem2';

foreach my $i (0..5){
	my $inFileName = "DLIP_Martha$i.log";
	
	my $outFileName1 = "$INPUT_FILE_DIR\\tract_start_by_log$i.txt";
	
	my $chrono = 0000.00;
	my $time = "00:00:00.000";
	
	my $delta = 55880;
	
	open Fin, "<$INPUT_FILE_DIR\\$inFileName" or die "impossible open $inFileName ....\n";
	open Fout1, ">$outFileName1" or die "impossible open $outFileName1 ....\n";
	
	print Fout1 "\n";
	
	 	my $msgCptTx1 = 0;
	 	my $msgCptFilt1 = 0;
		my $msgCptTx2 = 0;
		my $msgCptFilt2 = 0;

	while(<Fin>){
		my $line = $_;
		#print "$line";
		#chomp $line;
		
		
		# analyse des messages lost
		if( $line =~ /System_TN/ && $line =~ /Internal/ && $line =~ /Link/ && $line =~ /Link_TN/&& $line =~ /Tx_State/){
			
			$line =~ /^MARTHA :\s.*\s(\d+\.\d\d)/;
			$chrono = $1;
			#print "$chrono\n";
			$time = Conversion::toTime($chrono + $delta);

			#print "$time\n";
			#print Fout1 $line;
			#print $line;
			#print Fout1 "$chrono;$time;link ID 1 ; tx nber ; $msgCptTx1 ; filtered nber ; $msgCptFilt1\n";
			print Fout1 "$chrono;$time;link ID 2 ; tx nber ; $msgCptTx2 ; filtered nber ; $msgCptFilt2\n";
				$msgCptTx1 = 0;
			 	$msgCptFilt1 = 0;
				$msgCptTx2 = 0;
				$msgCptFilt2 = 0;
		}
		$line =~ s/\|/;/g;
		#print $line;
		#if ($line =~ /\s?(\d?) \/ (\d?)\s?;\s?(\d?) ;\s?(\d)\s?;\s?(\d?)\s?;\s?(\d?)\s?;\s?(.?)$/ ){
		if ($line =~ /\s?(\d*)\s\/\s(\d*)\s*;\s*(\d*)\s*;\s*(\d)\s*;\s*(\d*)\s*;\s*(\d*)\s*;\s*(.*)$/){
				#print "$1;$2;$3;$4;$5;$6;$7;$line";
				my $sysTN = $1;
				my $linkID = $4;
				my $linkTN = $5;
				my $txState = $7;
				print "sysTN = $sysTN; linkTN = $linkTN; linkID = $linkID; txState = $txState\n";
				#print Fout1 "sysTN = $sysTN; linkTN = $linkTN; linkID = $linkID; txState = $txState\n";
				if($linkID == 1 && $txState =~ /TX_EFFECTIVE/){					
						$msgCptTx1 += 1;
				}			
				if($linkID == 1 && $txState =~ /FILTERED/ && $sysTN != 0){					
						$msgCptFilt1 += 1;
				}
				if($linkID == 2 && $txState =~ /TX_EFFECTIVE/){					
						$msgCptTx2 += 1;
				}
				if($linkID == 2 && $txState =~ /FILTERED/ && $sysTN != 0){					
						$msgCptFilt2 += 1;
				}
				
				#print Fout1 "System_TN = $1 ," . "Info_key = $2\n";
				#print "System_TN = $1 ," . "Info_key = $2\n";
				#print "Internal_Key = $3\n";
		}
		
		# analyse des retards 
	
	}
	close Fin;
	close Fout1;

}
exit 0;