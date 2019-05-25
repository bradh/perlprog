# Modif S. Mouchot le 11/05/2016 V5_4_6
# 	ajout de l'option -x pour pouvoir lancer l'outil en mode graphique ou en mode online
# 	Traitement de plusieurs messages XHD dans 1 et même trame

use lib qw(G:/Tools/perlprog/lib);
#use strict;
use Tkx;
use Getopt::Std;
use File::Basename;
use TcpDumpLog;
use Conversion;
use BOM;
use SimpleMsg;
use J_Msg;
#use Time_conversion;




getopts("hf:o:");
print "opt_f : $opt_o \n";

my $Config_File = "TCPDump.cfg";
print "opt_f : $opt_f\n";

if($opt_f){
  $Config_File = "$opt_f";
  print "Config file = $Config_File\n";
  exit;
}
exit 0;
