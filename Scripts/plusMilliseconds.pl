#!/usr/bin/perl -w

use Getopt::Std;

getopts("hf:r:");

# print $ENV{PWD};
if ($opt_h) { print "plusMilliseconds.pl -f nom_dufichieri -r nom_repertoire\n";
print "plusMilliseconds permet de rajouter .000 au heure des fichier test driver sabotés par Aladdin\n";}

if($opt_f) { $fichierIn = "$opt_f";}

$repOut=".";
if($opt_r) { $repOut= "./$opt_r";}
if($opt_f && ! $opt_h){
  open Fin, "<$fichierIn" or die "impossible d'ouvrir le fichier d'entree";
  open Ftemp, ">$repOut/$fichierIn.tmp" or die "impossible de creer le fichier de sortie $repOut/$fichierIn.tmp";
  while(<Fin>){
    $_ =~ s/^(\d\d:\d\d:\d\d)\s/$1\.000 /;
    print Ftemp $_;
  }
  close Fin;
  close Ftemp;
  system ( "rm $fichierIn" ) ;
  system ( " mv $fichierIn.tmp $fichierIn");
}
exit(0);
