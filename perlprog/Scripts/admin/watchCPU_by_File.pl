#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("hf:c:v:ust:lr:");
my @NOM_PROCESS ;

# List des process à surveiller
my @Processes = ( 	"sampt_main",
			"recorder",
			"slp",
			"SNCP");
		
my $Log_file="watchCPU.log";
if($opt_f){
  $Log_file=$opt_f;
}

# Definition des utilitaires systeme:
my $PS_PROCESS="ps -ax";

my $Delta_echantillon = 12; # en seconde
my $Nbre_echantillon = 30;

if ($opt_h) { 
  print "watchCPU.pl [-h][-f fichier entree]: mesure le CPU et la RAM\n";
  exit 0;
}
if( ! $opt_h) {

  my %CPU;

  my %CPU_previous;

  foreach my $Process (@Processes){
    open Fin, "<$Log_file" or die "Impossible ouvrir $Log_file\n";
    open Fout, ">$Process.cpu" or die "Impossible ouvrir $ProcessesCPURAM.log\n";
    $CPU_previous{$Process}=0;
    $CPU{$Process}=0;
    my $HEURE=0;
    print Fout "$Process\n";
    while(<Fin>){
      my $LIGNE=$_;  
      if ($LIGNE =~ /WET/) { 
	chomp;
	$HEURE=$_;
      }
      if ($LIGNE =~ /$Process/) {
	$CPU{$Process}= (split " ",$LIGNE) [7];
	my $PROC_NAME = (split " ", $LIGNE)[10];
	if ($CPU{$Process} =~ /\d?:\d?:\d?/){
	  my ($heure, $minute, $seconde) = split (":", $CPU{$Process});
	  $CPU{$Process} = $heure*3600+$minute*60+$seconde;
	}
	else{
	  if ($CPU{$Process} =~ /\d?:\d?/){
	    my ($minute, $seconde) = split (":", $CPU{$Process});
	    $CPU{$Process} = $minute*60+$seconde;
	  }
	}
	my $tmp = ($CPU{$Process}-$CPU_previous{$Process})/$Delta_echantillon;
	print Fout "$HEURE\t$tmp\n";
	#print "$Process CPU = $tmp \n";
	$CPU_previous{$Process}= $CPU{$Process};
      } 
    }
    close Fout;
    close Fin;
  }
  open Fin, "<$Log_file" or die "Impossible ouvrir $Log_file\n";
  open Fout, ">rack.ram" or die "Impossible ouvrir $ProcessesCPURAM.log\n";
  print Fout "RAM_TOTAL\t RAM_FREE\t RAM_USED\n";
   while(<Fin>){
     my $LIGNE=$_;
     if ($LIGNE =~ /physical\/virtual/) {
       #print"$LIGNE\n";
       $RAM_FREE = (split " ",$LIGNE) [0];
       $RAM_FREE = (split "/",$RAM_FREE)[0];
       $RAM_FREE =~ s/K//;
       $RAM_USED = (split " ",$LIGNE) [3];
       $RAM_USED =~ s/K//;
       #print "free :	$RAM_FREE \n";
       #print "used : 	$RAM_USED\n";
       # Calcul de nouveau échantillon
       $RAM_TOTAL = $RAM_USED + $RAM_FREE;
       print Fout "$RAM_TOTAL\t $RAM_FREE\t $RAM_USED\n";
     }
   }
  close Fout;
  close Fin;
}
exit 0;


