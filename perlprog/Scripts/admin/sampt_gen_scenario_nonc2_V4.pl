#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hcusv:t:");

my $VERSION_DLIP = "SAMPT_V4";

my @NOM_PROCESS ;
my $REP_TEST = "/h7_usr/sil2_usr/samptivq/tests/C2";
my $REP_REF_ATP = "$REP_TEST/reference_ATP_V4";
my $REP_FIC_COMM = "$REP_REF_ATP/fichiers_communs";
my $REP_TEST_REF_COMM = "$REP_REF_ATP/COMMUNS";
my $REP_TEST_REF_UMAT = "$REP_REF_ATP/UMAT";
my $REP_TEST_REF_SIMPLE = "$REP_REF_ATP/SIMPLE";
my $NOM_FIC_INIT_UMAT = "C2_INIT_UMAT.xhd";
my $NOM_FIC_INIT_SIMPLE = "C2_INIT_SIMPLE.xhd";
my $REP_TEST_RUN_UMAT;
my $REP_TEST_RUN_SIMPLE;

if ($opt_h) { 
  print "sampt_gen_scenario_c2_V4.pl [-h] [-s][-u][c]: génère les scénarios UMAT, SIMPLE et communs  \n";
}
# Cas ou l'on remet à jour tous les tests
if( ! $opt_h && ! $opt_t) {
  # Definir la version du DLIP (par defaut $VERSION_DLIP)
  $VERSION_DLIP = "$opt_v"if($opt_v);

  # Traitement des tests UMAT
  #   crée les liens entre le rep ATP du rep de RUN vers le rep ATP de reference
  #   si le fichier existe dejà arrete le programme
  if($opt_u){
    print "\n****** Traitement des tests UMAT \n";
    chdir("$REP_TEST_REF_UMAT");
    foreach $TEST (`ls`){
      chomp $TEST;
      print "\n***** Traitement $TEST\n";
      $REP_TEST_REF = "$REP_TEST_REF_UMAT/$TEST/ATP";
      ( -d $REP_TEST_REF) or die "$REP_TEST_REF n'est pas un répertoire ...\n";
      $REP_TEST_RUN_UMAT = "$REP_TEST/UMAT/$VERSION_DLIP/$TEST/ATP";
      ( -d $REP_TEST_RUN_UMAT) or die "$REP_TEST_RUN_UMAT n'est pas un répertoire ...\n";
      foreach my $FILE (`ls $REP_TEST_REF`){
	chomp $FILE;
	#print "$FILE\n";
	# Si un fichier existe dans le répertoire de run, on avertit l'operateur pour qu'il le supprime
	#(! -f "$REP_TEST_RUN_UMAT/$FILE")or die "$REP_TEST_RUN_UMAT/$FILE existe : supprimer le et relancer le script !\n";
        if($FILE =~ /\.conf/ || $FILE =~ /\.fim/ || $FILE =~ /\.fom/ || $FILE =~ /\.cfg/|| $FILE =~ /\.xhd/){
	  system ("rm  $REP_TEST_RUN_UMAT/$FILE");
	  print "rm $REP_TEST_RUN_UMAT/$FILE\n";
	  system("ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_UMAT/$FILE");
	  print "ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_UMAT/$FILE\n";
	}
      }
    }
  }

# Traitement des tests SIMPLE
  if($opt_s){
    print "\n****** Traitement des tests SIMPLE \n";
    chdir("$REP_TEST_REF_SIMPLE"); 
    foreach $TEST (`ls`){
      chomp $TEST;
      print "\n***** Traitement $TEST \n";
      $REP_TEST_REF = "$REP_TEST_REF_SIMPLE/$TEST/ATP";
      ( -d $REP_TEST_REF) or die "$REP_TEST_REF n'est pas un répertoire ...\n";
      $REP_TEST_RUN_SIMPLE = "$REP_TEST/SIMPLE/$VERSION_DLIP/$TEST/ATP";
      ( -d $REP_TEST_RUN_SIMPLE) or die "$REP_TEST_RUN_SIMPLE n'est pas un répertoire ...\n";
      foreach my $FILE (`ls $REP_TEST_REF`){
	chomp $FILE;
	# Si un fichier existe dans le répertoire de run, on avertit l'operateur pour qu'il le supprime
	#(! -f "$REP_TEST_RUN_SIMPLE/$FILE")or die "$REP_TEST_RUN_SIMPLE/$FILE existe : supprimer le et relancer le script !\n";
	if($FILE =~ /\.conf/ || $FILE =~ /\.fim/ || $FILE =~ /\.fom/ || $FILE =~ /\.cfg/|| $FILE =~ /\.xhd/){
	  #print "$FILE\n";
	  system ("rm $REP_TEST_RUN_SIMPLE/$FILE");
	  print "rm $REP_TEST_RUN_SIMPLE/$FILE\n";
	  system("ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_SIMPLE/$FILE");
	  print "ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_SIMPLE/$FILE\n";
	}
      }
    }
  }
# Traitement des Tests COMMUNS SIMPLE/UMAT
  if($opt_c){
    print "\n****** Traitement des tests COMMUNS SIMPLE/UMAT \n";
    chdir("$REP_TEST_REF_COMM"); 
    foreach $TEST (`ls`){
      chomp $TEST;
      # Traitement du fichier xhd
      my $FILE_XHD = lc $TEST;
      $FILE_XHD = "$FILE_XHD.xhd";
      print "\n***** Traitement $TEST \n";
      $REP_TEST_REF = "$REP_TEST_REF_COMM/$TEST/ATP";
      ( -d $REP_TEST_REF) or die "$REP_TEST_REF n'est pas un répertoire ...\n";
      $REP_TEST_RUN_UMAT = "$REP_TEST/UMAT/$VERSION_DLIP/$TEST/ATP";      
      $REP_TEST_RUN_SIMPLE = "$REP_TEST/SIMPLE/$VERSION_DLIP/$TEST/ATP";
      ( -d $REP_TEST_RUN_UMAT) or die "$REP_TEST_RUN_UMAT n'est pas un répertoire ...\n";
      ( -d $REP_TEST_RUN_SIMPLE) or die "$REP_TEST_RUN_SIMPLE n'est pas un répertoire ...\n";
      foreach my $FILE (`ls $REP_TEST_REF`){
	chomp $FILE;
	(-f "$REP_TEST_REF/$FILE") or die "$REP_TEST_REF/$FILE n'est pas un fichier !\n";
	#print "**************** $FILE\n";
	if($FILE =~ /^$FILE_XHD$/){
	  # Test de la présence du fichier d'init dans le repert local
	  if(-f "$REP_TEST_REF/$NOM_FIC_INIT_UMAT"){
	    system("cat $REP_TEST_REF/$NOM_FIC_INIT_UMAT $REP_TEST_REF/$FILE > $REP_TEST_REF/UMAT_$FILE");
	    print "** mise à jour du test $TEST UMAT\n";
	    print "cat $REP_TEST_REF/$NOM_FIC_INIT_UMAT $REP_TEST_REF/$FILE > $REP_TEST_REF/UMAT_$FILE\n";
	  }
	  # Test de la presence du fichier d'init dans le repert commun
	  else{
	    if ( -f "$REP_FIC_COMM/$NOM_FIC_INIT_UMAT"){
	      # on le concatene avec le fichier C2_INIT_UMAT.xhd et on le recopie dans le répertoire de run
	      system("cat $REP_FIC_COMM/$NOM_FIC_INIT_UMAT $REP_TEST_REF/$FILE > $REP_TEST_REF/UMAT_$FILE");	      	      
	      print "cat $REP_FIC_COMM/$NOM_FIC_INIT_UMAT $REP_TEST_REF/$FILE > $REP_TEST_REF/UMAT_$FILE\n";	      
	    } 
	    else {
	      print "*** ERROR :$REP_TEST_REF/$FILE ou $REP_FIC_COMM/$NOM_FIC_INIT_UMAT n'existe pas...\n";
	      exit 1;
	    }
	  }
	  system("ln -s $REP_TEST_REF/UMAT_$FILE $REP_TEST_RUN_UMAT/$FILE");
	  print "ln -s $REP_TEST_REF/UMAT_$FILE $REP_TEST_RUN_UMAT/$FILE\n";
	  # Traitement test SIMPLE
	  #print "$REP_TEST_RUN_SIMPLE/$FILE\n";
       	  if(-f "$REP_TEST_REF/$NOM_FIC_INIT_SIMPLE"){
	   system("cat $REP_TEST_REF/$NOM_FIC_INIT_SIMPLE $REP_TEST_REF/$FILE > $REP_TEST_REF/SIMPLE_$FILE");
	    print"cat $REP_TEST_REF/$NOM_FIC_INIT_SIMPLE $REP_TEST_REF/$FILE > $REP_TEST_REF/SIMPLE_$FILE\n";
	  }
	  else {
	    # Test de la présence du fichier dans le répertoire de référence et du fichier d'init SIMPLE
	    # print "$REP_TEST_REF/$FILE $REP_FIC_COMM/$NOM_FIC_INIT_SIMPLE\n";
	    if( -f "$REP_FIC_COMM/$NOM_FIC_INIT_SIMPLE"){
	      # on le concatene avec le fichier C2_INIT_SIMPLE.xhd et on le recopie dans le répertoire de run
	      system("cat $REP_FIC_COMM/$NOM_FIC_INIT_SIMPLE $REP_TEST_REF/$FILE > $REP_TEST_REF/SIMPLE_$FILE");
	      print "cat $REP_FIC_COMM/$NOM_FIC_INIT_SIMPLE $REP_TEST_REF/$FILE > $REP_TEST_REF/SIMPLE_$FILE\n";
	      
	    }
	    else{
	       print "*** ERROR :$REP_TEST_REF/$FILE ou $REP_FIC_COMM/$NOM_FIC_INIT_SIMPLE n'existe pas...\n";
	      exit 1;
	     }
	  }
	  system("ln -s $REP_TEST_REF/SIMPLE_$FILE $REP_TEST_RUN_SIMPLE/$FILE");
	  print "ln -s $REP_TEST_REF/SIMPLE_$FILE $REP_TEST_RUN_SIMPLE/$FILE\n";
	}

	# Creation de lien sur les fichiers .conf, .fim, .fom, .cfg
	if($FILE =~ /\.conf/ || $FILE =~ /\.fim/ || $FILE =~ /\.fom/ || $FILE =~ /\.cfg/){
	  if(-f "$REP_TEST_RUN_UMAT/$FILE"){
	    system ("rm $REP_TEST_RUN_UMAT/$FILE");
	    print "rm $REP_TEST_RUN_UMAT/$FILE\n";
	  }
	  if(-f "$REP_TEST_RUN_SIMPLE/$FILE"){
	    system ("rm $REP_TEST_RUN_SIMPLE/$FILE");
	    print "rm $REP_TEST_RUN_SIMPLE/$FILE\n";
	  }
	  system("ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_UMAT/$FILE");
	  print "ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_UMAT/$FILE\n";
	  system("ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_SIMPLE/$FILE");
	  print "ln -s $REP_TEST_REF/$FILE $REP_TEST_RUN_SIMPLE/$FILE\n";
	  }
	}
      }
    }
exit 0;
  }
exit 0;
      



