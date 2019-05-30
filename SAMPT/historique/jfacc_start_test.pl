#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("abhc:v:us:t:lidwr:x");

my $VERSION;
my $VERSION_DLIP = "JFACC";


my $NOM_TEST;
my $LOCAL_DIR = `pwd`;


my @NOM_PROCESS ;

#my $REP_TEST = "/free2/samptivq/tests";
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/";
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



sub synchroniser(){	  
  # Calcul de l'heure locale pour la synchronisation des exe
  ($second, $minute,$hour,$day, $month,$year)=(localtime)[0,1,2,3,4,5];
  $month = $month+1;
  $year=$year+1900;
  $second=((($hour*60)+$minute)*60)+$second+$DELTATPS;
  print "$hour:$minute:$second le $day/$month/$year\n";
  return;
}
sub creer_stop_file(){
  #chdir($LOCAL_DIR);
  print "création du fichier stop dans $LOCAL_DIR\n";
  my $PID;
  my $PROC_NAME = "";
  my @PS = (`ps -edf`);
  my @PS_2 = (`$RSH_CMD ps -ax`);
  open Fout, ">$REP_LOCAL/stop" or die "impossible d'ouvrir ./stop \n";
  print Fout "#!/usr/bin/ksh\n";
  for my $LIGNE (@PS) {
    chomp ($LIGNE);
    # arret du script de non regression
    if ($LIGNE =~ /sampt_start_/ ) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      #print "PID perl : $$ \n";
      #print "PID TD   : $PID \n";
      print Fout "kill -9 $PID\n" if($PID > $$);
      #print "$PROC_NAME PID =  $PID\n";
    }
    if ($LIGNE =~ /_test_driver/ ) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      #print "PID perl : $$ \n";
      #print "PID TD   : $PID \n";
      print Fout "kill -9 $PID\n" if($PID > $$);
      #print "$PROC_NAME PID =  $PID\n";
    }
    if ($LIGNE =~ /watchCPU/ ) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -9 $PID\n";
      #print "$PROC_NAME PID =  $PID\n";
    }
   if ($LIGNE =~ /watchRAM/ ) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -9 $PID\n";
      #print "$PROC_NAME PID =  $PID\n";
    }
  }
# Ajout de la suppression du SUIP
for my $LIGNE (@PS_2) {
	if ($LIGNE =~ /suip_main/ && ! $opt_a) {
      	$PID = (split " ",$LIGNE) [0];
      	$PROC_NAME = (split " ", $LIGNE)[7];
      	print Fout "$RSH_CMD kill -9 $PID\n";
      	#print "$PROC_NAME PID =  $PID\n";
	sleep 1;
    	}
 }
for my $LIGNE (@PS_2) {
      chomp ($LIGNE);
      #print"$LIGNE\n";
      if ($LIGNE =~ /sampt_main/ && ! $opt_a) {
      	$PID = (split " ",$LIGNE) [0];
      	$PROC_NAME = (split " ", $LIGNE)[10];
      	print Fout "$RSH_CMD kill -9 $PID\n";
      	#print "$PROC_NAME PID =  $PID\n";
    	}
}
for my $LIGNE (@PS_2) {
      if ($LIGNE =~ /slp/ && ! $opt_a) {
      	$PID = (split " ",$LIGNE) [0];
      	$PROC_NAME = (split " ", $LIGNE)[10];
      	print Fout "$RSH_CMD kill -9 $PID\n";
      	#print "$PROC_NAME PID =  $PID\n";
    	}
} 
for my $LIGNE (@PS_2) {
      if ($LIGNE =~ /SNCP/ && ! $opt_a) {
      	$PID = (split " ",$LIGNE) [0];
      	$PROC_NAME = (split " ", $LIGNE)[7];
      	print Fout "$RSH_CMD kill -9 $PID\n";
      	#print "$PROC_NAME PID =  $PID\n";
	sleep 1;
    	}
}
for my $LIGNE (@PS_2) {
	if ($LIGNE =~ /recorder/ && ! $opt_a) {
      	$PID = (split " ",$LIGNE) [0];
      	$PROC_NAME = (split " ", $LIGNE)[7];
      	print Fout "$RSH_CMD kill -9 $PID\n";
      	#print "$PROC_NAME PID =  $PID\n";
	sleep 1;
    	}
 }
  print Fout "rm $REP_LOCAL/stop\n";
  print Fout "exit 0\n";
  close Fout;
  system("chmod +x $REP_LOCAL/stop");
  return 0;
}

if ($opt_h) { 
	print "sampt_start_test.pl [-h] [-c 1 à 9] [-v nom_version][-t nom_test][-l] [-d][-w] [-a]: init du repertoire de run  \n";
	print "c=1 répertoire test : $REP_TEST_CONFIG1/$VERSION_DLIP\n";
	print "c=2 répertoire test : $REP_TEST_CONFIG2/$VERSION_DLIP\n";
	print "c=3 répertoire test : $REP_TEST_CONFIG3/$VERSION_DLIP\n";
	print "c=4 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=5 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=6 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
	print "c=7 répertoire test : $REP_TEST_CONFIG4/$VERSION_DLIP\n";
	print "c=8 répertoire test : $REP_TEST_CONFIG5/$VERSION_DLIP\n";
	print "c=9 répertoire test : $REP_TEST_CONFIG6/$VERSION_DLIP\n";
	print "-l : lance le l16_test_driver\n";
	print "-d : redirige les log vers /hd1/RECORDING\n";
	print "-w : lance les scripts watchCPU.pl et watchRAM.pl\n";
    print "-i : lance le ti_test_driver\n";
	print "-a : ne lance pas les executable sur le rack\n";
}

# Si toutes les options sont definies

if( ! $opt_h && $opt_r && $opt_c && $opt_t ) {

# Definir la version du DLIP (par defaut $VERSION_DLIP)
	$VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v"if($opt_v);
# Definir le nom du test
	$NOM_TEST = "$opt_t";
#	$Nom_test = lc $NOM_TEST;
# Definir le rack
	$RSH_CMD = $RSH_CMD1;
	$RSH_CMD = $RSH_CMD2 if ($opt_r == 2);
	$RSH_CMD = $RSH_CMD3 if ($opt_r == 3);
	
# Definir le repertoire de test 
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
		exit 0;
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG1" if ($CONFIG_TEST == 1);
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG2" if ($CONFIG_TEST == 2);
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG3" if ($CONFIG_TEST == 3);
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG4" if ($CONFIG_TEST == 4);
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG5" if ($CONFIG_TEST == 5);
	$REP_TEST_CONFIG = "$REP_TEST_CONFIG6" if ($CONFIG_TEST == 6);
	$REP_RUN_TEST = "$REP_TEST_CONFIG/$NOM_TEST/";
	print "$REP_RUN_TEST\n";
	
# Définir la la durée du  test dans le fichier listant les tests à passer
	my $Duree = 1000;

      	if($opt_s){
	  "$opt_s";
	}

# Lancement des exe en conf UMAT

	chdir ("$REP_RUN_TEST");
	print "Repertoire du test $REP_RUN_TEST\n";
#	system ("$RSH_CMD 'cd $REP_RUN ; rm slp*.log'");
# Lancement des exe sur le rack si $opt_a n'est pas comme option

# Lancement des TD	
	synchroniser();
	print "Lancement TD...\n";
	print "xterm -title L16_TEST_DRIVER -geometry 150x40-300+300 -e ./l16_test_driver l16_test_driver.conf $year $month $day $second &\n" if($opt_l);	
	system("xterm -title L16_TEST_DRIVER -geometry 150x40-300+300 -e ./l16_test_driver l16_test_driver.conf $year $month $day $second & ")if($opt_l && !$opt_x);
	system("./l16_test_driver l16_test_driver.conf  $year $month $day $second &")if($opt_l && $opt_x);
#	print "xterm -title TI_TEST_DRIVER -geometry 150x40-300+300 -e ./ti_test_driver ti_test_driver.conf  $year $month $day $second &\n"if($opt_i);
#	system("xterm -title TI_TEST_DRIVER -geometry 150x40-300+300 -e ./ti_test_driver ti_test_driver.conf  $year $month $day $second &")if($opt_i && !$opt_x);
#	system(" ./ti_test_driver ti_test_driver.conf $year $month $day $second &2>&1 > /dev/null")if($opt_i && $opt_x);
	print "xterm -title HOST_TEST_DRIVER -geometry 150x40-300+300 -e ./host_test_driver host_test_driver.conf  $year $month $day $second\n";
	system("xterm -title HOST_TEST_DRIVER -geometry 150x40-300+300 -e ./host_test_driver host_test_driver.conf $year $month $day $second &")if(!$opt_x);
	system("./host_test_driver host_test_driver.conf  $year $month $day $second &")if($opt_x);
	#system("./host_test_driver host_test_driver.conf $year $month $day $second &")if($opt_x);
	
# Lancement des scripts de mesure
#	system("$RSH_CMD '/hd2/SCRIPTS_IVQ/watchCPU.sh' &")if($opt_w);
	system("watchCPU.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t &")if($opt_w);
	system("watchRAM.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t &")if($opt_w);
	sleep 10;
	creer_stop_file();
	#exit 0;
      

	print "# Attente fin du test ...\n";
	while ($Duree > 0){
		sleep 1;
		$Duree = $Duree - 1;
	}
	print "# Arret du test ...\n";
	system("$REP_LOCAL/stop");
} 
exit 0;





