#!/usr/bin/perl -w

package MessageUniversel;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&splitMessage &joinMessage &reverseMot &extractChampU &insertChampU &extractChampJ &insertChampJ &toHexaString);

if(0){
    my $message = "00:00:00.000 00000030 0E030200 0000 0000 0000 0000 0000 0000 0000 090C 0000 0000 0000 0000 0002 0000 0000 0000 0000 0005 0000 0000 0000 0000";
    print "ancien message : \n $message\n";
    (my $time, my $entete, my $wordI, my $wordE0, my $wordC1) = splitMessage($message);
    print "ancien mot I : \n $wordI\n";
    $wordI = insertChampJ ($wordI, 2, 6, 31);
    print "nouveau mot I : \n $wordI\n";
    print "ancien entete : \n $entete\n";
    $entete = insertChampU ($entete, 32, 46, 17); 
    print "nouvelle entete : \n $entete\n";
    $message = joinMessage($time, $entete, $wordI, $wordE0, $wordC1);
    print "nouveau message : \n $message\n";

    exit 0;
}

sub splitMessage {
    my $mess = shift;
    #print "$mess\n";
    my @word16 = split(" ", $mess);
    (scalar @word16 == 25) or die "message <> 24 \n";
    #print "$word16[1]\n";
    my $entete = "";
    my $wordI = "";
    my $wordE0 = "";
    my $wordC1 = "";
    my $time = $word16[0];
    for my $i (1..9){
	$entete = $entete.$word16[$i];
    }
    for my $i (10..14) {
	$wordI = $word16[$i].$wordI;
    }
    for my $i (15..19) {
	$wordE0 = $word16[$i].$wordE0;
    }
    for my $i (20..24) {
	$wordC1 = $word16[$i].$wordC1;
    }
#    print "ent = $entete\n";
    return ($time, $entete, $wordI, $wordE0, $wordC1);
}

sub joinMessage {
    my $time = shift;
    my $entete = shift;
    my $wordI = shift;
    my $wordE0 = shift;
    my $wordC1 = shift;
    $entete =~ s/(.{4})/$1 /g;
    $entete =~ s/^(\d{4})\s(.{9})\s/$1$2/;
    
    $wordI = reverseWord($wordI);
    $wordE0 = reverseWord($wordE0);
    $wordC1 = reverseWord($wordC1);
    
    my $message = $time." ".$entete.$wordI.$wordE0.$wordC1;
    return $message;
}

sub reverseWord {
    my $word = shift;
    my $revWord = "";
    (length($word) == 20) or die " le mot n'a pas 20 digits \n"; 
    foreach my $i (0..4) {
	$revWord = substr($word, $i*4, 4)." ".$revWord;
    }
    return $revWord;
}


sub extractChampJ {
    my $mot = shift;
#    print "mot = $mot\n";
    my $firstBit = shift;
    my $lastBit = shift;
    my $firstDigit = int($firstBit/4);
    #print "first digit = $firstDigit\n";
    my $lastDigit = int($lastBit/4);
    #print "last digit = $lastDigit\n";
    my $motHexa = substr($mot, length($mot) - $lastDigit - 1,  $lastDigit - $firstDigit + 1);
#    print "mot hexa =  $motHexa\n";
    my $valeur = hex $motHexa;
    $valeur = $valeur >> ($firstBit%4);
#    print "valeur = $valeur\n";
    my $masque = 2**($lastBit - $firstBit +1) - 1;
#    print "masque = $masque\n";
    return ($valeur & $masque);
}

sub insertChampJ {
    # v‰rifier la plage de valeur en fonction du
    my $mot = shift;
    #print "\nmot = $mot\n";
    my $firstBit = shift;
    my $lastBit = shift;
    my $valeur = shift;
    my $I = toHexaString($valeur);
    #print "firstBit = $firstBit, $lastBit, $I toto\n";
    ($valeur < 2**($lastBit-$firstBit+1)) or die "valeur excessive !\n";
   
    my $firstDigit = int($firstBit/4);
    #print "first digit = $firstDigit\n";
    my $lastDigit = int($lastBit/4);
    #print "last digit = $lastDigit\n";

    my $nbreBit = $lastBit - $firstBit + 1;
    my $nbreDigit = $lastDigit - $firstDigit + 1;
    my $firstChar = length($mot) - $lastDigit - 1;

    my $motHexa = substr($mot, $firstChar, $nbreDigit);
    $I =  $motHexa;
    #print "mot hexa =  $I\n";
    my $decalage = 2**($firstBit%4);
    my $masque = (2**$nbreBit-1)* $decalage;

    $I =  ~$masque & hex($motHexa);
    my $J = ($valeur*$decalage)& $masque;
    #print " $I, $J\n";
    $I= toHexaString($I);
    $J = toHexaString($J);
    #print " $I, $J\n";

    $masque = ~$masque & hex($motHexa)|(($valeur*$decalage)& $masque);
    $I = toHexaString($masque);
    #print "masque = $I\n";
    my $substit = "0"x$nbreDigit.toHexaString($masque);
    $substit = substr ($substit, -$nbreDigit, $nbreDigit);
   #print "chaine € remplacer = $substit\n"; 
   substr($mot, $firstChar, $nbreDigit) = $substit; 
   #print "nouveau mot = $mot\n";
   return $mot;
    
}

sub extractChampU {
    my $mot = shift;
#    print "mot = $mot\n";
    my $firstBit = shift;
    my $lastBit = shift;
    my $firstDigit = int($firstBit/4);
    #print "first digit = $firstDigit\n";
    my $lastDigit = int($lastBit/4);
    #print "last digit = $lastDigit\n";
    my $motHexa = substr($mot, length($mot) - $lastDigit - 1,  $lastDigit - $firstDigit + 1);
#    print "mot hexa =  $motHexa\n";
    my $valeur = hex $motHexa;
    $valeur = $valeur >> ($firstBit%4);
#    print "valeur = $valeur\n";
    my $masque = 2**($lastBit - $firstBit +1) - 1;
#    print "masque = $masque\n";
    return ($valeur & $masque);
}
sub insertChampU {
    # v‰rifier la plage de valeur en fonction du
    my $mot = shift;
    #print "mot = $mot\n";
    my $firstBit = shift;
    my $lastBit = shift;
    my $valeur = shift;
    ($valeur < 2**($lastBit-$firstBit+1)) or die "valeur excessive ...\n";
    my $firstDigit = int($firstBit/4);
    #print "first digit = $firstDigit\n";
    my $lastDigit = int($lastBit/4);
    #print "last digit = $lastDigit\n";
# Extraction des digits contenant le champ
    my $motHexa = substr($mot, 16+$firstDigit,  $lastDigit - $firstDigit + 1);
    #print "mot hexa =  $motHexa\n";
    my $nbreDigit = length($motHexa);
# Calcul des nouveaux digits
    my $masque = (2**($lastBit-$firstBit+1)-1)*2**($firstBit%4);
    $masque = (~$masque & hex($motHexa))|(($valeur*2**($firstBit%4))& $masque);
    #print "masque = $masque\n";
    my $substit = "0"x$nbreDigit.toHexaString($masque);
    $substit = substr ($substit, -$nbreDigit, $nbreDigit);
    #print "chaine € remplacer = $substit\n"; 
# Substitution des anciens digits par les nouveaux
    substr($mot, 16+$firstDigit,  $lastDigit - $firstDigit + 1) = $substit; 
    #print "nouveau mot = $mot\n";
    return $mot;    
}

sub toHexaString {
    my@tab = (0..9,A..F);
    my $string = "";
    my $nbre = shift;
    if ($nbre == 0) {
	$string = "0";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%16;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/16);
	}
    }
    return $string;
}
1;
