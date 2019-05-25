#!/usr/bin/perl -w

# calcule le temps de transit des messages 
# a partir d'un fichier input1 au format hh:mm:ss.mmm <MSG>
# d'un fichier input2 au format identique
# produit un fichier <diff en ms> <MSG>

# Algorithme
# pour chaque message du fichier input1
# recherche le message du fichier input2 tel que
# que les messages soient identiques 
# que le temps du message de sortie soit > au temps du message d'entrée

# systaxe
# time_diff_calculate.pl -i <input_msg_file> -o <output_msg_file> -r <result_file>

use Getopt::Std;
use lib qw(G:/Tools/perlprog/lib);
use Conversion;

getopts("hi:o:r:");

if($opt_h){	
	print "usage : time_diff_calculate.pl -i <input_msg_file> -o <output_msg_file> -r <result_file>\n";
}

if(defined $opt_i && $opt_o && $opt_r){
	open Fin1, "<$opt_i" or die "impossible open $opt_i";
	open Fin2, "<$opt_o" or die "Impossible open $opt_o\n";
	open Fout, ">$opt_r" or die "impossible open $opt_r";
	
	print Fout "Transit Time (ms); Message\n";
	print "Calculting transit time, please wait...\n";
	
	my $transit_time_max = 0;
	
	while(<Fin1>){
		my $line = $_;
		chomp $line;
		#print "$line\n";
		my ($time, $msg_in) = split(" ",$line);
		#print "time in : $time, $msg_in\n";
		my $chrono_in = get_chrono_from_time($time);
		my $chrono_out = find_chrono_msg_out($chrono_in, $msg_in);
		#my $transit_time = int(($chrono_out - $chrono_in)*1000);
		my $transit_time = int(($chrono_out - $chrono_in)*1000);
		exit -1 if($transit_time > 1000);
		$transit_time_max = $transit_time if($transit_time_max < $transit_time);
		print Fout "$transit_time;$msg_in\n";
	}
	print "**** Transit Time Max = $transit_time_max\n";
	close Fin1;
	close Fin2;
	close Fout;
}
else {
	print "usage : time_diff_calculate.pl -i <input_msg_file> -o <output_msg_file> -r <result_file>\n";
}

exit 0;

sub get_chrono_from_time {
	my $time = shift;
	
	$time =~ /(\d\d):(\d\d):(\d\d)\.(\d{3})/;
	my $hour = $1;
	my $min = $2;
	my $sec = $3;
	my $milli = $4;
	
	#print "$time, $hour, $min, $sec, $milli\n";
	my $chrono_in = Conversion::toChrono($hour, $min, $sec, $milli);
	#print "$chrono_in\n";
	return $chrono_in;
}

sub find_chrono_msg_out {
	my $chrono_in = shift;
	my $msg_in = shift;
	my $chrono_out = 0;
	#open Fin2, "<$opt_o" or die "Impossible open $opt_o\n";
	while(<Fin2>) {
		my $line = $_;
		chomp $line;
		if($line =~ /$msg_in/){
			my ($time, $msg_out) = split(" ",$line);
			#print "time out: $time, $msg_out\n";
			my $chrono_out = get_chrono_from_time($time);
			if($chrono_out >= $chrono_in){
				return $chrono_out;
			}
			else{
				next;
			}
		}
	}
	#close Fout2;
	
}
