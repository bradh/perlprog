#!/usr/bin/perl -w
# script permettant le chargement automatique des fichiers d'init MIDS lors du branchement d'une cle USB
# Suppression des fichiers d'init MIDS existant sur la cible
# Recuperation du fichier mission.xml
# Liste des fichiers d'init MIDS present sur la cible
# Tri des ficheir d'init MIDS par ordre alpha
# Ajout du prefix MIDS_0X des fichiers
# Mise à jour du fichier mission.xml
# Transfert des fichiers d'init sur la cible
# Transfert du ficheir mission.xml sur la cible
# redemarrage du Toplink

use File::Basename;
use File::Find;

my $XML_MISSION_TARGET_DIR = "/toplink/CORE_MANAGER/CONFIGURATION/MISSION";
my $MIDS_FILE_TARGET_DIR = "$XML_MISSION_TARGET_DIR";
my $MIDS_FILE_EXTENSION = "idl";
my $XML_MISSION_FILE_NAME = "MISSION.xml";
my @XML_MISSION_FILE_LIST;

my $USB_DEVICE = "/dev/sdb1";
my $USB_DIR="/media/toplink/usb";

# Detection du repetoire de montage de la cle usb
#open(DIR, "df |");
#while(my $dir = <DIR>){
	#$USB_DIR = shift;
#	if( $dir =~ /$USB_DEVICE/ ){
#		$USB_DIR = (split(' ',$dir))[5];
#		last;
#	}
#}
#print "$USB_DIR";
#close DIR;
#die "USB directory $USB_DIR not found !\n" if( $USB_DIR == "null");
# Recuperation du fichier mission.xml
die "XML mission file $XML_MISSION_FILE_NAME not found\n" if( ! -d  $XML_MISSION_TARGET_DIR  || ! -e "$XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME");
# Liste des fichiers d'init MIDS present sur la cible
my @mids_init_files;
open FILE, "ls $USB_DIR|";
while(my $file = <FILE>){
	print "$file\n";
	chomp $file;
	push @mids_init_files, $file if( $file =~/\.idl/);  
}
die "no idl file on usb key , nothing is done...\n" if($#mids_init_files < 1 );

# Suppression des fichiers d'init MIDS existant sur la cible
if( -d $MIDS_FILE_TARGET_DIR ){
	open(DIR, "ls $MIDS_FILE_TARGET_DIR|");
	while(my $file = <DIR>){
		chomp $file;
		print "$file\n";
		#system("rm -fr $MIDS_FILE_TARGET_DIR/$file")if ($file =~ /\.idl/);
		system("mv $MIDS_FILE_TARGET_DIR/$file $MIDS_FILE_TARGET_DIR/$file.bak")if ($file =~ /\.idl$/);
	}
	close DIR;
}
else {
	die "MIDS file target directory not found !\n";
}























# Tri des ficheir d'init MIDS par ordre alpha
@mids_init_files = sort @mids_init_files;
# Ajout du prefix MIDS_0X des fichiers
# Transfert des fichiers d'init sur la cible

foreach my $index (0..$#mids_init_files){
	# on rajoute le préfixe MIDS_XX au nom du fichier si il ne commence pas par MIDS_
	my $j = $index + 1;
	my $file = $mids_init_files[$index];
	$mids_init_files[$index] = "MIDS_${j}_" . "$file" if( $file !~ /^MIDS_/);
	print "with prefixe $mids_init_files[$index]\n";
	
	system("cp $USB_DIR/$file $MIDS_FILE_TARGET_DIR/$mids_init_files[$index]");
}
# Mise à jour du fichier mission.xml
#system("cp $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME.bak") or die "not possible save mission file\n";
open Fin, "< $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME" or die "file $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME not found\n";
open Fout, "> $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME.new" or die "file $XML_MISSION_TARGET_DIR/$XML_MISSION_FILE_NAME.new not found\n";
while(<Fin>){
	my $line = $_;
	print Fout $line  if ( $line !~ /FILE ID/ && $line !~ /<RESOURCE ID/);
	if ($line =~ /<RESOURCE ID/){
		print Fout $line;
		foreach my $index (0.. $#mids_init_files){
			my $j= $index + 1;
			print Fout "\t\t\<FILE ID=\"$j\" LABEL=\"INIT $j\" FILE=\"$mids_init_files[$index]\" \/>\n";
		}
	}
}
close Fin;
# Transfert du fichier mission.xml sur la cible
# redemarrage du Toplink
#system("/toplink/Scripts/stop_CORE_MANAGER");
#system("/toplink/Scripts/start_COREMANAGER");
print "That's all folk !\n";
exit 0;
