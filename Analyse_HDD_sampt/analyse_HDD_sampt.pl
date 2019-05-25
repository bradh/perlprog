#!/usr/bin/perl -w
# calcul les temps de transit du recorder


# a partir du fichier pcap sampt_test_HDD_0001.pcap

my $TEST_DIR = "E:/SAMPT_MCO/test_HDD";
my $PCAP_FILE = "sampt_test_HDD_00001.pcap";

# converti le pcap en format aladdin 
# créer les fichier sampt_test_HDD_in/out.fim/fom

chdir ($TEST_DIR);
print "decoding fim/fom SLP side from $PCAP_FILE, please wait...\n";
system("tcpdump2Aladdin_V5_4_6.pl -p $PCAP_FILE -f TCPDmp_in.cfg");
print "decoding fim/fom MIDS side from $PCAP_FILE, please wait...\n";
system("tcpdump2Aladdin_V5_4_6.pl -p $PCAP_FILE -f TCPDmp_out.cfg");

# extrait les heures par message , les convertit en chrono
# creer les 4 fichiers fim/fom_arrival_times_in/out.txt

system("extract_TN_date_from_fim.pl -i -f sampt_test_HDD_in.fim");
system("extract_TN_date_from_fim.pl -o -f sampt_test_HDD_out.fim");
system("extract_TN_date_from_fom.pl -i -f sampt_test_HDD_out.fom");
system("extract_TN_date_from_fom.pl -o -f sampt_test_HDD_in.fom");

# calcule le temps de transit dans le recorder
# créer les fichiers result_fim/fom.csv

system("time_diff_calculate.pl -i fim_arrival_times_in.txt -o fim_arrival_times_out.txt -r result_fim.csv");
system("time_diff_calculate.pl -i fom_arrival_times_in.txt -o fom_arrival_times_out.txt -r result_fom.csv");

print "That's all folks !\n";

exit 0;


