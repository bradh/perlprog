#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : recopie régulière des fichiers de log du rack P0 sur la machine d'ou est lancé ce script
# Auteur : J-P. Coron
# Mis à jour : le 29/09/2008
# Description :

my $STOP_TEST = 0; # 0 : False, 1 : True
my $WAIT_BETWEEN_TWO_LS = 10; # Temps entre deux ls sur le rack 
my $DLIP_HOTE = "200.1.18.2"; # Nom du rack sur lequel on cherche les log
my $REP_RUN = "/rd1/RUN"; # Repertoire de RUN du rack
my $RSH_CMD = "rsh   $DLIP_HOTE -l root";
my $LS_CMD = "$RSH_CMD ls -l $REP_RUN"; # Recherche de tous les fichiers dans le répertoire $REP_RUN du rack $DLIP_HOTE
my @RES_CMD; # Résultat de la commande

#Nom des fichiers .log du rack :
my $SAMPT_LOG = "sampt_main.log";
my $SLP_LOG = "slp.log";
my $CPU_LOG = "cpu.log";

#Taille des fichiers .log du rack :
my $SIZE_SAMPT_LOG = 0;
my $SIZE_SLP_LOG = 0;
my $SIZE_CPU_LOG = 0;

#Fichiers log nouveaux sur rack ?
my $LOG_UPDATED = 0;



while ($STOP_TEST == 0)
   {
    @RES_CMD = (`$LS_CMD | grep .log`); #  Recherche de tous les fichiers .log dans le répertoire $REP_RUN du rack $DLIP_HOTE 
    print ("Resultat LS commande = \n @RES_CMD \n"); 
    
    
    foreach my $LIGNE (@RES_CMD) #Etude du résultat de la commande ligne par ligne 
       {
      	chomp ($LIGNE);
	#print"$LIGNE\n";
	@ELEMENTS_LIGNE = split(" ", $LIGNE);

	
	if ($ELEMENTS_LIGNE[7] eq $SAMPT_LOG) #Ligne contenant le sampt_main.log
	   {
	    if ($ELEMENTS_LIGNE[3] > $SIZE_SAMPT_LOG) #Verification de la taille sampt_main.log
	       {
	        $SIZE_SAMPT_LOG = $ELEMENTS_LIGNE[3]; #Si cette taille a augmentée, le log a été modifié
		print ("SIZE_SAMPT_LOG = $SIZE_SAMPT_LOG \n");
		$LOG_UPDATED = 1;
	       }
	    if ($ELEMENTS_LIGNE[3] < $SIZE_SAMPT_LOG) 
	       {
	        $STOP_TEST = 1; #Si cette taille a diminuée, le rack a été rebooté
	       }
	   }
	   
	if ($ELEMENTS_LIGNE[7] eq $SLP_LOG)
	   {
	    if ($ELEMENTS_LIGNE[3] > $SIZE_SLP_LOG) #Verification de la taille slp.log
	       {
	        $SIZE_SLP_LOG = $ELEMENTS_LIGNE[3]; #Si cette taille a augmentée, le log a été modifié
		print ("SIZE_SLP_LOG = $SIZE_SLP_LOG \n");
		$LOG_UPDATED = 1;
	       }
	    if ($ELEMENTS_LIGNE[3] < $SIZE_SLP_LOG) 
	       {
	        $STOP_TEST = 1; #Si cette taille a diminuée, le rack a été rebooté
	       }
	   }	   
	   
	if ($ELEMENTS_LIGNE[7] eq $CPU_LOG)
	   {
	    if ($ELEMENTS_LIGNE[3] > $SIZE_CPU_LOG) #Verification de la taille cpu.log
	       {
	        $SIZE_CPU_LOG = $ELEMENTS_LIGNE[3]; #Si cette taille a augmentée, le log a été modifié
		print ("SIZE_CPU_LOG = $SIZE_CPU_LOG \n");
		$LOG_UPDATED = 1;
	       }
	    if ($ELEMENTS_LIGNE[3] < $SIZE_CPU_LOG) 
	       {
	        $STOP_TEST = 1; #Si elle cette taille a diminuée, le rack a été rebooté
	       }
	   }	   
	   
	   
       }
       
       if ($LOG_UPDATED == 1) #Si le log a été modifié, alors on les recopie
          {
	   system("sampt_retrieve_log.pl -r 1 -c 1 -t T_NONC2_CAPA_MAX");
	   $LOG_UPDATED = 0;	    
	  }

	
       
       sleep ($WAIT_BETWEEN_TWO_LS);
	
   }

