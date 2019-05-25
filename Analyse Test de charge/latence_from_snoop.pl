#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use lib qw(c:/perlprog/lib);
use Conversion;

my @file_name = ("remote_tx.csv");

foreach my $file (@file_name) {
	open Fin, "<$file" or die "impossible open $file";
	open Fout, ">snoop_latency.txt" or die "impossible open jre_101.log";
	my ($dump, $date_tx, $seq_num_tx, $date_rx, $seq_num_rx);
	while (<Fin>){
		my $line = $_;
		chomp $line;
		my @champs = split(";", $line);
		if($champs[1] =~/Push/){
				($date_tx, $dump, $dump, $seq_num_tx, $dump, $dump, $date_rx, $dump, $dump, $seq_num_rx) = split(";", $line);
		}
		else{
				($date_tx, $dump, $seq_num_tx, $dump, $dump, $dump, $date_rx, $dump, $seq_num_rx) = split(";", $line);
		}
		($dump, $seq_num_tx) = split("=", $seq_num_tx);
		($dump, $seq_num_rx) = split("=", $seq_num_rx);
		#print Fout "$seq_num_tx -> $seq_num_rx\n";
		if ($seq_num_rx == $seq_num_tx){
			my($heure_tx, $minute_tx, $seconde_tx) = split(":", $date_tx);
			#($seconde_tx, my $milli_tx) = split(".", $seconde_tx);
			my($heure_rx, $minute_rx, $seconde_rx) = split(":", $date_rx);
			#($seconde_rx, my $milli_rx) = split(".", $seconde_rx);
			
			#print Fout "$date_tx, $date_rx\n";
			my $chrono_rx = Conversion::toChrono($heure_rx, $minute_rx, $seconde_rx, 0);
			my $chrono_tx = Conversion::toChrono($heure_tx, $minute_tx, $seconde_tx, 0);
			#print Fout "$heure_tx, $minute_tx, $seconde_tx -> $heure_rx, $minute_rx, $seconde_rx \n";
			#print Fout "$chrono_tx  $chrono_rx \n";
			my $latency = $chrono_rx - $chrono_tx;
			print Fout "$latency \n";
		}
		else {
				print "$date_tx, $seq_num_tx, $date_rx, $seq_num_rx, Msg rx doesn't match Msg Rx\n"
		}
	}
	close Fin;
	close Fout;
}
exit 0;