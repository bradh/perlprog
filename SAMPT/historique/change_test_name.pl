#!/usr/bin/perl

print "$ARGV[0]\n";
print "$ARGV[1]\n";

foreach my $file (`ls`) {
	chomp $file;
	if($file =~ /$ARGV[0]/){
		print "$file\n";	
		my $old_file = $file;
		$file =~ s/$ARGV[0]/$ARGV[1]/;
		print"$file\n";
		system("mv $old_file $file");
	}
}

open Fin, "<host_test_driver.conf" or die "Impossible ouvrir host_test_driver.conf !";
open Fout, "> toto" or die " Impssible ouvrir toto !";

while(<Fin>) {
	my $line = $_ ;
	chomp $line;
	$line  =~ s/$ARGV[0]/$ARGV[1]/;
	print Fout "$line\n";
}

close Fin;
close Fout;
system("mv toto host_test_driver.conf");

open Fin, "<l16_test_driver.conf" or die "Impossible ouvrir host_test_driver.conf !";
open Fout, "> toto" or die " Impssible ouvrir toto !";

while(<Fin>) {
        my $line = $_ ;
        chomp $line;
        $line  =~ s/$ARGV[0]/$ARGV[1]/;
        print Fout "$line\n";
}

close Fin;
close Fout;
system("mv toto l16_test_driver.conf");


exit 0;
