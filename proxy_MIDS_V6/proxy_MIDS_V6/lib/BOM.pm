package BOM;

use lib qw(c:/perlprog/Scripts/lib);
use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use Conversion;
use BoctetProcessing;

my $r_mot;
my @FOM;

# Definition du BOM
my $BOMFOMTypeFirsBit = 9;
my $BOMFOMTypeLastBit = 14;
my $BOMLastFOMFirstBit = 15;
my $BOMLastFOMLastBit = 15;
my $BOMFOMLengthFisrtBit = 0;
my $BOMFOMLengthLastBit = 8;
my $BOMFOMByteOffset = 0;

# Definition du FOM
my $FOMLengthFirstBit = 2;
my $FOMLengthLastBit = 5;
my $FOMLengthByteOffset = 1;

sub new {
	# On passe une chaine de caractere hexa
	my $r_bom = shift;
	my $toto2 = $$r_bom;
	#print "bom : $toto2\n";
	# transforme la string en tableau de Boctet
	my $toto1 = length($$r_bom);
	#print "$toto1\n";
	my $I = 0;
	while($I < length($$r_bom)){
		my $J = int($I / 2);
		@$r_mot[$J]=substr($$r_bom, $I, 4);
		my $toto = @$r_mot[$J];
		#print " r_mot $ J $toto\n";
		$I = $I+4;
	}
	
    if( scalar @$r_mot < 1){ 
    	print "erreur\n";
    	#exit 0;
		return -1;
	}
	else{	
		(my $BOMHeader, @FOM) = (@$r_mot);
		bless $r_mot;
		return $r_mot;
	}
}

sub getFOMLength {
	return BoctetProcessing::getValue($r_mot, $FOMLengthFirstBit, $FOMLengthLastBit, $FOMLengthByteOffset);
}

sub getFOMType{	
	return BoctetProcessing::getValue($r_mot, $BOMFOMTypeFirsBit, $BOMFOMTypeLastBit-$BOMFOMTypeFirsBit+1, $BOMFOMByteOffset);
}

sub getBOMLength{
	return BoctetProcessing::getValue($r_mot, $BOMFOMLengthFirsBit, $BOMFOMLengthLastBit-$BOMFOMLengthFirsBit +1, $BOMFOMByteOffset);
}

sub getFOM{
	return \@FOM;
}
	

sub isLastFOM{
	return BoctetProcessing::getValue($r_mot, $BOMLastFOMFirsBit, $BOMLastFOMLastBit, $BOMFOMByteOffset);
}

1
