#!/bin/perl -w

use Getopt::Std;
#use Time::Local;

getopts("hf:");

my $Scenario_name = $opt_f if(defined($opt_f));

if ($opt_h) { 
	print "split_scenario_by_min.pl [-f] nom_scenario [-l] nombre de ligne [-h] : supprime les fom techniques des fichiers résultat .fim \n";
}

if( ! $opt_h && $opt_f ) {
	my @Extension = ("xhd","xdh", "fim", "fom", "jo", "ji");
	foreach my $Extension (@Extension) {
		my $INPUT_FILE = "$Scenario_name.$Extension";
		print "Traitement $INPUT_FILE\n";
		if (-f $INPUT_FILE){
  			open Fin, "<$INPUT_FILE" or die "Impossible d'ouvrir $INPUT_FILE\n";
			while(<Fin>){
				my $LINE = $_;
				if( $LINE =~ /^(\d\d):(\d\d):(\d\d)/){
		  			my $Heure = $1;
		  			my $Minute = $2;
		  			create_config_file ($Heure, $Minute);
		  			my $OutputFile = "$Scenario_name-$Heure-$Minute.$Extension";
		  			open Fout, ">>$OutputFile" or die "Impossible ouvrir $OutputFile  \n";
		  			print Fout "$LINE";
		  			close Fout;
				}
	      	}
      	}
		close Fin;
	}
}
exit 0;

sub create_config_file {
	my $Heure = shift;
	my $Minute = shift;
	my $new_scenario_name = "$Scenario_name-$Heure-$Minute";
	my $config_file_name = "$Scenario_name.conf";
	my $new_config_file_name = "$Scenario_name-$Heure-$Minute.conf";
	if(! -f $new_config_file_name && -f $config_file_name){	
			open Fin, "< $config_file_name" or die "impossible ouvrir $config_file_name";		
			open Fout, ">$new_config_file_name" or die "impossible creer $new_config_file_name";
			while (<Fin>) {
				my $ligne = chomp $_;
				$ligne =~ s/$Scenario_name/$new_scenario_name/;
				print Fout "$ligne\n";
			}
			
	}
	return 0;
}

