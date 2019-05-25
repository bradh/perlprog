#!/usr/bin/perl -w
# analyse une liste de tests vs une autre
# supprime le préfixe T_ ou STD_ avant comparaison

print "$ARGV[0], $ARGV[1]\n";
my $tests_doors_file = $ARGV[0];
my $tests_conf_file = $ARGV[1];

open Fin1, "<$tests_doors_file" or die "impossible ouvrir $tests_conf_file...";

open Fout, ">result_comparaison.csv" or die "impossible ouvrir result_comparaison.csv";
open Fout2, ">result.log" or die "impossible ouvrir result.log";

while(<Fin1>){
	my $test = $_;
	open Fin2, "<$tests_conf_file" or die "impossible ouvrir $tests_doors_file...";
	my $test_result = 0;
	chomp $test ;
	print Fout2 "$test\n";
	my $test_ori = $test;
	$test =~ s/STD_(.*)/$1/;
	$test =~ s/T_(.*)/$1/;
	print Fout2 "recherche $test\n";
	while(<Fin2>){
		my $line = $_;
		chomp $line;
		print "$line\n";
		print Fout2 "$test sous doors = $line \n";
		if($line =~ /$test/){
			print Fout2"test $test_ori trouvé : $line\n ";
			print Fout "$test_ori;$line;OK\n";
			$test_result = 1;
			last;
		}
	}
	if(! $test_result){
		print Fout2 "test $test_ori non trouvé\n";
		print Fout "$test_ori;;NOT_OK\n";
	}
	close Fin2
}
close Fin1;
close Fout;
close Fout2;

exit 0;
	
