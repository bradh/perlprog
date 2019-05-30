#!/usr/bin/perl -w
# Balaye l'arborescence de test pour un traitement de celui ci
# toto

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hd:");
if($opt_h) {
	print "usage $0 [-d nom du repertoire]\n";
	print "template permettant un traitement dans tous les repertoires de test\n";
	print "Si le repertoire n'est pas passé en parametre, on utilise le repertoire local\n";
	exit 0;
}
my $ROOT_DIR;
my $NOM_TEST;
# Si le repertoire n'est pas passé en parametre, on utilise le repertoire local
if(defined $opt_d) {
	$ROOT_DIR = $opt_d;
}
else{
	$ROOT_DIR = $ENV{'PWD'};
}

(-d $ROOT_DIR) or die "$ROOT_DIR n'est pas un repertoire !";
chdir($ROOT_DIR);
print "Processing... $ROOT_DIR\n";
#exit 0;

opendir FIN, "$ROOT_DIR" or die "Impossible ouvrir $ROOT_DIR !";
	my (@DIR) = readdir FIN;
	foreach $NOM_TEST (@DIR){
		if ( -d "$ROOT_DIR/$NOM_TEST" && $NOM_TEST !~ /^\./ ){
			print "running $ARGV[0]\n";
			#exit 0;
			chdir($NOM_TEST);
			print "\tprocessing $NOM_TEST...\n"; 
			# rajouter ici le traitement à faire 
			system("$ARGV[0]");	
			chdir($ROOT_DIR);
		}
	}
close FIN;
exit 0;






