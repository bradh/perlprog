#!/usr/bin/perl 

use Getopt::Std;
use Time::Local;

getopts("hxc:v:t:s:l:m:");

my @NOM_PROCESS_PEL_CAT1_L11 = (
		   "loc1_launcher",
		   );
my @NOM_PROCESS_CTIF_CAT1_L11 = ("loc1_main", 
		   "host_test_driver",
		   "l11_test_driver",
		   "dts_control_simulator");
my @NOM_PROCESS_PEL_CAT2_L11 = (
		   "loc1_launcher"
		   );
my @NOM_PROCESS_CTIF_CAT2_L11 = ("loc1_main",
		   "host_test_driver");
my @NOM_PROCESS_PEL_CAT1_L16 = (
		   "loc1_launcher"
		   );
my @NOM_PROCESS_CTIF_CAT1_L16 = ("loc1_main", 
		   "host_test_driver",
		   "l16_test_driver"
		   );
my @NOM_PROCESS_PEL_CAT2_L16 = (
		   "loc1_launcher"
		   );
my @NOM_PROCESS_CTIF_CAT2_L16 = ("loc1_main",
				 "l16_test_driver",
		   "host_test_driver");
my @PROCESS;
my $REP_BASE = "/data/users/loc1int/DLIP/test/test_tu";
my $REP_SCRIPT = "/data/users/loc1int/DLIP/test/utils/scripts";
my $REP_RESULTS = "results";
my $REP_COMMON_FILES = "common_files";
my $REP_RESULTAT = "results";
my $REP_CHECKER = "checker_results";
my $DURATION_FILE="test_duration_list.txt";
my $REP_DUREE;
my $REP_CIBLE;
my $CAT = 1;
my $TEST_MODE="DIV";# CTIF ou PEL ou DIV
my $LINK_TYPE="DIV";# L16 ou L11 ou MOP ou DIV
my $VERSION;
my $NOM_TEST;
my $TIME = 600;
my $DELTATPS=5; # declage en seconde pour la synchronisation des executables
my $RECAP_RESULTS = 0; # si = 1 compil les resultats dans le repertoires result si = 0 lance le test 
my $PORT_DTS = "7000";

if ($opt_h) { 
	print "loc1_start_test.pl [-c] [-h] : liste des versions dlip \n";
	print "loc1_start_test.pl [-c] [-v n_version ][-h] : liste des tests existants \n";
	print "loc1_start_test.pl [-c] [-v n_version ][-t nom_du_test][-s temp_du_test][-x] [-l link_type]: lancement d'un test L11 et L16\n";
	print "l'option -x inhibit le lancement des xterm showlog et showerr\n";
	print "Si le link_type n'est pas L11, lance un test pure L16 \n";
	print "Si le link_type n'est L16, lance un test pure L11\n";
	print "Si le link_type n'est pas defini, lance un test all link\n";
	print " \n";
}
if ($opt_h && $opt_c && ! $opt_v) {
  $CAT = $opt_c;
  print "categorie = $CAT \n";
  my $LISTE = `ls $REP_BASE/category$CAT`;
  print "Liste des versions DLIP en test catégorie $CAT :\n";
  print "$LISTE";
  print " \n";
}
if ($opt_h && $opt_c && $opt_v) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  my $LISTE = `ls $REP_BASE/category$CAT/$VERSION`;
  print "Liste des tests categorie $CAT pour la version DLIP $VERSION :\n";
  print "$LISTE";
  print " \n";
}
if(!$opt_h && $opt_c && $opt_v && $opt_t && ! $opt_l){
  # Determination du type de link
  $TEST_NAME = $opt_t;
  if ( $TEST_NAME =~ /^L11_/) {
    $opt_l = "L11";
  }
  if ( $TEST_NAME =~ /^L16_/ || $TEST_NAME =~ /^REC_/ ||  $TEST_NAME =~ /^SYS_/ ) {
    $opt_l ="L16";
  }
  if ( $TEST_NAME =~ /^MXS/){
    print "$TEST_NAME not L11 or L16";
    exit -1;
  }
}
#print " Link type = $opt_l\n";
if( ! $opt_h && $opt_c && $opt_v && $opt_t && $opt_l) {
  $CAT = $opt_c;
  $VERSION = $opt_v;
  $TEST_NAME = $opt_t;
  $LINK_TYPE = $opt_l;
  # Lecture du fichier duree_des_tests.txt et calcul de la durée du test en seconde et du mode de test
  if( ! $opt_s || ! $opt_m ) {
    $REP_DUREE="$REP_BASE/category$CAT/$REP_COMMON_FILES";
    open Fin, "<$REP_DUREE/$DURATION_FILE" or die "Impossible d'ouvrir $REP_DUREE/$DURATION_FILE\n";
    my $TEST_OK = 0;
    while(<Fin>){
      #print "$_\n";
      chomp;
      my $LINE = $_;
      my $KEY;
      if( $LINE =~ /^$TEST_NAME/){
	($KEY, $VALUE) = split( ":", $_);
	#print "$VALUE\n";
	if ($VALUE ne "x" && $VALUE ne "DIV"){
	  #print "CTIF\n";
	  $TEST_MODE = "CTIF";
	  $TIME = $VALUE*60;
	}
	if($VALUE eq "x"){
	  #print "PEL\n";
	  $TEST_MODE = "PEL";
	}
	$TEST_OK =1;
      }
    }
    if ($TEST_OK == 0){
      print "Le test n'est pas dans le fichier $DURATION_FILE\n";
      exit -1;
    }
    if ( $TEST_MODE eq "DIV" ){
      print "Le test est de type DIV\n";
      exit -1;
    }
    close Fin;
  }
  else {
    $TIME = $opt_s if ($opt_s);
    $TEST_MODE = $opt_m if($opt_m);
  }
  print "Nom du test = $TEST_NAME\n";
  print "Mode du test = $TEST_MODE\n";
  print "Type de link du test = $opt_l\n";
  # Positionnement dans le répertoire de test
  my $REP_CIBLE = "$REP_BASE/category$CAT/$VERSION/$TEST_NAME";
  chdir "$REP_CIBLE" or die "Impossible positionner le rep $REP_CIBLE\n";
  #$TOTO = `pwd`;
  # print "Repertoire de test $TOTO positionné \n";
  # Positionnement de la version
  # system("set_dlip_version -v $VERSION"); 
  # Nettoyage du repertoire
  #system("cleanin");

  # Affichage des versions des exe positionnés
  my $TEXT = `show_version`;
  # print "$TEXT";
  # Sauvegarde des version des exe positionnés 
  open Fout,">version.txt" or die "impossible d'ouvrir version.txt\n";
  print Fout "$TEXT";
  close Fout;

  # Calcul du temps du test en mode PEL
  if($TEST_MODE eq "PEL"){
    open Fin, "<$REP_CIBLE/loc1_launcher.conf" or die "Impossible d'ouvrir le fichier loc1_launcher.conf du test PEL $TEST_NAME"; 
    while(<Fin>){
      chomp;
      if( $_ =~ /SCENARIO_TIME/){
	($A, $TIME) = split("=", $_);
      }
    }
    close Fout;
  }
  print "Durée du test = $TIME\n";
  $RECAP_RESULTS = 0;
  if(! $RECAP_RESULTS){
    if($TEST_MODE eq "CTIF"){
      synchroniser();
      if($CAT == 1){
	if($LINK_TYPE eq "L11"){
	  @PROCESS = (@NOM_PROCESS_CTIF_CAT1_L11);
	  lancer_exe();
	}
	if($LINK_TYPE eq "L16"){
	  @PROCESS = (@NOM_PROCESS_CTIF_CAT1_L16);
	  lancer_exe();
	}
      }
      if($CAT == 2 || $CAT == 6){
	if($LINK_TYPE eq "L11"){
	  @PROCESS = (@NOM_PROCESS_CTIF_CAT2_L11);
	  print "Démarrage dans 5 secondes...\n";
	  sleep 1;
	  print "Démarrage dans 4 secondes...\n";
	  sleep 1;
	  print "Démarrage dans 3 secondes...\n";
	  sleep 1;
	  print "Démarrage dans 2 secondes...\n";
	  sleep 1;
	  print "Démarrage dans 1 secondes...\n";
	  sleep 1;
	  print "GO!\n\n";
	  lancer_exe();
	}
	if($LINK_TYPE eq "L16"){
	  @PROCESS = (@NOM_PROCESS_CTIF_CAT2_L16);
	  lancer_exe();
	}
      }
      creer_stop_file();
    }
    if($TEST_MODE eq "PEL"){
      if($CAT == 1){
	if($LINK_TYPE eq "L11"){
	  #print "toto\n";
	  @PROCESS = (@NOM_PROCESS_PEL_CAT1_L11);
	  lancer_exe();
	}
	if($LINK_TYPE eq "L16"){
	  @PROCESS = (@NOM_PROCESS_PEL_CAT1_L16);
	  lancer_exe();
	}
      }
      if($CAT == 2 || $CAT == 6){
	if($LINK_TYPE eq "L11"){
	  @PROCESS = (@NOM_PROCESS_PEL_CAT2_L11);
	  lancer_exe();
	}
	if($LINK_TYPE eq "L16"){
	  @PROCESS = (@NOM_PROCESS_PEL_CAT2_L16);
	  lancer_exe();
	}
      }
    }
    system("xterm -e showerr &") if(! $opt_x);
    system("xterm -e showlog &") if(! $opt_x);
    # Calcul de la durée du scenario
    $TIME = $TIME + 20;
    while ( $TIME != 0) {
      sleep 1;
      $TIME=$TIME-1;
    }   
    # Arret des executables
    if($TEST_MODE eq "CTIF"){
      system("stop");
      print "Test terminé\n";
    }
  }
  # Analyse du fichier log
  system("error_extract.pl -c $CAT -v $VERSION -t $TEST_NAME");
  # Lancement du resulter
  system("start_checker -c $CAT -v reference -w $VERSION -t $TEST_NAME -x");
  system("resulter2aladdin.pl -c 2 -t $TEST_NAME");
  system("cp $REP_BASE/category$CAT/$REP_CHECKER/$TEST_NAME/*.res* $REP_BASE/category$CAT/$VERSION/$TEST_NAME");

  # nettoyage du répertoire
  system("cleanout");

  #system("rm  *.xdh *.jo *.fim $REP_SCRIPT/stop");
  #system("rm $REP_SCRIPT/stop");

  chdir ".." or die "Impossible positionner le repertoire pere\n";
  # compilation des résultats avec 
  system("tar cvf $TEST_NAME.tar $TEST_NAME/*");
  #system("tar cvf $TEST_NAME.tar *.xhd *.xdh *.jo *.ji *.log* *.f?m");
  system("gzip -f $TEST_NAME.tar");
  # Move du tar.gz dans $REP_RESULTS
  print "rep_result =  $REP_BASE/category$CAT/$REP_RESULTAT\n";
  system("mv $TEST_NAME.tar.gz $REP_BASE/category$CAT/$REP_RESULTAT");
exit 0;
}

sub synchroniser(){	  
  # Calcul de l'heure locale pour la synchronisation des exe
  ($second, $minute,$hour,$day, $month,$year)=(localtime)[0,1,2,3,4,5];
  $month = $month+1;
  $year=$year+1900;
  #print "$hour:$minute:$second le $day/$month/$year\n";
  $second=(($hour*60)+$minute)*60+$second+$DELTATPS;
  # create loc1_main.synchro file
  open Fout, ">loc1_main.synchro" or die "impossible de creer loc1_main.synchro\n";
  print Fout "Synchro_Year=$year\n";
  print Fout "Synchro_Month=$month\n";
  print Fout "Synchro_Day=$day\n";
  print Fout "Synchro_Seconds=$second\n";
  close Fout;
}

sub lancer_exe(){
  # Lancement des executables
  for my $PROCESS (@PROCESS) {
    if ($PROCESS eq "loc1_main") {
      # Pour tracer les appels systeme
      #      system ("truss -t open,close,ioctl,so_socket -s \!14 loc1_main > traces.sys.err 2>&1 &");
      system ("loc1_main > /dev/null 2>&1  &");
      print "loc1_main lancé...\n";
    }
    if($PROCESS eq "host_test_driver" && $opt_l ne "L11" ) {
      system("host_test_driver C2_test_driver.conf $year $month $day $second > C2_host_test_driver.log &");
      print "C2_host_test_driver lancé ...\n";
      system("host_test_driver L16NCM_test_driver.conf $year $month $day $second > L16NCM_host_test_driver.log &");
      print "L16NCM_host_test_driver lancé ...\n";
    }
    if($PROCESS eq "host_test_driver" && $opt_l ne "L16" ) {
      system("host_test_driver C2_test_driver.conf $year $month $day $second > C2_host_test_driver.log &");
      print "C2_host_test_driver lancé ...\n";
      system("host_test_driver DLCM_test_driver.conf $year $month $day $second > DLCM_host_test_driver.log &");
      print "DLCM_host_test_driver lancé ...\n";
    }
    if($PROCESS eq "l16_test_driver" && $opt_l ne "L11") {
      system("l16_test_driver l16_test_driver.conf $year $month $day $second > /dev/null 2>&1 &");
      print "l16_test_driver lancé ...\n";
    }
    if($PROCESS eq "l16_test_driver" && $opt_l ne "L16") {
      system("l11_test_driver DTS_test_driver.conf $year $month $day $second > /dev/null 2>&1 &");
      print "l11_test_driver lancé ...\n";
      system("dts_control_simulator -p $PORT_DTS -d dts_control_simu.log.log > /dev/null 2>&1 &");
      print "dts_control_simulator lancé ...\n";
    }
    if($PROCESS eq "loc1_launcher") {
      system("loc1_launcher loc1_launcher.conf > loc1_launcher.log &");
      print "loc1_launcher lancé ...\n";
    }
  }
}
sub creer_stop_file(){    
  # création du fichier stop
  my $PID;
  my $PROC_NAME = "toto";
  my @PS = (`ps -f`);
  open Fout, ">$REP_SCRIPT/stop" or die "impossible d'ouvrir $REP_SCRIPT/stop \n";
  print Fout "#!/usr/bin/ksh\n";
  for my $LIGNE (@PS) {
    chomp ($LIGNE);
    if ($LIGNE =~ /loc1_main/) {
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -15 $PID\n";
      #print "$PROC_NAME PID =  $PID\n";
    }
    if ($LIGNE =~ /host_test_driver|l16_test_driver|l11_test_driver/) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -9 $PID\n";
      #print "$PROC_NAME PID =  $PID\n";
    }
    if ($LIGNE =~ /dts_control_simulator/) {
      #print "\n";
      #print "$LIGNE \n";
      $PID = (split " ",$LIGNE) [1];
      $PROC_NAME = (split " ", $LIGNE)[7];
      print Fout "kill -9 $PID\n";
      #print "$PROC_NAME PID =  $PID\n";
    }
  }
  print Fout "rm $REP_SCRIPT/stop\n";
  print Fout "exit 0\n";
  close Fout;
  system("chmod +x $REP_SCRIPT/stop");
}
