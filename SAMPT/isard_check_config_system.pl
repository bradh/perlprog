#!/usr/bin/perl

# check the traduction for each reference of the dico
# the reference file is Traduzione_IHM_OSIM_Italian_revu_SF.csv
# the dico to be check is osim_dico_multilangue_en_US.dbm
# 	in the install CD 
# 	in the restauration CD

my $reference_file = 			"verif_dico_italien\\osim_italian_dico\\list_paquet_rpm_ancien.txt";
my $osim_italien_dico_file = 	"verif_dico_italien\\osim_italian_dico\\list_paquet_machine_unique.txt";
my $result_file = 				"verif_dico_italien\\diff.csv";

open Fin_ref, "<$reference_file" or die;

open Fout_install, ">$result_file" or die;

print Fout_install "reference;french;english; italian ref.;osim italian dico;result;acceptance\n";

$ref_nber = 0;
while(<Fin_ref>){
	my $line = $_;
	my $result = "KO";
	chomp $line;
	#print $line;
	my($ref) = split('\s', $line);
#	if($ref =~ /^\&/){
		print "$ref\n";
		my $traduction = find_ref($ref);
		$result = "OK" if($traduction eq $ref);
		print "$ref;$traduction;$result\n";
		print Fout_install "$ref;$traduction;$result\n";
		$result = "KO";
		$ref_nber += 1;
#	}
}
close Fin_ref;
close Fout_install;

print "Nber of ref = $ref_nber\n";
exit 0;

sub find_ref {
	my $ref = shift;
	my $traduc = "null";
	open Fin_install, "<$osim_italien_dico_file" or die;
	while(<Fin_install>){
		my $line = $_;
		if($line =~ /$ref/){
						
					$traduc = $ref;
					last;
			
			
		}
		else {
		
		}
	}
		if ($traduc =~ /null/){
			print "$ref\n";
			print "$line\n";
			<>;
		}
	close Fin_install;
	return $traduc;
}
