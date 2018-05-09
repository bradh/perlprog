#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hf:");

my $MSG_ID = 1;
my $PACKING_LIMIT = 0;
my $PRIORITY = 10;
my $PG = 7;
my $STN = 21;
my $FIM55="00:00:01.000 00000022 06000037 0001 0000 000C 0001 0002 0007 0009 0101 0102 0103 0104 010C 0110 0114 011B";
my $FIM56="00:00:02.000 00000046 06000038 0001 0000 001C 0000 0100 0010 0012 0015 0018 0019 001A 001D 001F 0038 0039 003A 003B 003C 003D 003E 003F 0048 0049 004A 0052 0060 0065 0066 0067 006A 006D 00F4 00F5";
my $FIM57="00:00:03.000 00000016 06000039 0101 0000 0006 0000 000F 0016 0070 0071 0076";

if ($opt_h) { 
	print "fom2fim.pl [-f] nom_fichier [-h] :  transforme un fichier .fom en fichier .fim \n";
}

if( ! $opt_h && $opt_f ) {
  	my $INPUT_FILE = $opt_f;
        my ($FILE_NAME, $FILE_EXT) = split /\./, $INPUT_FILE;
  	my $OUTPUT_FILE = "$FILE_NAME.fim";
	#print "$OUTPUT_FILE\n";
  	open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
  	open Fout, ">$OUTPUT_FILE" or die "Impossible d'ouvrir $OUTPUT_FILE\n";
	
	print Fout "$FIM55\n";
	print Fout "$FIM56\n";
	print Fout "$FIM57\n";

	while(<Fin>){
 		# Recherche 	04000001 pour les FOM01
		#		06000001 pour les FIM01
		my $LIGNE = $_;
#		chomp $LIGNE;
  		my @LINE = split;
		my $TAB_SCALAR = scalar @LINE;	
		#print "$TAB_SCALAR $LIGNE\n";
 		if($TAB_SCALAR > 22 && $TAB_SCALAR < 27 && $LINE[2] =~ /04000001/){
			my $JI = "";
			foreach my $I (9 .. $TAB_SCALAR) { 
				$JI= "$JI $LINE[$I-1]";
			}
			my $MSG_ID_HEXA = toHexaString($MSG_ID);
			$MSG_ID += 1;
			my $STN = $LINE[4];
			$FIM_ENTETE = "0000 A328 0000 0000 3FFF 0000 0007 $STN";
			#print "fom $LIGNE";
			print Fout "$LINE[0] 00000032 06000001 $FIM_ENTETE $JI\n";
		}
	}
	close Fin;
	close Fout;

}
exit 0;

sub toHexaString {
    my@tab = (0..9,A..F);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "00000000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%16;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/16);
	}
    }
    $string = substr("0000000000"."$string", -4, 4);
    #print "hexa : $string \n";
    return $string;
}
