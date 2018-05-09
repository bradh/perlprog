#!/usr/bin/perl -w

# Calcule le nombre de message par seconde dznd un fichier
# On suppose que le fichier est de la forme hh:mm:ss.mmm msg <en hexa>
# Le script n'identifie pas les types de message, un pré traitement des fichiers doit être fait
use strict;
use Getopt::Std;
use lib qw(c:/perlprog/lib);
use Conversion;

my @file_name = ("jre_101_remote.log", "jre_101_local.log");

foreach my $file (@file_name) {
	open Fin, "<$file" or die "impossible open $file";
	open Fout, ">$file.stat" or die "impossible open $file.stat";
	print Fout "$file Statistique\n";
	my $prev_chrono = 0;
	my $msg_count = 0;
	my $msg_count_per_12 = 0;
	while (<Fin>){
		my $line = $_;
		if ($line =~ /^\s*(\d\d):(\d\d):(\d+)/) {
			my $heure = $1;
			my $minute = $2;
			my $seconde = $3;
			my $new_chrono = int (Conversion::toChrono($heure, $minute, $seconde, 0));
			#print Fout "$new_chrono vs $prev_chrono\n";
			
			$prev_chrono = $new_chrono if ($prev_chrono == 0);
			if ($new_chrono > $prev_chrono){			
				while($prev_chrono < $new_chrono - 1) {
					print Fout "$prev_chrono\t0\t$msg_count\n";
					$prev_chrono += 1;
				}		
				$msg_count += $msg_count_per_12;
				print Fout "$prev_chrono\t$msg_count_per_12\t$msg_count\n";
				$msg_count_per_12 = 1;	
				$prev_chrono = $new_chrono;
			}
			else {
				$msg_count_per_12 += 1;
				#print Fout "$msg_count_per_12\n";
			}
		}
	}
}
close Fout;
close Fin;
exit 0;