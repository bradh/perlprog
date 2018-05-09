#!/usr/bin/perl -w

print "$ARGV[0], $ARGV[1]\n";

my $tests_doors_file = $ARGV[0];
my $results_tests_PEU_file = $ARGV[1];

open Fin1, "<$tests_doors_file" or die "impossible ouvrir $tests_doors_file...";

open Fout, ">result.csv" or die "impossible ouvrir result.csv";
open Foutlog, ">result.log" or die "impossible ouvrir result.log";

while(<Fin1>){
	my $test_name = $_;
	my $test_PEU;
	my $result_PEU;
	my $find_result = 0;
	chomp $test_name ;
	print Foutlog "$test_name\n";
	my $test_ori = $test_name;
	$test_name =~ s/STD_(.*)/$1/;
	$test_name =~ s/T_(.*)/$1/;
	if($test_name =~ /^$/){
		print Fout "not a test;no PEU test;no result\n";
		next;
	}
	print Foutlog "recherche $test_name\n";
	open Fin2, "<$results_tests_PEU_file" or die "impossible ouvrir $results_tests_PEU_file...";
	while(<Fin2>){
		$test_PEU = $_;
		chomp $test_PEU;
		($test_PEU, $result_PEU)= split(";", $test_PEU);
		print Foutlog "$test_name sous doors = $test_PEU \n";
		if($test_PEU =~ /$test_name/){
			print Foutlog "test $test_ori trouvé : $test_PEU result $result_PEU\n ";
			print Fout "$test_ori;$test_PEU;$result_PEU\n";
			$find_result = 1;
			last;
		}
	}
	if(! $find_result){
		print Fout "$test_ori;test non trouvé;?\n";
		print Foutlog "$test_ori;test non trouvé;?\n";
	}
	close Fin2
}
close Fin1;
close Fout;
close Foutlog;

exit 0;
	
