#!/usr/bin/perl -w 

use Getopt::Std; 
use File::Basename;

use LU2_trame;

getopts('hf:');

my $header = "000000D8 20000002 00D4 00FF FFFF 0000 0000 0000 0000 1840 0000 0000";

if(defined $opt_f){
	$input_file = $opt_f;
	open Fin , "<$input_file" or die "impossible open $input_file\n";
	open Fout, ">$input_file.modifed" or die "impossible open $input_file.modifed";
	while(<Fin>){
		my $line = $_;
		chomp $line;		
		if( $line =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})/){	
			print "New scenario message :\n";	
			print "$line\n";	
			my $time = $1;
			my $message_number = 0;
			my $trame = LU2_trame::new();
			my $response = 'y';
			print " Add new word ? (y) : ";
			$response = <>;
			chomp $response;
			
			while($response eq  'y' ){
				$message_number += 1;
				print "Add message n° $message_number\n";
				$trame->add_message($message_number);
				print $trame->get_hexa_trame ."\n";
				print " Add new word ? (y) : ";
				$response = <>;
				chomp $response;
			}
			print $trame->get_hexa_trame ."\n";
			my $formatted_trame = $trame->format();
			print "$formatted_trame\n";
			print Fout "$time ". "$header ". "$formatted_trame\n";
		}
		else{
			print Fout $line . "\n";
		}
	
	}
	close Fin; 
	close Fout;
}		

	
	
	