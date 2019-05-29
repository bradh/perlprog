#!/usr/bin/perl -w 

use Getopt::Std; 
use File::Basename;

use lib qw(D:\Users\t0028369\perlprog\lib);
use Conversion;

use lib qw(..);
use TRA5400N_trame;

my $SAMPT_scripts_dir = "D:\\Users\\t0028369\\Documents\\Mes\ outils\ personnels\\perlprog\\Admin";

getopts('hf:');
#bl2 header avec longueur full time slot 24 mot de 64 bits
my $tr_header = "000000D4 22000002";
# header full longueur 104 , msg type reception data, pas d'erreur
my $trg_header = "0068 0004 0C00 0000 0000 0000";

if(defined $opt_f){

	$input_file = $opt_f;
	
	open Fin , "<$input_file" or die "impossible open $input_file\n";
	open Fout, ">$input_file.bl" or die "impossible open $input_file.bl";
	
	my $first_line = 1;
	my $first_chrono = 0;
	
	while(<Fin>){
		my $line = $_;
		print "$line";
		chomp $line;		
		if( $line =~ /^(\d{2}:\d{2}:\d{2}\.\d{3}) (\S{8}) (\S{8}) (.*)/) {	
			print "New scenario message : ";	
			print "$line\n";	
			my ($time, $length, $trr_header, $tra_trame) = ($1, $2, $3, $4);
			print "$time, $length, $trr_header, $tra_trame\n";
			if($first_line){
				$first_chrono = $time;
				$first_line = 0;
			}
			my $r_tra_trame = TRA5400N_trame::new($tra_trame);
			my $data = $r_tra_trame->{'data lu2'};
			# bourrage de data avec des 0 24  * 64 bits
			while(length $data < 384){
				$data = "$data" . "00";
			}
			$data =~ s/(\S{4})/$1 /g;
			my $ec_bytes = $r_tra_trame->{'wrong words'};
			$ec_bytes = substr($ec_bytes, 0, 8);
			print Fout "$time $tr_header $trg_header $ec_bytes $data\n";
			print "$time $tr_header $trg_header $ec_bytes $data\n";
		}
	}
	close Fin; 
	close Fout;
	my $delta_scenario = 5 - Conversion::timeToChrono($first_chrono);
	print "delta scenario = $delta_scenario\n";
	system( "$SAMPT_scripts_dir\\translate_time.pl -f $input_file.bl -s $delta_scenario");
}		

exit 0;





	