package BIM;

use lib qw(c:/perlprog/Scripts/lib);
use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use Conversion;
use BoctetProcessing;

my $r_mot;
my @FIM;

# Definition du BIM
my $BIMFIMTypeFirsBit = 9;
my $BIMFIMTypeLastBit = 14;
my $BIMLastFIMFirstBit = 15;
my $BIMLastFIMLastBit = 15;
my $BIMFIMLengthFisrtBit = 0;
my $BIMFIMLengthLastBit = 8;
my $BIMFIMByteOffset = 0;

# Definition du FIM
my $FIMHeader16bWordLength = 8;
my $FIMLengthLastBit = 5;
my $FIMLengthByteOffset = 1;

# test sub routine 
for my $i (1..3){
	my $hexa_BIM_eentete = getBIM01Header($i);
	print "$i , $hexa_BIM_eentete\n";
}
#exit 0;


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
		(my $BIMHeader, @FIM) = (@$r_mot);
		bless $r_mot;
		return $r_mot;
	}
}

sub getFIMLength {
	return BoctetProcessing::getValue($r_mot, $FIMLengthFirstBit, $FIMLengthLastBit, $FIMLengthByteOffset);
}

sub getFIMType{	
	return BoctetProcessing::getValue($r_mot, $BIMFIMTypeFirsBit, $BIMFIMTypeLastBit-$BIMFIMTypeFirsBit+1, $BIMFIMByteOffset);
}

sub getBIMLength{
	return BoctetProcessing::getValue($r_mot, $BIMFIMLengthFirsBit, $BIMFIMLengthLastBit-$BIMFIMLengthFirsBit +1, $BIMFIMByteOffset);
}

sub getFIM{
	return \@FIM;
}
	

sub isLastFIM{
	return BoctetProcessing::getValue($r_mot, $BIMLastFIMFirsBit, $BIMLastFIMLastBit, $BIMFIMByteOffset);
}

sub getBIM01Header{
	my $J_word_nber = shift;
	my $length_in_16w = $FIMHeader16bWordLength + 5*$J_word_nber;
	print "length in 16w : $length_in_16w\n";
	my $binary_length = sprintf( "%09b",$FIMHeader16bWordLength + 5*$J_word_nber);
	print "binary length : $binary_length\n";
	
	my $bim01_header = "1000001" . $binary_length;
	print "$bim01_header\n";
	$bim01_header = pack("B16", $bim01_header);
	print "$bim01_header\n";
	$bim01_header = unpack("H4", $bim01_header);
	print "$bim01_header\n";
	
	return $bim01_header;
}

1
