#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hc:t:us");
my @EXE_LIST = ("DLIP", "SNCP", "SLP", "RECORDER");
my @NOM_PROCESS;
my $REP_EXE = "/hd2/TEST_ENV";
my $REP_C2 = "C2";
my $REP_NONC2 = "NONC2";
my $REP_SIMPLE = "SIMPLE";
my $REP_UMAT = "UMAT";
my $REP_RUN = "/rd1/RUN"; # répertoire du test
my $DLIP_HOTE = "200.1.18.2";
my $RSH_CMD = "rsh $DLIP_HOTE -l root";

# Tire un lien sur les executables et copie les fichiers de conf
sub link_exe() {
    	for my $EXE  (@EXE_LIST) {
      		print "$EXE\n";
		for $FILE (`$RSH_CMD ls  $REP_EXE/$EXE`) {
	  		chomp($FILE);
	    		print "Copie de $REP_RUN/$FILE\n";
	    		system("$RSH_CMD cp $REP_EXE/$EXE/$FILE $REP_RUN");
		}     
    	}
    	return 0;
}


if ($opt_h) { 
	print "sampt_init.pl [-h] [-c] [-u] [-t config_test]: init du repertoire de run  \n";
	print " config_test : T_Standard (par defaut) ou T_Traversee\n";
	print "exemple 1 : sampt_init.pl -c 1 -s -t: init du repertoire de run en config nonC2 SIMPLE \n";
	print "exemple 2 : sampt_init.pl -c 2 -u: init du repertoire de run en config C2 UMAT  \n";
	exit 0;
}

if( ! $opt_h && $opt_c && ($opt_u || $opt_s)) {
	my $CONFIG_TEST = "T_Standard";
	if($opt_t){
		$CONFIG_TEST = "$opt_t";
	}
	system("$RSH_CMD rm -fr $REP_RUN");
	system("$RSH_CMD rmdir $REP_RUN");
	if($opt_c == 2){
		if($opt_u){
			$REP_EXE="$REP_EXE/$REP_C2/$REP_UMAT";
		}
		if($opt_s) {
			$REP_EXE="$REP_EXE/$REP_C2/$REP_SIMPLE";
		}
	}
	if($opt_c != 2){
		if($opt_u){
			$REP_EXE="$REP_EXE/$REP_NONC2/$REP_UMAT";
		}
		if($opt_s) {
			$REP_EXE="$REP_EXE/$REP_NONC2/$REP_SIMPLE";
		}
	}
	print "From $REP_EXE to $REP_RUN\n";
	system("$RSH_CMD mkdir $REP_RUN");
    	link_exe();
}
else {
	print "erreur dans les options choisies...\n";
} 
exit 0;


