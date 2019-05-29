#!/usr/bin/perl -w

my $file_name = $ARGV[0];

print $file_name . "\n";

open Fin, "<$file_name" or die "not possible to open\n";
open Fout, ">$file_name.ascii" or die "not possible open\n";

my $char_number = 0;

while(<Fin>){
	my $line = $_;	
	chomp $line ;
	print "$line\n";
	foreach my $i (0..length($line)-1){	
		my $ascii = ord(substr($line, $i, 1));
		print "$ascii ";
		$ascii = sprintf("%02X", $ascii );
		print "$ascii\n";
		print Fout "$ascii";
		$char_number += 1;
	}
	print "0D0A";
	print Fout "0D0A";
	$char_number += 2;
}
print "\nnber of char = $char_number\n";
close Fin;
close Fout;

exit 0;