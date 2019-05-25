#!/usr/bin/perl -w

package GenScenario;

use Time;
use ConvLat;
use ConvLong;
use GenAirTrack;
use GenSurfaceTrack;

my $BASE_DIR = "/data/users/loc1int/scenario_generator";
my $SCENARIO_NAME = "GLOBAL";
my $BIBLIO_DIR = "Bibliotheque";
my $SCENARIO_DIR = "Scenario";

open Fout, ">$SCENARIO_NAME/$BIBLIO_DIR/scenario_1.ji" or die "impossible d'ouvrir new...\n";

# permet d'entretenir entre 2 heures données une piste toutes les 12s 
keepTrackAlive("00:00:00.000", "23:59:59.000", "N/00/00/00.000", "S/00/00/00.000", 0, 0, 0);
exit 0;


# keepTrackAlive(startTime, stopTime, lat, deltaLat,long, deltaLong, STN, TN, TQ)
#                00:00:00.000, 23:59:59.000, N/00/00/00.000, S/00/00/00.000, 0, 0, 0); 
sub keepTrackAlive {
		    my $startTime = conv2Chrono(shift);	    
		    my $stopTime = conv2Chrono(shift);
		    my $deltaTime = 12.000;
		    my $I = $startTime;
		    my $J;
		    while($I < $stopTime){
			my $time = conv2Time($I);
			print "$time\n";
			$I += $deltaTime;
		    }
		}

 
