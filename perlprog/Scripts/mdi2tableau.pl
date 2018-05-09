#!/usr/bin/perl -w

use Getopt::Std;

getopts("hf:");

if ($opt_h) { 
	print "$0 traite les fichiers texte extrait des fichiers.mdi \n"; 
}
if( ! $opt_h && $opt_f){
       open Fin, "<$opt_f" or die "Impossible ouvrir $opt_f ! \n";
       open Fout, ">result.txt" or die "Impossible ouvrir result.txt\n";
	while(<Fin>){
		#print $_;
		$_ =~ s/(,\d\d)\s+(\d\d\/\d\d)/$1\n$2/g;
 		print Fout $_;
	}	
	close Fout;
	close Fin;
	open Fin, "<result.txt" or die "Impossible ouvrir result.txt\n!";
	open Fout, ">result2.txt" or die "Impossible ouvrir result2.txt\n!";
	while(<Fin>){
		$_ =~ s/^(\d\d\/\d\d\/\d{4})\s+/$1\t/;
		$_ =~ s/\s+(\d+,\d\d)$/\t$1/;
		print Fout $_;
	}
	close Fin;
	close Fout;
	system("mv result2.txt $opt_f");
	system("rm -f result.txt");
	exit 0;
}
exit -1;
