#!/usr/bin/perl -w

package GenSurfaceTrack;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&genSurfaceTrack);
   
#use MessageUniversel;

use MessageUniversel;
use ConvLat;
use ConvLong;
use Time;

$BASE_DIR = "/data/users/loc1int/scenario_generator";
$SCENARIO_NAME = "GLOBAL";
$BIBLIO_DIR = "Bibliotheque";
$SCENARIO_DIR = "Scenario";

my $debug = 0;

if($debug){    
    
    genSurfaceTrack( "00:00:00.000","22:18:12.123", 17, 192, "N/45/00/00.000", "W001/00/00.000", 12);

    exit 0;
}

sub genSurfaceTrack {

(my $startTime, my $stopTime, my $STN, my $TN, my $lat, my $long, my $TQ) = (@_);
my $message;
open Fin, "<$SCENARIO_NAME/$BIBLIO_DIR/piste_surface.ji" or die "impossible de lire Bibliotheque/piste_air.ji...\n";
while(<Fin>){
    chomp;
    $message = $_;
}
close Fin;
open Fout, ">$SCENARIO_NAME/$SCENARIO_DIR/new_surface_track.ji" or die "impossible d'ouvrir scenarii/new_surface_track.ji...\n";
my $lat_00051 = convLat_00051((split("/", $lat)));
my $long_00051 = convLong_00051((split("/", $long)));

$startTime = conv2Chrono($startTime);	    
$stopTime = conv2Chrono($stopTime);
my $deltaTime = 12.100;
my $I = $startTime;
my $J;
while($I < $stopTime){
    my $time = conv2Time($I);
    print "$time\n";
    $I += $deltaTime;
    (my $timeOld, my $entete, my $wordI, my $wordE0, my $wordC1) = splitMessage($message);
#    print "ent = $entete\n";
    $entete = setSTN($entete, $STN) if ($STN && $entete);
    $wordI = setTN($wordI, $TN) if($TN);
    $wordE0 = setLat($wordE0, $lat_00051);
    $wordE0 = setLong($wordE0, $long_00051);
    $wordI = setTQ($wordI, $TQ) if($TQ);

			my $messageOut = joinMessage($time, $entete, $wordI, $wordE0, $wordC1);
			print Fout "$messageOut\n";
		    }
close Fout;
return 0;
} 

sub setSTN {
    (my $entete, my $STN) = (@_);
    my $firstBit = 32;
    my $lastBit = 46;
    $entete = insertChampU($entete, $firstBit, $lastBit, $STN);
    return $entete;
}

sub setTN {
    (my $wordI, my $TN) = (@_);
    my $firstBit = 19;
    my $lastBit = 37;
    $wordI = insertChampJ($wordI, $firstBit, $lastBit, $TN);
    return $wordI;
}

sub setLat {
    (my $wordE0, my $lat) = (@_);
    my $firstBit = 4;
    my $lastBit = 24;
    $wordE0 = insertChampJ($wordE0, $firstBit, $lastBit, $lat);
    return $wordE0;
}

sub setLong {
    (my $wordE0, my $long) = (@_);
    my $firstBit = 27;
    my $lastBit = 48;
    $wordE0 = insertChampJ($wordE0, $firstBit, $lastBit, $long);
    return $wordE0;
}
sub getLong {
    my $wordE0 = $_;
    my $firstBit = 27;
    my $lastBit = 48;
    my $long = extractChampJ($wordE0, $firstBit, $lastBit);
    return $long;
}

sub setTQ {
    (my $wordI, my $TQ) = (@_);
    my $firstBit = 58;
    my $lastBit = 61;
    $wordI = insertChampJ($wordI, $firstBit, $lastBit, $TQ);
    return $wordI;
}
1;
