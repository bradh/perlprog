#!/usr/bin/perl -w

package GenAirTrack;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&genAirTrack);

#use MessageUniversel;

use MessageUniversel;
use ConvLat;
use ConvLong;
use Time;
use Getopt::Std;

getopts("hd:i:f:n:o:O:t:z:");

my $debug = 1;

my $BASE_DIR = "/data/users/loc1int/scenario_generator";

my $BIBLIO_DIR = "Bibliotheque";
my $SCENARIO_DIR = "Scenario";


# print $ENV{PWD};
if ($opt_h) { 
  print "usage GenAirTrack.pm [-i nom_test] [-f nom_fichier_sortie] [-n nombre_de_pistes] [-o hh:mm:ss.sss start time] [-O hh:mm:ss.sss stop time] [-t delta_t_en_ms] [-o T0 en secondes][-z firsSysTN]\n";
  print "GenAirTrack genere dun fichier au format .ji contenant nombre_de_piste espacee de delta_t en s\n";
  exit(0);
}


# lecture du repertoire de test
my $SCENARIO_NAME = "charge001";
if($opt_d) { $SCENARIO_NAME = $opt_d;}

# lecture du fichier d'entrée (patern)
my $INPUT_FILE = "AirTrack.ji";
if($opt_i) { $INPUT_FILE = $opt_i;}

$INPUT_FILE = "$SCENARIO_NAME/$BIBLIO_DIR/$INPUT_FILE";

# fichier de sortie sorti
my $OUTPUT_FILE = "L16RemoteObject_02.ji";
if($opt_f) {$OUTPUT_FILE = "$opt_f";}
$OUTPUT_FILE="$SCENARIO_NAME/$BIBLIO_DIR/$OUTPUT_FILE";

# nombre de pistes generée
my $trackNumber = 800;
if($opt_n) { $trackNumber = "$opt_n";}

# delta t entre pistes
my $deltaTime = 0.01; # en seconde
if($opt_t) { $deltaTime = $opt_t;}

# heure de démarrage en seconde
my $startTime = "00:01:00.000";
if($opt_o) {
  $startTime = $opt_o;
  print "$startTime\n";
}
# heure de fin en seconde
my $stopTime = "00:02:00.000";
if($opt_O) {
  $stopTime = $opt_O;
}
# premier TN
my  $TN = 512;
if($opt_z) { 
  $TN = $opt_z;
}

my $message; 

my $STN = 17;

my $lat = "N/45/00/00.000";
my $long = "W/001/00/00.000";
my $TQ = 12;

my $deltaLat = "N/00/00/1.000";
my $deltaLong = "W/000/00/1.000";



open Fout, ">$OUTPUT_FILE" or die "impossible d'ouvrir $OUTPUT_FILE...\n";

open Fin, "<$INPUT_FILE" or die "impossible de lire $INPUT_FILE...\n";
while(<Fin>){
    chomp;
    $message = $_;
  }
close Fin;

setAirTrackProperties();
genAirTrackGroup();
  
close Fout;

exit 0;

# Dans un premier temps on fixe les invariants à savoir :
# le STN, le premier TN, la Lat, la Long, la TQ

sub setAirTrackProperties {

my $lat_00051 = convLat_00051((split("/", $lat)));
my $long_00051 = convLong_00051((split("/", $lat)));

(my $timeOld, my $entete, my $wordI, my $wordE0, my $wordC1) = splitMessage($message);
#    print "ent = $entete\n";
$entete = setSTN($entete, $STN) if ($STN && $entete);
$wordI = setTN($wordI, $TN) if($TN);
$wordE0 = setLat($wordE0, $lat_00051);
$wordE0 = setLong($wordE0, $long_00051);
$wordI = setTQ($wordI, $TQ) if($TQ);

$message = joinMessage($timeOld, $entete, $wordI, $wordE0, $wordC1);

return 0;
} 


# genere un groupe de pistes à partir d'une piste unitaire en spécifiant le nombre de pistes, le TN STN
# le delta en lat, long et en temps 

sub genAirTrackGroup {
my $currentTN = $TN;
my $startChrono = conv2Chrono($startTime);
my $currentLat = $lat;
my $currentLong = $long;
  foreach my $I (1..$trackNumber) {
    print "TN = $I\n";
    
    genAirTrack($startChrono, $currentTN, $currentLat, $currentLong);
    $startChrono += $deltaTime;
    $currentTN++;
    $currentLat = join("/", latSum($currentLat, $deltaLat));
    $currentLong = join("/", longSum($currentLong, $deltaLong));
    #print "$currentLat\n";
    #print "$currentLong\n";
  }
return 0;
}    
    
# genere une piste entre 2 temps start et stop
  
sub genAirTrack {

  my $startChrono = shift;
  my $currentTN = shift;
  my $currentLat = shift;
  my $currentLong = shift;

  my $lat_00051 = convLat_00051((split("/", $currentLat)));
  my $long_00051 = convLong_00051((split("/", $currentLong)));
  #print "$long_00051\n";

	    
  my $stopChrono = conv2Chrono($stopTime);
  my $deltaTime = 12.000;
  my $I = $startChrono;
  my $J;
  while($I < $stopChrono){
    my $time = conv2Time($I);
    #print "$time\n";
    $I += $deltaTime;
    (my $timeOld, my $entete, my $wordI, my $wordE0, my $wordC1) = splitMessage($message);
#    print "ent = $entete\n";
    $wordI = setTN($wordI, $currentTN) if($currentTN);
    $wordE0 = setLat($wordE0, $lat_00051);
    $wordE0 = setLong($wordE0, $long_00051);
    my $messageOut = joinMessage($time, $entete, $wordI, $wordE0, $wordC1);
    print Fout "$messageOut\n";
  }
  return 0;
} 

sub setSTN {
    #print "setSTN\n";
    (my $entete, my $STN) = (@_);
    my $firstBit = 32;
    my $lastBit = 46;
    $entete = insertChampU($entete, $firstBit, $lastBit, $STN);
    return $entete;
}

sub setTN {
    #print "set TN\n";
    (my $wordI, my $TN) = (@_);
    my $firstBit = 19;
    my $lastBit = 37;
    $wordI = insertChampJ($wordI, $firstBit, $lastBit, $TN);
    return $wordI;
}

sub setLat {
    #print "set lat\n";
    (my $wordE0, my $lat) = (@_);
    my $firstBit = 4;
    my $lastBit = 24;
    $wordE0 = insertChampJ($wordE0, $firstBit, $lastBit, $lat);
    return $wordE0;
}

sub setLong {
    #print "set long\n";
    (my $wordE0, my $long) = (@_);
    my $firstBit = 27;
    my $lastBit = 48;
    #print "$long\n";
    $wordE0 = insertChampJ($wordE0, $firstBit, $lastBit, $long);
    print "$wordE0\n";
    return $wordE0;
}

sub setTQ {
    #print "set TQ\n";
    (my $wordI, my $TQ) = (@_);
    my $firstBit = 58;
    my $lastBit = 61;
    $wordI = insertChampJ($wordI, $firstBit, $lastBit, $TQ);
    return $wordI;
}
1;
