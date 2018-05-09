#!/usr/bin/perl
# 
# Traduction du fichier loc1_main.log vers un fichier .mo lisible par Aladdin
# Les traces API_MGR doivent etre positionnées a NORMAL_DEBUG
#

use Getopt::Std;

my $REP_VERSION = "/data/users/loc1int/DLIP/test/test_tu";
my $REP_SCRIPT = "/data/users/loc1int/DLIP/test/utils/scripts";
my $REP_RESULTS = "$REP_VERSION/results";
my $REP_CIBLE;
my $CAT = 1;
my $VERSION;
my $NOM_TEST;
my $TIME = 600;

getopts("hc:v:t:");

# print $ENV{PWDb;
if ($opt_h) { 
  print "toAladdin.pl [-h] [-c cat] [ -v version] [-t test]\n";
  print "toAladdin.pl permet de transcrire les tracves du log en fichier .mi \n";
  print "il faut possitionner les traces API manager\n";
  exit(0);
}

if ($opt_h && $opt_c && ! $opt_v) {
  $CAT = $opt_c;
  print "categorie = $CAT \n";
  my $LISTE = `ls $REP_VERSION/category$CAT`;
  print "Liste des versions DLIP en test catégorie $CAT :\n";
  print "$LISTE";
  print " \n";
}
if ($opt_h && $opt_c && $opt_v) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  my $LISTE = `ls $REP_VERSION/category$CAT/$VERSION`;
  print "Liste des tests categorie $CAT pour la version DLIP $VERSION :\n";
  print "$LISTE";
  print " \n";
}
if($opt_s) {
  $TIME = $opt_s;
}
if( ! $opt_h && $opt_c && $opt_v && $opt_t) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  $NOM_TEST = $opt_t;

# Positionnement dans le répertoire de test
  my $REP_CIBLE = "$REP_VERSION/category$CAT/$VERSION/$NOM_TEST";
  chdir "$REP_CIBLE" or die "Impossible positionner le rep $REP_CIBLE\n";
  $TOTO = `pwd`;
  print "Repertoire de test $TOTO positionné \n";


# lecture du fichier de filtrage

  my $fichierInput = "loc1_main.log";
  my $fichierOutput = "$NOM_TEST.mo";

  system("ls -al $fichierInput");

  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";

  my $SEND = 0;
  my $QUEUE = 0;
  my $OK = 0;

  while(<Fin>){
    
    if($_ =~ /CNS API/){
      if($_ =~ /SyCnsQueueSender_send/) {
	$SEND=1;
      }
      if($_ =~ /queueSender  <= 4/ && $SEND==1){
	$QUEUE=4;
	$SEND = 0;
      }
      if($_ =~ /message/ && $QUEUE == 4){
	$OK = 1;
	$QUEUE=0;
      }
      if( $_ !~ /message/ && $OK == 1) { 
	
	my $MSG = $_;
	my @MOT = split" ", $MSG;
	print "$MSG";
	
	my $Heure = conv2Time ($MOT[1]);
	$MOT[34] =~ /..(..)/;
	my $M_TYPE = $1;
	if ( $MOT[13] =~ /\d\d01/ ){
	  print Fout "$Heure 0000000A 0B0000$M_TYPE $MOT[32] $MOT[33]  $MOT[34]\n";
	}
	else {
	  print Fout "$Heure 0000000A 0A0000$M_TYPE $MOT[32] $MOT[33]  $MOT[34]\n";
	}
	$OK = 0;
      }
    }
    
  }
close Fin;
close Fout;
# split du fichier .mo par tranche d'une minute
  $fichierInput = "$NOM_TEST.mo";
  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  my $I_old = 1;
  $fichierOutput = "$NOM_TEST"."_$I_old.mo";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier d'entree $fichierOutput \n";
  while(<Fin>){
    my $Ligne = $_;
    my @Mot = split" ", $Ligne;
    my $heure = (split ":", $Mot[0])[0];
    my $minute = (split ":", $Mot[0])[1];
    my $I = $heure*60+$minute;
    
    if ($I < $I_old){
      print Fout "$Ligne";
    }
    else {
      close Fout;
      $I_old =  $I+1;
      $fichierOutput = "$NOM_TEST"."_$I_old.mo";
      open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier d'entree $fichierOutput \n";
       print Fout "$Ligne";
    }
  }
}
exit 0;
	

# convertit un chrono en nombre d'heure de minute et de seconde

sub conv2Time {
    my $chrono = shift;
    my $heure = int ($chrono/3600) ;
    my $minute = int (($chrono - ($heure*3600))/60);
    my $seconde = $chrono - ($heure*3600) - ($minute *60);
    $heure = "0"."$heure";
    $heure =~ s/\d*(\d\d)$/$1/;
    #print "heure = $heure\n";
    $minute = "0"."$minute";
    $minute =~ s/\d*(\d\d)$/$1/;
    #print "minute = $minute\n";
    if ($seconde =~ /\./){
	$seconde = "0"."$seconde"."000";
    }
    else {
	$seconde = "0"."$seconde".".000";
    }
    #print "$seconde\n";
    $seconde =~ s/\d*(\d\d)\.(\d{3})\d*$/$1\.$2/;
    #print "seconde = $seconde\n";
    
    my $toto = "$heure".":$minute".":$seconde";
    return $toto;
}

# convertit une heure en chrono référence log

sub time2Chrono {
	$heure = shift;
	$minute = shift;
	$seconde = shift;

	$chrono1 = $heure*3600 + $minute*60 + $seconde;
	#$chrono2 = $heureDebut*3600 + $minuteDebut*60 + $secondeDebut;
	#print "heure : $heure\n";
	#print "heure debut : $heureDebut\n";
	#print "chrono2 : $chrono2\n";
	return ($chrono1);
}

# test si le chrono est compris entre chronoDebut et chronoFin

sub isInTime {

	$chronox = shift;
	#print "chrono: $chronox \n";
	#print "fin   : $chronoFin \n";
	#print "debut : $chronoDebut) \n";
	if ($chronox < $chronoFin && $chronox > $chronoDebut) { return "oui";}
	else { return "non";}
}

exit(0);
