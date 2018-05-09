#!/usr/bin/perl -w

package TimeChrono;

use Exporter;
use strict;

my @ISA = qw(Exporter);
my @EXPORT = qw(&chrono2Time &time2Chrono);

# Text

my @essai = chrono2Time (123325.12);
(my $a, my $b, my $c) = (@essai);
print "$a:$b:$c\n";
my $chrono = time2Chrono(@essai);
print "$chrono\n";
exit 0;

# convertit un chrono en nombre d'heure de minute et de seconde
sub chrono2Time {
    my $chrono = shift;
    my $heure = int ($chrono/3600) ;
    my $minute = int (($chrono - ($heure*3600))/60);
    my $seconde = $chrono - ($heure*3600) - ($minute *60);
    print " sec = $seconde\n";
    my $milliSeconde;
    $heure = sprintf("%02d", $heure);
    print "heure = $heure\n";
    $minute = sprintf("%02d", $minute);
    print "minute = $minute\n";
    $seconde = sprintf ("%02.3f", $seconde);
    print "seconde = $seconde\n";
    
    my @heure = ($heure,$minute,$seconde);
    return (@heure);
}

# convertit une heure au format hh:mm:ss.sss en chrono (secondes)
sub time2Chrono {
    (my $heure, my $minute, my $seconde) = (@_);
    my $chrono = $heure*3600 + $minute*60 + $seconde;
    return $chrono;
}
1;
