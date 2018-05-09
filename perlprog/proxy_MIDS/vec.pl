#!/usr/bin/perl -w

use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);

use Conversion;

foreach my $i (-5..2**16){
	#print "nber = $i \n";
	foreach my $digitNumber (0..17){
		my $binary = Conversion::toBinaryString($i, $digitNumber);
		#print $binary."\n";
	}
}


$byte = pack('n', 1);
$byte = $byte . pack('n', 2);
$byte = $byte . pack('n', 3);
$byte = $byte . pack('n', 4);
$byte = $byte . pack('n', 5);
$byte = $byte . pack('n', 6);
$byte = $byte . pack('n', 7);
$byte = $byte . pack('n', 8);

my $hexa_msg = unpack('H*', $byte);
print "$hexa_msg\n";
my $network_msg = pack('H*', $hexa_msg);
$hexa_msg = unpack('H*', $network_msg);
print "$hexa_msg\n";

exit 0;