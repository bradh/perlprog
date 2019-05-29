#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("abhc:v:us:t:lidwr:x");

my $VERSION;
my $VERSION_DLIP = "SAMPT_V5";


my $NOM_TEST;
my $LOCAL_DIR = `pwd`;


my @NOM_PROCESS ;

#my $REP_TEST = "/free2/samptivq/tests";
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_REF = "reference_ATP";
my $REP_FIC_COM = "fichiers_communs";
my $FIC_NON_REG = "sampt_non_reg_test_list.txt";

my $REP_TEST_CONFIG;
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

my $REP_RUN = "/rd1/RUN"; # répertoire du test
my $REP_LOCAL = $ENV{PWD};
print "repertoire local : $REP_LOCAL\n";

my $DLIP_HOTE1 = "rackP0";
my $DLIP_HOTE2 = "rackP1";
my $DLIP_HOTE3 = "rackP3";

my $RSH_CMD;
my $RSH_CMD1 = "rsh   $DLIP_HOTE1 -l root";
my $RSH_CMD2 = "rsh   $DLIP_HOTE2 -l root";
my $RSH_CMD3 = "rsh   $DLIP_HOTE3 -l root";

my $year;
my $month;
my $day;
my $minute;
my $second;
my $DELTATPS = 0; # Décalage du lancement des test driver en secondes

synchroniser();
exit 0;

sub synchroniser(){	  
  # Calcul de l'heure locale pour la synchronisation des exe
  ($second, $minute,$hour,$day, $month,$year)=(localtime)[0,1,2,3,4,5];
  $month = $month+1;
  $year=$year+1900;
  $second=((($hour*60)+$minute)*60)+$second+$DELTATPS-3600;
  print "$hour:$minute:$second le $day/$month/$year\n";
  return;
}