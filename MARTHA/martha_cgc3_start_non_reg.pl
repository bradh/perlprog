#!/usr/bin/perl -w
# Balaye l'arborescence de test pour un traitement de celui ci
# lance le run
# lance le check
# fait la sauvegarde
# edite la synthèse sous la forme 
# Nom du test : OK/KO

###################################################################################
##################################################################################

use Getopt::Std;
# recoit en argument le nom du fichier listant les tests à passer
# le nom de la version
getopts("hrcsd:f:v:");
if($opt_h) {
	print "usage $0 [-d nom du repertoire root]\n";
	print "-f <non reg file name> -v <version> -r si run -c si check -s si save\n";
	print "template permettant un traitement dans tous les repertoires de test\n";
	print "Si le repertoire n'est pas passé en parametre, on utilise le repertoire local\n";
	exit 0;
}

my $ROOT_DIR = "/h7_usr/sil2_usr/marthivq/MARTHA_CGC3" ;
my $TEST_DIR = "$ROOT_DIR/C2/TESTS_CGC3_PEU/build2";
my $TEST_LIST_DIR = "$ROOT_DIR/non_reg_result";
my $TEST_LIST_FILE = "test_list.txt";
my $NON_REG_RESULT_DIR = "$ROOT_DIR/non_reg_result";
my $NON_REG_RESULT_FILE = "non_reg_result.log";
my $TEST_NAME;
my $NON_REG_VERSION = "UNKNOWN";
my $DURATION_TEST;
my $TYPE_TEST;
my $TEST_RESULT;
my $nonRegResult = "OK";

# Si le repertoire n'est pas passé en parametre, on utilise le repertoire local
if(defined $opt_d) {
	$ROOT_DIR = $opt_d;
}
if(defined $opt_f){
	$TEST_LIST_FILE = $opt_f;
}
if(defined $opt_v){
	$NON_REG_VERSION = $opt_v;
}

# initialisation de la liste de test 
my @TEST_LIST;
getTestList();
open Fout, "> $NON_REG_RESULT_DIR/$NON_REG_RESULT_FILE" or die " $NON_REG_RESULT_DIR/$NON_REG_RESULT_FILE could not created...";
close Fout;
printResult("running MARTHA CGC3 non reg version $NON_REG_VERSION");
startNonReg();
exit 0;

sub startNonReg {
	foreach my $r_test (@TEST_LIST) {			
		my $testName = $r_test->{'Name'};
		my $duration = $r_test->{'Duration'};
		my $type     = $r_test->{'Type'};
		print "Processing $testName ...\n";	
		printResult("Processing $testName...");
		chdir("$TEST_DIR/$testName") or die "$ROOT_DIR/$TEST_DIR/$testName could not be find...";	
		my $result = `martha_run_test.sh $duration` if ( defined $opt_r );
		$result = system("martha_check_test.sh") if ( $type =~ /F/ && defined $opt_c );
		$result = system("martha_check_perfo.sh") if ( $type =~ /P/ && defined $opt_c);
		print "$result\n";
		$testResult = "$testName : OK";
		if ( $result == 0 ) {
		}
		else {
			$testResult = "KO";
			$nonRegResult = "KO";
		}
		printResult("$testName : $testResult");
		system(	"martha_save_test.sh"	)if( defined $opt_s );
	}
	printResult("MARTHA CGC3 non reg terminate !");
	printResult("MARTHA CGC3 non reg : $nonRegResult");
}

sub getTestList {
	open Fin, "< $TEST_LIST_DIR/$TEST_LIST_FILE" or die "$TEST_LIST_DIR/$TEST_LIST_FILE doesnot exist ! \n";	
	while(<Fin>){
		my $line = $_;
		chomp $line;
		my ( $test, $duration, $type ) = split( ":", $line );
		print "$TEST_LIST_DIR/$TEST_LIST_FILE, $test, $duration\n";
		push @TEST_LIST,
		  {
			'Name'     => $test,
			'Duration' => $duration,
			'Type'     => $type
		  };
	}
	close Fin;
}

sub printResult {
	my $line = shift;
	open Fout, ">> $NON_REG_RESULT_DIR/$NON_REG_RESULT_FILE" or die " $NON_REG_RESULT_DIR/$NON_REG_RESULT_FILE coud be opened ...";
	print Fout $line ."\n";
	return;
}
