#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 02/05/2007
# Description :

use Getopt::Std;

my @MOT;
my $Delta_Error = "00:00:02.000";

getopts("hsf:");



if ($opt_h) { 
  print "remove_xdh_technique.pl -f nom_fichier -s: tri les messages Msd_ID  > 100 ou = 92 -s pour sauvegarder l'original ";
  exit(0);
}
if( ! $opt_h && $opt_f) {
  $fichierInput = "$opt_f";
  $fichierOutput = "$opt_f.tmp";

  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	
  print "remove tdh from $fichierInput , please wait...\n";
   while(<Fin>){
    chomp;
	
    my $LIGNE = $_;
    (@MOT) = (split " ",$LIGNE);
    next if (! ($MOT[2] =~ /^01/ || $MOT[2] =~ /^03/ ));
    #print "$MOT[2]\n";
    my $Length_xdh = scalar @MOT;
    my $Msg_ID = hex (substr($MOT[2],-4,4));
    #print "t $Msg_ID\n";
    # Ne traite pas les messages techniques
    #if($Msg_ID > 100 || $Msg_ID == 70|| $Msg_ID == 72|| $Msg_ID == 73 || $Msg_ID == 93 || $Msg_ID == 92 ){
	if(($Msg_ID > 100 && $Msg_ID <400 ) || $Msg_ID == 69  || $Msg_ID == 70|| $Msg_ID == 72|| $Msg_ID == 73 || $Msg_ID == 93 || $Msg_ID == 92 ){
      print "$Msg_ID\n";
      print Fout "$LIGNE\n";
      #print "$Msg_ID\n";
    }
  }
  close Fin;
  close Fout;
  system("mv $fichierInput $fichierInput.save")if($opt_s);
  system("mv $fichierOutput $fichierInput");
  exit 0;
}
