#!/usr/bin/perl
require 'gnuplot.pl';

my @dx, @dy, @dz, @di;

for ($i=0;$i<100;$i++) {
#   $dx[$i] = cos($i)*cos($i); 
   $dx[$i] = $i; 
   $dy[$i] = sin($i/5);
   $dz[$i] = cos($i/5);
   $di[$i] = sin($i/5)*sin($i/5);
   }
   
initplot();
plot(\@dx,\@dy,\@dz,\@di);
closeplot();

