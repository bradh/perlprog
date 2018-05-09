package position_conversion ;

use Math::Trig;
use lib qw(/media/stephane/TRANSCEND/Tools/perlprog/lib);

my $Xt, $Yt, $Zt;
my ($Phys,$Lambdas, $Hs );
my ($Phyt,$Phypt, $Lambdat, $Ht);

my $a = 3487.607721; # data miles

my $e2 = 0.0066943737999013;

my $k2 = $a*$e2/sqrt(1-$e2);

print "a = $a \n";
print "e2 = $e2\n";
print "k2 = $k2\n";


my ($E, $C, $L, $As, $K, $Kp);

# initialisation 
$Phys = 45;
$Lambdas = 5;
$Hs = 0;

convert_Cartesian2WGS84(100, 100, 0);

sub convert_Cartesian2WGS84 {
	$Xt = shift;
	$Yt = shift;
	$Ht = shift;

	$As = $a /(sqrt(1-$e2*sin($Phys)**2));
	
	$E = ($As*(1-$e2) + $Hs + $Zt)*sin($Phys) + $Yt*cos($Phys);
	
	$C = ($As + $Hs + $Zt)*cos($Phys) + $Yt*sin($Phys);
	
	$L = Math::Trig::atan($Xt/$C);
	
	my $R = $C/ cos($L);
	print "\n";
	print "As = $As\n";
	print "E == $E\n";
	print "C == $C\n";
	print "L == $L\n";
	
	$Kp = 0;
	
	$K = 1;
	
	while ((abs($K)-abs($Kp)) > 0.00001){
		print "$K : $Kp\n";
		$Kp = $K;
		$K = ($k2 * ($E + $Kp))/sqrt(  ($R**2 /(1-$e2) ) + ($E + $Kp)**2 );
		
	}
	
	
	$Phypt = Math::Trig::atan ( ( ($E + $K) * cos($L) ) / $C );
	
	$Phyt = $Phypt;
	
	$Lambdat = $Lambdas + $L;
	
	$Ht = ( $R / cos ($Phyt) ) - ( $a / sqrt ( 1 - ( $e2 * (sin($Phyt)**2 ) ) ) );
	
	print "Phyt = $Phyt\n";
	print "Lambdat = $Lambdat\n";
	print "Ht = $Ht\n";
	
	return 0;
}

1