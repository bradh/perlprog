#/usr/bin/perl
#     gnuplot.pl
#
#     bibliotheque de fonctions gnuplot.pl permettant le trace de courbes a l'aide de gnuplot
#
#############################################
#   initplot
#      genere un fichier gnuplot.in contenant des instructions
#      gnuplot. Gnuplot sera lance par la commande suivante:
#      gnuplot 'gnuplot.in'
#############################################
sub initplot {

$infile = "gnuplot.in";
open (IN,">$infile") || die("Erreur d'ecriture du fichier $infile, $!");

printf("set pointsize 2\n");
printf(IN "set data style linespoints \n");
printf(IN "set terminal png xdddddd x000000 xffff00 x9500d3 x0000ff \n");
printf(IN "set output \"toto.png\"\n");
printf(IN "set multiplot\n");
printf(IN "set yrange[-2:2]\n");

#printf(IN "show output\n");
}

############################################
#   closeplot
#      complete la fin du fichier gnuplot.in
############################################
sub closeplot {
 
printf(IN "set nomultiplot\n");
#printf(IN "pause -1 'tapez return !'\n"); 
close(IN);
#`/Applications/gnuplot/pgnuplot 'gnuplot.in'`   # MacOSX
print "execution de wgnuplot.exe\n";
system ("wgnuplot.exe gnuplot.in");                      # UNIX
}
#############################################
#   plot
#      genere un fichier gnuplot.dat contenant n colonnes de nombres representant
#      les vecteurs a tracer par gnuplot.
############################################
sub plot {

my $dat_file = "gnuplot.dat";
$ncourbes = -1;         # nbre de parametres passes a la cde plot
#
#   on compte le nbre de parametres qui sont passes a la cde plot
#
for ($i=0;$i<100;$i++) {
#
#   on suppose que le nbre de param. ne depasse pas 100
#   
   if (defined(@{$_[$i]})) {
#   if defined = si la valeur existe.
      $ncourbes++;
      }
   else {
      if ($ncourbes < 1) {
#   il faut au moins 1 vecteur abcisse et un vecteur ordonnee
         print "Erreur : nombre de parametres de la commande plot incorrect !\n";
         return -1;
         }
      else {
         last;
         }
      }
   } 
#
#   on verifie les dimensions des vecteurs, il faut que leur longueur soit egale
print "finalement ncourbes=$ncourbes\n";
foreach $k (0..$ncourbes) {
   if ($#{$_[0]} != $#{$_[$k]}) {
      print "Erreur : les vecteurs n'ont pas la meme dimension !\n";
      return -1;
      }
   }
#
#   on ouvre un fichier de donnees dans lequel on ecrire 3 colonnes:
#     abcisses   ordonnee1  ordonnee2 etc...
#
open(DAT,">$dat_file");
#
foreach $i (0..$#{$_[0]}) {
   foreach $k (0..$ncourbes) {
      printf(DAT "%f ",${$_[$k]}[$i]);
      }
   printf(DAT "\n");
   }
foreach $k (1..$ncourbes) {
   printf(IN "plot 'gnuplot.dat' palette using 1:%d\n",$k+1);
   }
close DAT;
}
############################################

1;

