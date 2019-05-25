#!/usr/atelier/gnu/perl_5.00404/solaris/bin/perl
use Time::Local;


($second, $minute,$hour,$day, $month,$year)=(localtime)[0,1,2,3,4,5];
$month = $month+1;
$year=$year+1900;

print "$hour:$minute:$second le $day/$month/$year\n";
$second=(($hour*60)+$minute)*60+$second+30;
print "$second\n";
# create loc1_main.synchro file
open Fout, ">loc1_main.synchro" or die "impossible de creer loc1_main.synchro\n";
print Fout "Synchro_Year=$year\n";
print Fout "Synchro_Month=$month\n";
print Fout "Synchro_Day=$day\n";
print Fout "Synchro_Seconds=$second\n";
close Fout;
exit 0;
