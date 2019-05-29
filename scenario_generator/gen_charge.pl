#!/usr/bin/perl
# gen_charge permet ...
# Mise a jour le 8 octobre 2002 par S. Mouchot

use Getopt::Std;
use lib qw(../lib);

use aladdin_AHD101;
use aladdin_AHD106;
use aladdin_AHD121;
use aladdin_FIM01_J3_2_I_E0_C1;
use aladdin_FIM01_J3_7;
use aladdin_FIM01_J3_6;
use aladdin_FIM01_J7_0;
use BIM;
use Conversion;

getopts("hd:i:f:n:o:p:r:t:z:");

#my $BASE_DIR = "/data/users/loc1int/scenario_generator";
my $BASE_DIR = "D:\\Users\\t0028369\\Documents\\Mes outils personnels\\perlprog\\scenario_generator";
#my $BASE_DIR = "/home/stephane/Informatique/perlprog_repo/perlprog/scenario_generator";

my $BIBLIO_DIR = "Bibliotheque";


# print $ENV{PWD};
if (defined $opt_h) { 
		print "usage gen_charge.pl [-i nom_fichier_init] [-f nom_fichier_sortie] [-n nombre_de_pistes] [-r nombre_repetitions] [-t delta_t_en_s] [-o T0 en secondes][-z firsSysTN]\n";
	print "gen_charge.pl genere dun fichier au format .xhd contenant nombre_de_piste espacee de delta_t en ms\n";
	exit(0);
}
# Projet
my $PROJECT = "SAMPT";

# lecture du nom du test
my $TEST_NAME = "T_C2_PS-13935_SIMPLE_ENDURANCE";
$TEST_NAME = $opt_d if($opt_d);
my $TEST_DIR = "$TEST_NAME";

# fichier de sortie intermediaire
my $fichierTemp = "temp.xhd";
my $fichierTempFim = "temp.fim";
my $fichierTempBim = "temp.bim";
# fichier de sortie final
my $fichierOutput = "$TEST_NAME.xhd";
if($opt_f) {$fichierOutput = "$opt_f";}
print "$fichierOutput\n";


# Definition du scenario
# Duree du scenario
my $scenario_duration = 60;

# sysTN
my $scenario_first_sysTN = 10;
$scenario_first_sysTN = $opt_z if($opt_z);
my $scenario_current_sysTN = $scenario_first_sysTN;
my $scenario_max_used_sysTN = $scenario_first_sysTN;

# Definition de la sequence 1
# heure de demarrage en seconde
my $sequence_T0 = 5;
$sequence_T0= $opt_o if(defined $opt_o);

# AHD101
# lecture du fichier d'entree (template)
my $AHD101_template_file = "AHD101.xhd";
# nombre de pistes generees
my $ahd101_track_number = 50;
$ahd101_track_number = $opt_n if(defined $opt_n);
# track period en second
my $ahd101_track_period = 1;
# nombre de repetition des pistes
my $ahd101_track_recurrence_nber = 45;
$ahd101_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $ahd101_track_interval = 20; 
$ahd101_track_interval = $opt_t if(defined $opt_t);
# delta lattitude en element binaire
my $deltaLat = 1000000;
my $lat0 = hex("22222221");
# delta longitude
my $deltaLong = 1000000;
my $long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

# AHD106
# lecture du fichier d'entree (template)
my $AHD106_template_file = "AHD106.xhd";
# nombre de pistes generees
my $ahd106_track_number = 2;
$ahd106_track_number = $opt_n if(defined $opt_n);
# track period en second
my $ahd106_track_period = 1;
# nombre de repetition des pistes
my $ahd106_track_recurrence_nber = 45;
$ahd106_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $ahd106_track_interval = 500; 
$ahd106_track_interval = $opt_t if(defined $opt_t);




open Fout, ">$BASE_DIR/$fichierTemp" or die "impossible d'ouvrir le fichier de sortie $fichierTemp";

# Processing 3D Air Tracks
my $ahd101_template = get_template($AHD101_template_file);
my $current_time = get_message_time($ahd101_template);
print "time : $current_time\n" if($debug ==1);
my $current_chrono = Conversion::timeToChrono($current_time);
$current_chrono += $sequence_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";


# Creation de la sequence 1
my $r_AHD101_message = aladdin_AHD101::new(\$ahd101_template);
#print "$$r_AHD101_message\n";
my $first_message_chrono = $current_chrono;
my $first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $ahd101_track_recurrence_nber;){	
	$scenario_max_used_sysTN = $scenario_current_sysTN if($scenario_current_sysTN > $scenario_max_used_sysTN );
	$scenario_current_sysTN = $scenario_first_sysTN;
	#print "$scenario_current_sysTN, $scenario_max_used_sysTN\n";
	for (my $track = 0; $track < $ahd101_track_number; ) {
		$r_AHD101_message->setSysTN($scenario_current_sysTN);
		$r_AHD101_message->addTime($current_time);
		print "after $$r_AHD101_message\n";
		print Fout "$$r_AHD101_message\n";
		$scenario_current_sysTN += 1;
		$current_chrono += $ahd101_track_interval/1000;
		$current_time = Conversion::toTime($current_chrono);
		print "by tracks chrono , time : $current_chrono, $current_time\n ";
		$track += 1;
		#exit 0;	
	}
	# incrementation 
	$first_message_chrono +=  $ahd101_track_period;
	$current_chrono = $first_message_chrono;
	print "rec chrono $current_chrono\n";
	$current_time = Conversion::toTime($current_chrono);
	print "rec time $current_time\n";	
	$recurrence += 1;
}


# Processing 2D FIX ESM
my $ahd106_template = get_template($AHD106_template_file);
print "$ahd106_template\n";
$current_time = get_message_time($ahd106_template);
print "time : $current_time\n";
$current_chrono = Conversion::timeToChrono($current_time);
$current_chrono += $sequence_T0;
print "chrono $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);

# Creation de la sequence 1 2D
my $r_AHD106_message = aladdin_AHD106::new(\$ahd106_template);
print "$$r_AHD106_message\n";

$scenario_current_sysTN = $scenario_max_used_sysTN;
my  $scenario_first_adh106_sysTN = $scenario_max_used_sysTN;
print "first 106 sysTN : $scenario_first_adh106_sysTN\n";

$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $ahd106_track_recurrence_nber;){
	$scenario_max_used_sysTN = $scenario_current_sysTN if($scenario_current_sysTN > $scenario_max_used_sysTN );
	$scenario_current_sysTN = $scenario_first_adh106_sysTN;
	print "$scenario_current_sysTN, $scenario_max_used_sysTN\n";
	for (my $track = 0; $track < $ahd106_track_number; ) {
		$r_AHD106_message->setSysTN($scenario_current_sysTN);
		$r_AHD106_message->addTime($current_time);
		#print "after $$r_AHD106_message\n";
		print Fout "$$r_AHD106_message\n";
		$scenario_current_sysTN += 1;
		$current_chrono += $ahd106_track_interval/1000;
		$current_time = Conversion::toTime($current_chrono);
		$track += 1;
	}
	# incrementation 
	$first_message_chrono += $ahd106_track_period;
	$current_chrono = $first_message_chrono;
	$current_time = Conversion::toTime($current_chrono);
	print "rec chrono $current_chrono\n";
	print "rec time $current_time\n";	
		
	$recurrence += 1;
		
}

# Definition sequence 2
my $sequence2_T0 = 55;
my $drop_interval = 50;
$scenario_current_sysTN = $scenario_first_sysTN;
my $AHD121_template_file  = "AHD121.xhd";
my $AHD121_template = get_template($AHD121_template_file);

$current_time = get_message_time($AHD121_template);
$current_chrono = Conversion::timeToChrono($current_time);
$current_chrono += $sequence2_T0;
print "chrono $current_chrono\n";

$current_time = Conversion::toTime($current_chrono);
print "time $current_time\n";

# Creation de la sequence 1
my $r_AHD121_message = aladdin_AHD121::new(\$AHD121_template);
print "$$r_AHD121_message\n";
for (my $track = 0; $track < $ahd101_track_number + $ahd106_track_number; ) {
	$r_AHD121_message->setSysTN($scenario_current_sysTN);
	$r_AHD121_message->addTime($current_time);
	print "after $$r_AHD121_message\n";
	print Fout "$$r_AHD121_message\n";
	$scenario_current_sysTN += 1;
	$current_chrono += $drop_interval/1000;
	$current_time = Conversion::toTime($current_chrono);
	$track += 1;
}
# Ajout d'une sequence 3 free text à 00:00:30 
my $sequence3_T0 = 30;
my $AHD200_template_file  = "AHD200.xhd";
open Fin, "< $BASE_DIR/$BIBLIO_DIR/$PROJECT/$AHD200_template_file" or die "impossible open $AHD200_template_file";
my $AHD200_template = <Fin>;
chomp $AHD200_template;
my @AHD200 = split " ",$AHD200_template;
#print "@AHD200";

$current_chrono = $sequence3_T0;
$current_time = Conversion::toTime($current_chrono);
print "time $current_time\n";

# Creation de la sequence 1
$AHD200_template =~ s/^(\d{2}:\d{2}:\d{2}\.\d{3})/$current_time/;
print $AHD200_template . "\n";
print Fout $AHD200_template . "\n";
	
close Fout;

#############################################################
# Scenario reseau
#############################################################
open Fout, ">$BASE_DIR/$fichierTempFim" or die "impossible d'ouvrir le fichier de sortie $fichierTemp";
open Fout2, ">$BASE_DIR/$fichierTempBim" or die "impossible d'ouvrir le fichier de sortie $fichierTemp";
# Definition de la  remote sequence 1
# heure de demarrage en seconde
my $remote_sequence1_T0 = 4;

# J2.2
# lecture du fichier d'entree (template)
my $j2_2_template_file = "FIM01_J2_2.fim";
# nombre de pistes generees
my $j2_2_track_number = 50;
#$j2_2_track_number = $opt_n if(defined $opt_n);
# track period en second
my $j2_2_track_period = 12;
# nombre de repetition des pistes
my $j2_2_track_recurrence_nber = 4;
#$ahd101_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $j2_2_track_interval = 50; 
$ahd101_track_interval = $opt_t if(defined $opt_t);
# delta lattitude en element binaire
$deltaLat = 1000000;
$lat0 = hex("22222221");
# delta longitude
$deltaLong = 1000000;
$long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

my $FIM01_J2_2_template = get_template($j2_2_template_file);
print "J2_2 template 1 : $FIM01_J2_2_template\n";

#reinitialisation du current time et current chrono
$current_chrono = $remote_sequence1_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";

# Creation de la sequence 1

$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $j2_2_track_recurrence_nber;){	
	$FIM01_J2_2_template =~ s/^(\d{2}:\d{2}:\d{2}\.\d{3})/$current_time/;
	$FIM01_J2_2_template =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s?(\d{8})\s?(\d{8})\s?(.*)/;
	my $BIM01_header = BIM::getBIM01Header(3);
	my $length = hex($2) + 2;
	$length = sprintf("%08X", $length);
	print "BIM : $1 $length $3 $BIM01_header $4\n";
	print Fout2 "$1 $length $3 $BIM01_header $4\n";
	print "FIM : $FIM01_J2_2_template\n";
	print Fout "$FIM01_J2_2_template\n";		

	# incrementation 
	$first_message_chrono +=  $j2_2_track_period;
	$current_chrono = $first_message_chrono;
	print "rec chrono $current_chrono\n";
	$current_time = Conversion::toTime($current_chrono);
	print "rec time $current_time\n";	
	$recurrence += 1;
}

# Sequence 2 : J3.2

my $remote_sequence2_T0 = 5;

# lecture du fichier d'entree (template)
my $j3_2_template_file = "FIM01_J3_2_I_E0_C1.fim";
# STN des pistes remote
my $j3_2_STN = 9; # en decimal
# nombre de pistes generees
my $j3_2_track_number = 50;
#$j3_2_track_number = $opt_n if(defined $opt_n);
# track period en second
my $j3_2_track_period = 12;
# nombre de repetition des pistes
my $j3_2_track_recurrence_nber = 4;
#$ahd101_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $j3_2_track_interval = 50; 
$ahd101_track_interval = $opt_t if(defined $opt_t);
# delta lattitude en element binaire
$deltaLat = 1000000;
$lat0 = hex("22222221");
# delta longitude
$deltaLong = 1000000;
$long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

my $FIM01_J3_2_I_E0_C1_template = get_template($j3_2_template_file);
my $r_FIM01_J3_2_I_E0_C1_message = aladdin_FIM01_J3_2_I_E0_C1::new(\$FIM01_J3_2_I_E0_C1_template);
#print "$$r_FIM01_J3_2_I_E0_C1_message\n";

#reinitialisation du current time et current chrono
$current_chrono = $remote_sequence2_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";
$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

# Creation de la sequence 1
# LTN
my $scenario_first_LTN = 1001;
my $scenario_current_LTN = $scenario_first_LTN;
my $scenario_max_used_LTN = $scenario_first_LTN;

$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $j3_2_track_recurrence_nber;){	
	$scenario_max_used_LTN = $scenario_current_LTN if($scenario_current_LTN > $scenario_max_used_LTN );
	$scenario_current_LTN = $scenario_first_LTN;
	#print "$scenario_current_LTN, $scenario_max_used_LTN\n";
	for (my $track = 0; $track < $j3_2_track_number; ) {
		$r_FIM01_J3_2_I_E0_C1_message->setSTN($j3_2_STN);
		my $message = $r_FIM01_J3_2_I_E0_C1_message->get_FIM01_J3_2_I_E0_C1();
		$r_FIM01_J3_2_I_E0_C1_message->setLTN($scenario_current_LTN);
		$message = $r_FIM01_J3_2_I_E0_C1_message->get_FIM01_J3_2_I_E0_C1();
		$r_FIM01_J3_2_I_E0_C1_message->addTime($current_time);
		$message = $r_FIM01_J3_2_I_E0_C1_message->get_FIM01_J3_2_I_E0_C1();
		$message =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s?(\d{8})\s?(\d{8})\s?(.*)/;
		my $BIM01_header = BIM::getBIM01Header(3);
		my $length = hex($2) + 2;
		$length = sprintf("%08X", $length);
		print "BIM : $1 $length $3 $BIM01_header $4\n";
		print Fout2 "$1 $length $3 $BIM01_header $4\n";
		print "FIM : $message\n";
		print Fout "$message\n";
		$scenario_current_LTN += 1;
		$current_chrono += $j3_2_track_interval/1000;
		$current_time = Conversion::toTime($current_chrono);
		print "by tracks chrono , time : $current_chrono, $current_time\n ";
		$track += 1;
	}
	# incrementation 
	$first_message_chrono +=  $j3_2_track_period;
	$current_chrono = $first_message_chrono;
	print "rec chrono $current_chrono\n";
	$current_time = Conversion::toTime($current_chrono);
	print "rec time $current_time\n";	
	$recurrence += 1;
}
# Sequence 3 J3.7

my $remote_sequence3_T0 = 6;

# lecture du fichier d'entree (template)
my $j3_7_template_file = "FIM01_J3_7.fim";
# STN des pistes remote
my $j3_7_STN = 9; # en decimal
# nombre de pistes generees
my $j3_7_track_number = 4;
#$j3_7_track_number = $opt_n if(defined $opt_n);
# track period en second
my $j3_7_track_period = 12;
# nombre de repetition des pistes
my $j3_7_track_recurrence_nber = 4;
#$ahd101_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $j3_7_track_interval = 200; 
$ahd101_track_interval = $opt_t if(defined $opt_t);
# delta lattitude en element binaire
$deltaLat = 1000000;
$lat0 = hex("22222221");
# delta longitude
$deltaLong = 1000000;
$long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

my $FIM01_j3_7_template = get_template($j3_7_template_file);
my $r_FIM01_j3_7_message = aladdin_FIM01_J3_7::new(\$FIM01_j3_7_template);
#print "$$r_FIM01_j3_7_message\n";

#reinitialisation du current time et current chrono
$current_chrono = $remote_sequence3_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";
$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

# Creation de la sequence 1
# LTN
my $j3_7_first_LTN = $scenario_current_LTN;

$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $j3_7_track_recurrence_nber;){	
	$scenario_max_used_LTN = $scenario_current_LTN if($scenario_current_LTN > $scenario_max_used_LTN );
	$scenario_current_LTN = $j3_7_first_LTN;
	#print "$scenario_current_LTN, $scenario_max_used_LTN\n";
	for (my $track = 0; $track < $j3_7_track_number; ) {
		$r_FIM01_j3_7_message->setSTN($j3_7_STN);
		my $message = $r_FIM01_j3_7_message->get_FIM01_J3_7();
		$r_FIM01_j3_7_message->setLTN($scenario_current_LTN);
		$message = $r_FIM01_j3_7_message->get_FIM01_J3_7();
		$r_FIM01_j3_7_message->addTime($current_time);
		$message = $r_FIM01_j3_7_message->get_FIM01_J3_7();
		$message =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s?(\d{8})\s?(\d{8})\s?(.*)/;
		my $BIM01_header = BIM::getBIM01Header(6);
		my $length = hex($2) + 2;
		$length = sprintf("%08X", $length);
		print "BIM : $1 $length $3 $BIM01_header $4\n";
		print Fout2 "$1 $length $3 $BIM01_header $4\n";
		print "FIM : $message\n";
		print Fout "$message\n";
		$scenario_current_LTN += 1;
		$current_chrono += $j3_7_track_interval/1000;
		$current_time = Conversion::toTime($current_chrono);
		print "by tracks chrono , time : $current_chrono, $current_time\n ";
		$track += 1;
	}
	# incrementation 
	$first_message_chrono +=  $j3_7_track_period;
	$current_chrono = $first_message_chrono;
	print "rec chrono $current_chrono\n";
	$current_time = Conversion::toTime($current_chrono);
	print "rec time $current_time\n";	
	$recurrence += 1;
}
# Sequence 4 J3.6

my $remote_sequence4_T0 = 7;

# lecture du fichier d'entree (template)
my $j3_6_template_file = "FIM01_j3_6_state_only.fim";
# STN des pistes remote
my $j3_6_STN = 9; # en decimal
# nombre de pistes generees
my $j3_6_track_number = 4;
#$j3_6_track_number = $opt_n if(defined $opt_n);
# track period en second
my $j3_6_track_period = 12;
# nombre de repetition des pistes
my $j3_6_track_recurrence_nber = 4;
#$ahd101_track_recurrence_nber = $opt_r if(defined $opt_r);
# Intervalle entre messages en ms
my $j3_6_track_interval = 200; 
$ahd101_track_interval = $opt_t if(defined $opt_t);
# delta lattitude en element binaire
$deltaLat = 1000000;
$lat0 = hex("22222221");
# delta longitude
$deltaLong = 1000000;
$long0 = hex("FFFFF4A3");
#print "long0 = $long0 \n";

my $FIM01_j3_6_template = get_template($j3_6_template_file);
my $r_FIM01_j3_6_message = aladdin_FIM01_J3_6::new(\$FIM01_j3_6_template);
#print "$$r_FIM01_j3_6_message\n";

#reinitialisation du current time et current chrono
$current_chrono = $remote_sequence4_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";
$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

# Creation de la sequence 1
# LTN
my $j3_6_first_LTN = $scenario_current_LTN;

$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

for (my $recurrence = 0; $recurrence < $j3_6_track_recurrence_nber;){	
	$scenario_max_used_LTN = $scenario_current_LTN if($scenario_current_LTN > $scenario_max_used_LTN );
	$scenario_current_LTN = $j3_6_first_LTN;
	#print "$scenario_current_LTN, $scenario_max_used_LTN\n";
	for (my $track = 0; $track < $j3_6_track_number; ) {
		$r_FIM01_j3_6_message->setSTN($j3_6_STN);
		my $message = $r_FIM01_j3_6_message->get_FIM01_J3_6();
		$r_FIM01_j3_6_message->setLTN($scenario_current_LTN);
		$message = $r_FIM01_j3_6_message->get_FIM01_J3_6();
		$r_FIM01_j3_6_message->addTime($current_time);
		$message = $r_FIM01_j3_6_message->get_FIM01_J3_6();
		$message =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s?(\d{8})\s?(\d{8})\s?(.*)/;
		my $BIM01_header = BIM::getBIM01Header(3);
		my $length = hex($2) + 2;
		$length = sprintf("%08X", $length);
		print "BIM : $1 $length $3 $BIM01_header $4\n";
		print Fout2 "$1 $length $3 $BIM01_header $4\n";
		print "FIM : $message\n";
		print Fout "$message\n";
		$scenario_current_LTN += 1;
		$current_chrono += $j3_6_track_interval/1000;
		$current_time = Conversion::toTime($current_chrono);
		print "by tracks chrono , time : $current_chrono, $current_time\n ";
		$track += 1;
	}
	# incrementation 
	$first_message_chrono +=  $j3_6_track_period;
	$current_chrono = $first_message_chrono;
	print "rec chrono $current_chrono\n";
	$current_time = Conversion::toTime($current_chrono);
	print "rec time $current_time\n";	
	$recurrence += 1;
}
# Sequence 5 J3.0 LP
# Sequence 6 J3.0 IP
# Sequence 7 J7.0 drop des pistes remote

my $remote_sequence7_T0 = 45;

# lecture du fichier d'entree (template)
my $j7_0_template_file = "FIM01_J7_0.fim";
my $FIM01_J7_0_template = get_template($j7_0_template_file);

my $j7_0_track_interval = 50; # en ms
my $r_FIM01_J7_0_message = aladdin_FIM01_J7_0::new(\$FIM01_J7_0_template);
my $j7_0_STN = 9;
my $j7_0_reference_LTN = $scenario_first_LTN;


#reinitialisation du current time et current chrono
$current_chrono = $remote_sequence7_T0;
print "initial chrono : $current_chrono\n";
$current_time = Conversion::toTime($current_chrono);
print "initial time : $current_time\n";
$first_message_chrono = $current_chrono;
$first_message_time = $current_time;

while($j7_0_reference_LTN < $scenario_max_used_LTN){
	# création du message J7.0
	$r_FIM01_J7_0_message->setSTN($j7_0_STN);
	my $message = $r_FIM01_J7_0_message->get_FIM01_J7_0();
	$r_FIM01_J7_0_message->setLTN($j7_0_reference_LTN);
	$message = $r_FIM01_J7_0_message->get_FIM01_J7_0();
	$r_FIM01_J7_0_message->addTime($current_time);
	$message = $r_FIM01_J7_0_message->get_FIM01_J7_0();
	print "$message\n";
	$message =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})\s?(\X{8})\s?(\d{8})\s?(.*)/;
	my $BIM01_header = BIM::getBIM01Header(1);
	my $length = hex($2) + 2;
	$length = sprintf("%08X", $length);
	print "BIM : $1 $length $3 $BIM01_header $4\n";
	print Fout2 "$1 $length $3 $BIM01_header $4\n";
	# ajout du message dans le fichier scenario
	print "FIM : $message\n";
	print Fout "$message\n";
	# incrementation du chrono et du ttime
	$current_chrono += $j7_0_track_interval/1000;
	$current_time = Conversion::toTime($current_chrono);
	# traitement LTN suivant
	$j7_0_reference_LTN += 1;	
}
close Fout;

make_documentation();
exit 0;

sub make_documentation {
	open Fdoc, ">$TEST_NAME.doc" or die "impossible ouvrir $TEST_NAME.doc\n";
	print Fdoc "$TEST_NAME Documentation\n\n";
	print Fdoc "Scenario parameters :
\tduration : $scenario_duration s\n";
	print Fdoc "\tFirst sysTN : $scenario_first_sysTN\n";
	print Fdoc "\nFirst sequence : Receive local air track\n";
	print Fdoc "\tT0 : $remote_sequence2_T0 s\n ";
	print Fdoc "\tReceive $ahd101_track_number Local 3D Air Tracks with interval of $ahd101_track_interval ms
\tLocal Air Track are received $ahd101_track_recurrence_nber times with a period of  $ahd101_track_period s\n";
	print Fdoc "\tReceive $ahd106_track_number Local 2D Tracks with interval of $ahd106_track_interval ms
\tLocal 2D Track are received $ahd106_track_recurrence_nber times with a period of  $ahd106_track_period s\n";
	print Fdoc "Second sequence : drop tracks\n";
	print Fdoc "\treceived Local Drop Message for all 3D + 2D tracks with interval of $drop_interval ms\n";
	print Fdoc "\nEnd of scenario\n";
	close Fdoc;	
}

exit 0;

sub get_template{
	my $template_file = shift;
	open Fin, "<$BASE_DIR/$BIBLIO_DIR/$PROJECT/$template_file" or die "impossible d'ouvrir le fichier d'entree $BASE_DIR/$BIBLIO_DIR/$PROJECT/$template_file\n";
	my $template = <Fin>;
	print "$template\n";
	chomp $template;
	close Fin;
	return $template;
}

sub get_message_time{
	my $template = shift;
	$template =~ /^(\d{2}:\d{2}:\d{2}\.\d{3})/ or die "$template not matching time\n";
	return $1;
}

