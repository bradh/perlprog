#!/usr/bin/perl
# scrtip tournant en tant que root
# attente du montage de la clé 
# démontage de la clé 
# montage de la clé en tant que toplink
# vérification
# lancement du script d import des fichiers d init
my $USB_DEVICE = "/dev/sdb1";
my $USB_DIR = "/media/toplink/usb";
# attente du montage de la clé 
my $usb_device_present = 0;
while(! $usb_device_present ){
	open(DEVICE, "df |") ;
	while(my $mount_point = <DEVICE>){
		if($mount_point =~ /$USB_DEVICE/){
			$usb_device_present = 1;
			last;
		}
	}
	close DEVICE;
	sleep 1;
}
# démontage de la clé
#system("umount $USB_DEVICE");
# montage de la clé en tant que toplink
# system("sudo -u toplink mount $USB_DEVICE $USB_DIR");	
# lancement du script d import des fichiers d init
 system("sudo -u toplink /toplink/Scripts/get_mids_init_files_from_usb.pl");
exit 0;