#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("abhc:v:us:t:lidwr:");

my $VERSION;
my $VERSION_DLIP = "SAMPT_MCO";


my $NOM_TEST;

my @NOM_PROCESS ;

my $REP_TEST = "/free/samptivq/tests";
#my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests";
my $REP_TEST_CONFIG;
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

my $REP_RUN = "/rd1/RUN"; # répertoire du test

my $DLIP_HOTE1 = "200.1.18.2";
my $DLIP_HOTE2 = "200.1.18.5";
my $DLIP_HOTE3 = "200.1.18.6";

my $RSH_CMD;
my $RSH_CMD1 = "rsh   $DLIP_HOTE1 -l root";
my $RSH_CMD2 = "rsh   $DLIP_HOTE2 -l root";
my $RSH_CMD3 = "rsh   $DLIP_HOTE3 -l root";

my $year;
my $month;
my $day;
my $minute;
my $second;
my $DELTATPS = 10; # Décalage du lancement des test driver en secondes

sub synchroniser(){	  
  # Calcul de l'heure locale pour la synchronisation des exe
  ($second, $minute,$hour,$day, $month,$year)=(gmtime)[0,1,2,3,4,5];
  $month = $month+1;
  $year=$year+1900;
  $second=((($hour*60)+$minute)*60)+$second+$DELTATPS;
  print "$hour:$minute:$second le $day/$month/$year\n";
  return;
}
sub creer_stop_file(){
  print "création du fichier stop\n";
  my $PID;
  my $PROC_NAME = "";
  my @PS = (`ps -edf`);
  my @PS_2 = (`$RSH_CMD ps -ax`);
  open Fout, ">./stop" or die "impossible d'ouvrir ./stop \n";
  print Fout "#!/usr/bin/ksh\n";
  for my $LIGNE (@PS) {
    chomp ($LIGNE);
    if ($LIGNE =~ /_test_driver/ ) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -9 $PID\n";
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
  print Fout "rm ./stop\n";
  print Fout "exit 0\n";
  close Fout;
  system("chmod +x ./stop");
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
# Definir la durée du scenario
	my $Duree = 1000;
	$Duree = "$opt_s" if($opt_s);
	print "Durée du scenario = $Duree\n";


# Definir la version du DLIP (par defaut $VERSION_DLIP)
	$VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v"if($opt_v);
# Definir le nom du test
	$NOM_TEST = "$opt_t";
#	$NOM_TEST = lc $NOM_TEST;
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
	$REP_TEST = "$REP_TEST_CONFIG/$VERSION/$NOM_TEST";
	print "$REP_TEST\n";

# Lancement des exe en conf UMAT
if ($CONFIG_TEST == 1 || $CONFIG_TEST == 2 || $CONFIG_TEST ==  4 || $CONFIG_TEST == 5 ) {
	chdir ("$REP_TEST");
	print "$REP_TEST\n";
#	system ("$RSH_CMD 'cd $REP_RUN ; rm slp*.log'");
# Lancement des exe sur le rack si $opt_a n'est pas comme option
	if (! $opt_a) {
		#print "Lancement recorder...\n";
		system("xterm -title RECORDER -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ; recorder recorder.conf ' &")if(! $opt_d);
		#system("xterm -title RECORDER -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ; recorder recorder.conf 2>&1 > /hd2/RECORDING/recorder.log ' &")if(!$opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ; recorder recorder.conf' &")if($opt_d);
                # attendre 40 secondes au moins car l'init du recorder prend du temps si bcp de fichiers de log
                sleep 10;
		print "Lancement slp...\n";
		system("xterm -title SERVER_SLP -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ;slp 5001 '&")if(! $opt_d);
		#system("xterm -title SERVER_SLP -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ;slp 5001 2>&1 > /hd2/RECORDING/slp.log ' &") if (!$opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ;slp 5001' &") if ($opt_d);
		print "Lancement sampt_main...\n";
		print "xterm -title SAMPT_MAIN -geometry 150x40-300+300 -e $RSH_CMD 'TZ=UCT ; export TZ ;cd $REP_RUN ; sampt_main ' &\n";
		system("xterm -title SAMPT_MAIN -geometry 150x40-300+300 -e $RSH_CMD 'TZ=UCT ; export TZ ;cd $REP_RUN ; sampt_main ' &")if(!$opt_d );
		#system("xterm -title SAMPT_MAIN -geometry 150x40-300+300 -e $RSH_CMD 'TZ=UCT ; export TZ ;cd $REP_RUN ; sampt_main > /hd1/sampt_main.log 2>&1' &")if(!$opt_d);
		#system("$RSH_CMD 'TZ=UCT ; export TZ ; cd $REP_RUN ; sampt_main ' & ")if($opt_d);
		print "Lancement SNCP pour rien...\n";
		system("xterm -title SNCP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; SNCP -debug SNCP.xml '&") if(! $opt_d);
		#system("xterm -title SNCP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; SNCP  -debug SNCP.xml 2>&1 > /hd2/RECORDING/sncp.log '&") if(!$opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ; SNCP SNCP.xml'&") if($opt_d);
		print "Lancement SUIP...\n";
		system("xterm -title SUIP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; suip_main '&") if(! $opt_d);
		#system("xterm -title SUIP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; suip_main  -d 2>&1 > /hd2/RECORDING/suip.log '&") if(!$opt_d);
	}
# Lancement des TD	
	synchroniser();
	print "Lancement TD...\n";
	print "xterm -title L16_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver l16_test_driver.conf $year $month $day $second &\n";	
	system("xterm -title L16_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/l16_test_driver l16_test_driver.conf $year $month $day $second &")if($opt_l);	
	print "xterm -title TI_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/ti_test_driver ti_test_driver.conf $year $month $day $second &\n";
	system("xterm -title TI_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/L16_Test_Driver/ti_test_driver ti_test_driver.conf $year $month $day $second &")if($opt_i);
	print "xterm -title HOST_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver host_test_driver.conf $year $month $day $second &\n";
	system("xterm -title HOST_TEST_DRIVER -geometry 150x40-300+300 -e /h7_usr/sil2_usr/samptivq/tools/Host_test_Driver/host_test_driver host_test_driver.conf $year $month $day $second &");
	
# Lancement des scripts de mesure
#	system("$RSH_CMD '/hd2/SCRIPTS_IVQ/watchCPU.sh' &")if($opt_w);
	system("watchCPU.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t &")if($opt_w);
	system("watchRAM.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t &")if($opt_w);
	sleep 10;
	creer_stop_file();
	#exit 0;
}

# Lancement des exe en conf SIMPLE
if ($CONFIG_TEST == 3 || $CONFIG_TEST == 6) {
	#print "$REP_TEST";
	chdir ("$REP_TEST");
	#print "TEST\n";
#	system ("$RSH_CMD 'cd $REP_RUN ; rm slp.log'");
	if (! $opt_a){
		print "Lancement sampt_main...\n";
		#system("xterm -title SAMPT_MAIN -geometry 150x40-300+300  -e $RSH_CMD 'TZ=UCT ; export TZ ; cd $REP_RUN ; sampt_main'&")if(! $opt_d);
		system("xterm -title SAMPT_MAIN -geometry 150x40-300+300  -e $RSH_CMD 'TZ=UCT ; export TZ ;cd $REP_RUN ; sampt_main  2>&1 > /hd2/sampt_main.log'&")if($opt_d);
		#system(" $RSH_CMD 'cd $REP_RUN ; sampt_main ' > toto.log &")if($opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ; sampt_main &' &")if($opt_d);
		print "Lancement slp...\n";
		#system("xterm -title SERVER_SLP  -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ;slp 5001 '&");
		system("xterm -title SERVER_SLP -geometry 150x40-300+300 -e $RSH_CMD 'cd $REP_RUN ;slp 5001 2>&1 > /hd2/RECORDING/slp.log ' &") if($opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ;slp 5001 & '&") if($opt_d);
		print "Lancement SNCP...\n";	
		#system("xterm -title SNCP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; SNCP -debug SNCP.xml '&");
		system("xterm -title SNCP -geometry 68x34-0-300 -e $RSH_CMD 'cd $REP_RUN ; SNCP -debug SNCP.xml 2>&1 > /hd2/RECORDING/sncp.log '&") if($opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ; SNCP SNCP.xml &'&") if($opt_d);
		sleep 1;
		print "Lancement recorder...\n";
		#system("xterm -title RECORDER -geometry 68x20-0+0 -e $RSH_CMD 'cd $REP_RUN ; recorder recorder.conf'&");	
		system("xterm -title RECORDER -geometry 68x20-0+0 -e $RSH_CMD 'cd $REP_RUN ; recorder recorder.conf  2>&1 > /hd2/RECORDING/recorder.log'&")if($opt_d);
		#system("$RSH_CMD 'cd $REP_RUN ; recorder recorder.conf & '&")if($opt_d);
		print "Lancement l16 test driver ...\n" if($opt_l);
	}
# Lancement des TD	
	synchroniser();
	print "Lancement TD...\n";
	system("xterm -title L16_TEST_DRIVER -geometry 150x40-300+300 -e l16_test_driver l16_test_driver.conf $year $month $day $second &")if($opt_l);
	print "Lancement host test driver...\n";
	system("xterm -title HOST_TEST_DRIVER -geometry 150x20-300+0 -e host_test_driver host_test_driver.conf $year $month $day $second &");
	system("xterm -title TI_TEST_DRIVER -e ./ti_test_driver ti_test_driver.conf $year $month $day $second &")if($opt_i);
# Lancement des scripts de mesure
	#system("$RSH_CMD '/hd2/SCRIPTS_IVQ/watchCPU.sh' &")if($opt_w);
	system("watchCPU.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t 2>&1 > /hd2/RECORDING/cpu.log &")if($opt_w);	
	system("watchRAM.pl -r $opt_r -c $CONFIG_TEST -v $VERSION_DLIP -t $opt_t 2>&1 > /hd2/RECORDING/ram.log &")if($opt_w);
	sleep 10;
	#print "toto";
	creer_stop_file();
	}
	print "# Attente fin du test ...\n";
	while ($Duree > 0){
		sleep 1;
		$Duree = $Duree - 1;
	}
	print "# Arret du test ...\n";
	system("./stop");
} 
exit 0;





