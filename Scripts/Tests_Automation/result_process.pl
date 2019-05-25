#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 1/05/2007
# Description :

use Getopt::Std;

getopts("ht:");



if ($opt_h) { 
  print "result_process.pl -t <nom_du_test> : dans le répertoire de test traite les fichiers résultats\n";
  print "\t formatte les fichiers .xdh et .fim\n";
  print "\t supprime les messages techniques des .fim et des .xdh\n";
  print "\t commente le fom12  technique dans le .fom \n"; 
  exit(0);
}

if( ! $opt_h && $opt_t) {
	my $TestName = $opt_t;
	my $TestNameLc = lc  $TestName;
	if(-f "$TestNameLc.fim"){
		system("format2boctet.pl -f $TestNameLc.fim");
		system("remove_fom_technique.pl -f $TestNameLc.fim");
	}
	else {
		print "Impossible de trouver $TestNameLc.fim !\n";
	}
	if(-f "$TestNameLc.xdh"){
		system("format2boctet.pl -f   $TestNameLc.xdh");
		system("remove_xdh_technique.pl -f $TestNameLc.xdh");
	}
	else {
		print "Impossible de trouver $TestNameLc.xdh !\n";
	}
	if(-f "$TestNameLc.fom" && ! -f "$TestNameLc.fom.bak"){
		system("format2boctet.pl -f $TestNameLc.fom");
		system("remove_fom_technique.pl -f $TestNameLc.fom");
		print "Attention, recopier le .fom.bak dans le .fom après analyse !\n";
	}
	else {
		print "Impossible de trouver $TestNameLc.fom! ou $TestNameLc.fom.bak exite deja ! \n";
	}
	system("compas");
exit 0;
}

