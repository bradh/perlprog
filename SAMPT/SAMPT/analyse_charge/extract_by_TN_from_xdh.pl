#!/usr/bin/perl
# #!/cygdrive/c/Perl/bin/perl 

use Getopt::Std;

my $RESULTS_FILE = "xdh_arrival_times_and_tns.txt";

getopts("hf:");

if ($opt_h) { 
  print "extract_by_TN_from_xdh.pl : extrait à partir de l'entrée standard";
  exit(0);
}
if( ! $opt_h ) {
	print "Extract AHD by TN, please wait...\n";
	while(<>){
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
			if($ADH_id == 101 || $ADH_id == 102 || $ADH_id == 103 || $ADH_id == 104 || $ADH_id == 105 || $ADH_id == 106 || $ADH_id == 107 || $ADH_id == 108 || $ADH_id == 109 || $ADH_id == 147 ){
				my $TN = hex($MOT[16]);
				my $fichierOutput = "ADH$ADH_id-$TN.xdh";
				open Fout, ">>$fichierOutput" or open ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
				#print "$ADH_id\n";
				#print "$LIGNE\n";	
				print Fout "$LIGNE\n";
				close Fout;
			}
		}
	}
}
print "That's all folk !\n";
exit 0;
