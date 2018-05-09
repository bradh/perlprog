#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hlc:v:t:");

my $VERSION_DLIP = "SAMPT_V4";

my @NOM_PROCESS ;
my $REP_TEST = "/free2/samptivq/tests";
my $REP_TEST_CONFIG1 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG2 = "$REP_TEST/C2/UMAT";
my $REP_TEST_CONFIG3 = "$REP_TEST/C2/SIMPLE";
my $REP_TEST_CONFIG4 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG5 = "$REP_TEST/NON_C2/UMAT";
my $REP_TEST_CONFIG6 = "$REP_TEST/NON_C2/SIMPLE";

if ($opt_h) { 
	print "$1 [-h] [-c 1 à 9] [-v nom_version] : update l'environnement de test de la version \n";
	print "mets à jour l'environnement de test à jour dans le cadre du passage des tests de l'environnement\n";
	print "sous /h7_usr/sil2_usr/samptivq/tests à l'environnement sur le disque dur de SMARTHA01 sous /free2/samptivq/tests\n";
	print "en particulier les liens des fichiers d'entrée deviennent relatif\n";
	print "ils point également vers un rertoire generique reference_ATP au lieu de reference_ATP_V5\n";
	print "le repertoire reference_ATP est un lien version la reference en cours \n";

}

# Si toutes les options sont definies

if( ! $opt_h && $opt_c && $opt_v) {
# Definir la version du DLIP (par defaut $VERSION_DLIP)
	my $VERSION = $VERSION_DLIP;
	$VERSION = "$opt_v";


# Definir le repertoire de test ATR et ATP
	my $CONFIG_TEST = $opt_c;
	if ( $CONFIG_TEST > 9) {
		print "Erreur choix configuration de test...\n";
	}
	if ($CONFIG_TEST > 6 && $CONFIG_TEST < 10) {
		$CONFIG_TEST = $CONFIG_TEST-3;
	}

	$REP_CONFIG = "$REP_TEST_CONFIG1/$VERSION" if ($CONFIG_TEST == 1);
	$REP_CONFIG = "$REP_TEST_CONFIG2/$VERSION" if ($CONFIG_TEST == 2);
	$REP_CONFIG = "$REP_TEST_CONFIG3/$VERSION" if ($CONFIG_TEST == 3);
	$REP_CONFIG = "$REP_TEST_CONFIG4/$VERSION" if ($CONFIG_TEST == 4);
	$REP_CONFIG = "$REP_TEST_CONFIG5/$VERSION" if ($CONFIG_TEST == 5);
	$REP_CONFIG = "$REP_TEST_CONFIG6/$VERSION" if ($CONFIG_TEST == 6);
	print "$REP_CONFIG\n";


	print "# Liste des tests à mettre à jour \n";
	opendir(DIR, "$REP_CONFIG") or die "Impossible ouvrir rep $REP_CONFIG...\n";
	my @TEST = grep {   ! /^\./ && -d "$REP_CONFIG/$_" }readdir (DIR);
	foreach $TEST (@TEST){
		chdir("$REP_CONFIG");
		print "$TEST\n";
		print "# liste des fichiers à mettre à jour...\n";
		opendir(DIR2, "$REP_CONFIG/$TEST/ATP") or die "Impossible ouvrir $REP_CONFIG/$TEST/ATP ... \n";
		my @File = grep { -l "$REP_CONFIG/$TEST/ATP/$_"} readdir(DIR2);
		foreach $File(@File) {
			chdir("$TEST/ATP");
			my $Link = `ls -l $File`;
			$Link = (split (" ", $Link))[10];
			# Mettre à jour le lien si lien non relatif
			my $LinkNew = $Link;
			$LinkNew =~ s/\/h7_usr\/sil2_usr\/samptivq\/tests\/C2/..\/..\/..\/../;
			$LinkNew =~ s/\/h7_usr\/sil2_usr\/samptivq\/tests\/NONC2/..\/..\/..\/../;
			$LinkNew =~ s/\/free2\/samptivq\/tests\/C2/..\/..\/..\/../;
			$LinkNew =~ s/\/free2\/sil2_usr\/samptivq\/tests\/NONC2/..\/..\/..\/../;
			$LinkNew =~ s/reference_ATP_V4/reference_ATP/;

			$Dir = `pwd`;
			print "$Dir \n";
			print "file $File\n";
			print "old link $Link\n";
			print "new link $LinkNew\n";
			# Supprimer le lien 
			system("rm -f $File");
			# Recreer le lien
			system("ln -s $LinkNew $File");
		}
		close DIR2;
	}
	close DIR;
}
exit 0;
