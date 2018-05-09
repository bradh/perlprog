#!/usr/bin/perl -w

package AirTrack;
   
#use MessageUniversel;

use MessageUniversel;

#print "hello world\n";
my $newMessage = genAirTrack( "22:18:12.123", 17, 192, 132323, 54654, 12);
print "nouveau message :\n $newMessage\n";
exit 0;


sub genAirTrack {

(my $newTime, my $STN, my $TN, my $lat, my $long, my $TQ) = (@_);
#print "time = $newTime\n";

my $message = "00:00:00.000 00000030 0E030200 0000 0000 0000 0000 0000 0000 0000 090C 0000 0000 0000 0000 0002 0000 0000 0000 0000 0005 0000 0000 0000 0000";
(my $time, my $entete, my $wordI, my $wordE0, my $wordC1) = splitMessage($message);
#    print "ent = $entete\n";
$time = $newTime if($newTime);
$entete = setSTN($entete, $STN) if ($STN && $entete);
$wordI = setTN($wordI, $TN) if($TN);
$wordE0 = setLat($wordE0, $lat) if($lat);
$wordE0 = setLong($wordE0, $long) if($long);
$wordI = setTQ($wordI, $TQ) if($TQ);

$message = joinMessage($time, $entete, $wordI, $wordE0, $wordC1);

return $message;
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

sub setTQ {
    (my $wordI, my $TQ) = (@_);
    my $firstBit = 58;
    my $lastBit = 61;
    $wordI = insertChampJ($wordI, $firstBit, $lastBit, $TQ);
    return $wordI;
}
1;
