#!/usr/bin/perl
# #!/cygdrive/c/Perl/bin/perl 

use Getopt::Std;

my $RESULTS_FILE = "xdh_arrival_times_and_tns.txt";

getopts("hf:");

if ($opt_h) { 
  print "extract_TN_date_from_xdh.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h && $opt_f ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "$RESULTS_FILE";

	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";

	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;
		my $ADH_id;
		#print "$MOT[14]\n";
		# récupération de l'ADH id
		if($MOT[2] =~ /01....(..)/){
			$ADH_id = hex($1);
			#print "$ADH_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($ADH_id == 101 || $ADH_id == 102 || $ADH_id == 103 || $ADH_id == 104 || $ADH_id == 105 || $ADH_id == 106 || $ADH_id == 107 || $ADH_id == 108|| $ADH_id == 109 || $ADH_id == 118 || $ADH_id == 135 || $ADH_id == 325){
				my $TN = hex($MOT[16]);
				#print "$ADH_id\n";
				#print "$LIGNE\n";	
				print Fout "$MOT[0] $TN ADH$ADH_id\n";
			}
			if($ADH_id == 142){
			  # simulation d'un TN fictif 12345
				print Fout "$MOT[0] 12345 J10_2_IN ADH$ADH_id\n";
			}
			if($ADH_id == 147){
			  # simulation d'un TN fictif 12346
			  print Fout "$MOT[0] 12346 J9_2_IN ADH$ADH_id\n";
			}
		}
	}
}
exit 0;
