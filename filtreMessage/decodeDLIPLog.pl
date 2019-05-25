#!/usr/bin/perl -w
# decodeDLIPLog.pl permet de decoder les messages fim /fom loggé avec les traces MIDS interface Core adaptateur
# Il utilise les entrée et sortie standard
#
# Cette version fonctionne avec le DLIP LOC1 version L4.12.1
# Mise € jour le 16/06/09 par S. Mouchot
#

use Getopt::Std;
use fom03;
use fom63;

getopts("h");

# print $ENV{PWDb;
if ($opt_h) { print "decodeDLIPLog.pl\n";
print "decode les fim / fom du log DLIP avec traces MICA\n";
exit(0);}




my $heure = 0;
my $minute = 0;
my $seconde = 0;


while(<>){
          my $line = $_;
          chomp $line;
#         Maintien de l'heure
          if($_ =~ /(\d+):(\d+):(\d+\.\d+)\s+IFOM/) {
                $heure = $1;
                $minute = $2;
                $seconde = $3;
		    }
#          extractAlert();
           if($line =~ /^\*\s/){ print "$line\n"};
#          extractWarning();
           if($line =~ /^\*\*\s/) {print "$line\n"};
#          extractError();
           if($line =~ /^\*\*\*\s/) {print "$line\n"};
#          extractFom();
	       if($line =~ /I(FOM)_id:\s+(\d+).+ data:\s+(.*)/) {
   #                     resource_id:  3 IFOM_id:  3 IFOM_word_count:  4 data:  00 03 40 40 21 80 00 09
				my $r1 = $1;
				my $fom_id = $2;
				my $data = $3;
				$data =~ s/\s//g;
				$data =~ s/^\d\d\d\d//;
				if ($fom_id == 3){
                   my $fom03 = fom03::new($data);
                   my $currentInitState  = $fom03->{currentInitState};
                   my $netEntryStatus = $fom03->{netEntryStatus};
				   print "$heure:$minute:$seconde\t\tFom $fom_id\n\t\t\t\t$currentInitState\n\t\t\t\t$netEntryStatus\n";
#				   exit 0;
				}
				if($fom_id == 63) {

				   my $fom63 = fom63::new($data);
                   my $validity  = $fom63->{validity};
                   my $errorCode = $fom63->{errorCode};
                   my $MTOD_UTC_DeltaTime = $fom63->{MTOD_UTC_DeltaTime};
				   print "$heure:$minute:$seconde\t\tFom $fom_id\n\t\t\t\t$validity\n\t\t\t\t$errorCode\n\t\t\t\t$MTOD_UTC_DeltaTime\n";
				   #exit 0;
                   }
			}
#			extract changement etat
			if($line =~/_Mgr/){
              print "$heure:$minute:$seconde\n\t$line\n";
              }
#             extract Flow tracer
              if($line =~ s/FLOW_TRACER// ){
                $line =~ s/\++\s*//;
                print "$line\n";
              }
}

exit(0);



