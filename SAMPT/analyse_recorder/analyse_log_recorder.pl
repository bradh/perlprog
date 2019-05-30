#!/usr/bin/perl

# l'objet de ce script est d'analyser le profil d'ecriture du recorder à partir de son fichier log
# les traces des CSC suivants doivent etre positionnees en detailed_debug
#
# le script calcul de delta entre 2 "ecritures" trace MSG_WRITTEN
# la quantite de donnee entre 2 "ecriture" word_written : xxxx
# le debit d ecriture : quantite ecriture / delta ecriture
#
# la periode des flush
# la quantite de donnee entre 2 flush
# le debit de flush ( doit etre egal au debit d'ecriture)


my $input_dir = ".";
my $input_file = "recorder.log";
my $result_dir =".";
my $result_file = "analyse_log_recorder.csv";
my $result_file2 = "analyse_log_recorder_flush.csv";

open Fin, "<$input_dir/$input_file" or die "impossible ouvrir $input_dir/$input_file \n ";
open Fout, ">$result_dir/$result_file" or die "impossible ouvrir $result_dir/$result_file\n ";
open Fout2, ">$result_dir/$result_file2" or die "impossible ouvrir $result_dir/$result_file2\n ";
my $write_current_time = 0;
my $write_previous_time = 0;
my $write_delta_time = 0;

my $write_current_data = 0;
my $write_previous_data = 0;
my $write_delta_data = 0;

my $write_debit = 0;

my $flush_current_time = 0;
my $flush_previous_time = 0;
my $flush_delta_time = 0;

my $flush_current_data = 0;
my $flush_previous_data = 0;
my $flush_delta_data = 0;

my $flush_ind = 0;


print Fout "write_delta_time;write_delta_data;write_debit\n";
print Fout2 "flush_delta_time;flush_delta_data;flush_debit\n";

while(<Fin>){
	my $line = $_;
	chomp $line;
	#print "$line\n";
	#+     27.9609 MSG_WRITTEN
	#if($line =~ /^\+\s+(\d?\.\d+)\sMSG_WRITTEN/){
	if($line =~ /(\d+\.\d{4})\sMSG_WRITTEN/){	
		#print "$line\n";
		$write_current_time = $1;
		if($write_previous_time != 0){
			$write_delta_time = $write_current_time - $write_previous_time;
		}
		$write_previous_time = $write_current_time;
		#print "write current time = $write_current_time\n";
		#print "write delta time = $write_delta_time\n";
		if($write_delta_time < 0){
			print "ERROR delta time negatif\n";
			exit 0;
		}
	}
	if($line =~ /word_written:\s+(\d+),/){	
		#print "$line\n";
		$write_current_data = $1;
		if($write_previous_data != 0){
			$write_delta_data = $write_current_data - $write_previous_data;
		}
		if($write_delta_time != 0){
			$write_debit = 2 * $write_delta_data / $write_delta_time;
		}
		else{
			$write_debit = 0;
		}
		$write_previous_data = $write_current_data;
		#print "write current data = $write_current_data\n";
		#print "write delta data = $write_delta_data\n";
		
		#print "write debit = $write_debit\n";
		print Fout "$write_delta_time;$write_delta_data;$write_debit\n";
		
	}
#  traitement des flush
#		+     27.9796 FLUSHING_FILES 
	if($line =~ /(\d+\.\d{4})\sFLUSHING_FILES/){
		$flush_ind = 1;	
		#print "$line\n";
		$flush_current_time = $1;
		if($flush_previous_time != 0){
			$flush_delta_time = $flush_current_time - $flush_previous_time;
		}
		$flush_previous_time = $flush_current_time;
		#print "flush current time = $flush_current_time\n";
		print "flush delta time = $flush_delta_time\n";
		if($flush_delta_time < 0){
			print "ERROR delta time negatif\n";
			exit 0;
		}
	}
	if($line =~ /word_written:\s+(\d+),/){	
		print "$line\n";
		$flush_current_data = $1;
		if($flush_ind == 1){
			if($flush_previous_data != 0){
				$flush_delta_data = $flush_current_data - $flush_previous_data;
				
			}
			if($flush_delta_time != 0){
				$flush_debit = 2 * $flush_delta_data / $flush_delta_time;			
			}
			$flush_previous_data = $flush_current_data;
		}
		print "flush ind = $flush_ind\n";
		print "flush current data = $flush_current_data\n";
		print "flush delta data = $flush_delta_data\n";
		print "flush debit = $flush_debit\n";
		print Fout2 "$flush_delta_time;$flush_delta_data;$flush_debit\n";
		$flush_ind = 0;		
	}

}
close Fin;
close Fout;
close Fout2;

exit 0;