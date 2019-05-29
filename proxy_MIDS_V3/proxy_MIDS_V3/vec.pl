#!/usr/bin/perl -w

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);

use Conversion;

foreach my $i (-5..2**16){
	print "nber = $i \n";
	foreach my $digitNumber (0..17){
		my $binary = Conversion::toBinaryString($i, $digitNumber);
		print $binary."\n";
	}
}

exit 0;