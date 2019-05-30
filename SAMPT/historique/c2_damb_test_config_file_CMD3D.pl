#!/usr/bin/perl -w

###################################################################################
##################################################################################

use Getopt::Std;

getopts("h");

my $debug = 0;
my $DLIP_IP = "200.1.18.51";
my $HOST_TD_IP = "200.1.18.50";


if ($opt_h) { 
	print "$0 [-h] [-c 1 à 9]: init du repertoire de run  \n";
	
}
else {

	print "toot\n";

	
# DeFINir le nom du test
		
		opendir (DIR , ".");
		my @dir = readdir(DIR);
		my $ROOT = `pwd`;
		chomp $ROOT;
		foreach my $NOM_TEST (@dir) {	
		print "$NOM_TEST\n";
			next if($NOM_TEST =~ /^\./);
			next if($NOM_TEST =~ /^_/);
			
			if( -d "$NOM_TEST" ){
				chdir $NOM_TEST;
				print "Process $NOM_TEST...\n";
				chdir "$NOM_TEST";
							
				open FOUT , ">tempo" or die " impossibleouvrir toto";
				open FIN , "<  host_test_driver.conf" or die "impossible ouvrir  c2_host_test_driver.conf";
				while (<FIN>) {
					my $line = $_;
					if($line =~ /Network_Broadcast_Address/){
						print FOUT "Network_Broadcast_Address                = $DLIP_IP\n";
						next;
					}
					if($line =~ /Host_Address/){
						print FOUT "Host_Address            = $HOST_TD_IP\n";
						next;
					}
					print FOUT $line;
				}
				close FIN;
				close FOUT;
				system("mv host_test_driver.conf host_test_driver.conf.old")if(! $debug);
				system("mv tempo host_test_driver.conf")if(! $debug);

				open FOUT , ">tempo" or die " impossibleouvrir toto";
				open FIN , "<  l16_test_driver.conf" or die "impossible ouvrir  l16_test_driver.conf";
				while (<FIN>) {
					my $line = $_;
					if($line =~ /remote_hostname_2/){
						print FOUT "remote_hostname_2                = $DLIP_IP\n";
						next;
					}
					print FOUT $line;
				}
				close FIN;
				close FOUT;
				
				system("mv l16_test_driver.conf l16_test_driver.conf.old")if(! $debug);
				system("mv tempo l16_test_driver.conf")if(! $debug);
				
				open FOUT , ">tempo" or die " impossibleouvrir toto";
				open FIN , "<  martha_main.cfg" or die "impossible ouvrir  martha_main.cfg";
				while (<FIN>) {
					my $line = $_;
					next if($line =~ /^--/);
					if($line =~ /Network_Broadcast_Address/){
						print FOUT "Network_Broadcast_Address                = $HOST_TD_IP\n";
						next;
					}
					if($line =~ /DLIP_Address/){
						print FOUT "DLIP_Address                = $DLIP_IP\n";
						next;
					}
					if($line =~ /SLP_TCP_Address/){
						print "SLP_TCP_Address                = $HOST_TD_IP\n";
						print FOUT "SLP_TCP_Address                = $HOST_TD_IP\n";
						next;
					}
					print FOUT $line;
				}
				close FIN;
				close FOUT;
				system("mv martha_main.cfg martha_main.cfg.old")if(! $debug);
				system("mv tempo martha_main.cfg")if(! $debug);
				chdir("..");
			}
		}
	close DIR; 
}
exit 0;



