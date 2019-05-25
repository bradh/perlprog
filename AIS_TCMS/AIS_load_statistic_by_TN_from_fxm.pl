#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : mesure du temps de traversée
# Auteur : S. Mouchot
# Mis à jour : le 23/05/2006
# Description :
# le script extrait du fichier .fim d'entree dans un fichier texte $RESULT_FILE
# contenant les infos suivantes dans les fichiers texte correspondants :
# exemple :
# pour les j3_0
# 00:24:51.993 PLAT_0003
# pour les j3_2
# 00:24:51.993 IFF_0033
# pour les j3_7
# 00:25:00.192 ID_0000
# La valeur de l'IFF est affichée en octal

use Getopt::Std;



getopts("hb:");

if ($opt_h) { 
  print "extract_TN_date_from_fim.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h ) {
	my $NBER_LOOP_MAX = 64;
	$NBER_LOOP_MAX = $opt_b if($opt_b);
	system ("rm -fr statisticTargetFxm.cvs");
	my $boucle = 0;
	while ($boucle < $NBER_LOOP_MAX){
		print "Traitement boucle : $boucle \n";
		# récupération du ficher snoop
		#system ("rename fxm.pcap fxm$boucle.cap");
		# conversion du fichier snoop en ficheir tcpdump
		my $fichierSnoop = "fxm$boucle.pcap";
		my $fichierTcpdump = "fxm.pcap";
		system("editcap -F pcap $fichierSnoop $fichierTcpdump");
		# tcpdump2aladdin du fichier tcpdump
		print "perl tcpdump2Aladdin_online_V5_3.pl\n";
		system("perl tcpdump2Aladdin_online_V5_3.pl");
		system("mv fxm.pcap fxm-$boucle.pcap");
		system("mv scenario_fxm.fim scenario_fxm-$boucle.fim");
		system("mv scenario_fxm.fom scenario_fxm-$boucle.fom");
		# analyse des fichiers fim et fom
		print "perl statistic_by_TN_from_fxm.pl -f scenario_fxm-$boucle -b $boucle \n";
		system ("perl statistic_by_TN_from_fxm.pl -f scenario_fxm-$boucle -b $boucle");
		$boucle = $boucle + 1;
	}
}

print "That's all folk !\n";
exit 0;
