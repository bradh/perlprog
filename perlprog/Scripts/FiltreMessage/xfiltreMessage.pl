#!/usr/bin/perl -w
# xfilterMessage permet de générer le fichier filtremessage.flt de façon graphique
#
# Mise à jour le 23 juillet 2007 par S. Mouchot

use Getopt::Std;
use strict;
use Tk;
#require Tk::MenuButton;
my $opt_h;
getopts("hf:r:");

# print $ENV{PWD};
if ($opt_h) { 
	print "xfiltreMessages génère le fichier filtreMessage.flt nécessaire au script filtreMessage.pl \n";
	print "il permet également de choisir le nom des fichiers de log utilisés et de lancer le script, d'afficher les statistiques sur les messages \n";
	exit(0);
}

if(! $opt_h) {
	my @Select;
	my $I;
	my @Jmessage;
	my %startTime=("Heure" => 0, "Minute" => 0,  "Seconde" => 0);
	my %stopTime=("Heure" => 0, "Minute" => 0,  "Seconde" => 0);
	# initialisation de la structure de donnée refleter par le fichier filtremessage.flt"
	# si le message n'est pas sélectionné la ligne commence par #/s*
	if ( -f "./filtremessage.flt") {	
		print "filtreMessage.flt exite !\n";
		# on lit le fichier dans une structure
		open (Fin, "<./filtremessage.flt") or die "Impossible ouvrir ./filtremessage.flt\n";
		while(<Fin>){
			my $Jselect=-1;
			chomp $_;
			if ($_ =~ /^#*\s*j/){
				if ($_ =~ s/^#\s*(j.*)/$1/){
					$Jselect=0;
				}else{
					$Jselect=1;
				}
				(my $Type, my $Label, my $Sublabel, my $a, my $b) = split (":", $_);
				my $STN=0;
				if(defined($a) && defined($b)){
					$STN = $b;
				}
				#print "J$Label.$Sublabel with STN = $STN\n";	
				my $ref={"Select", $Jselect,"Label",$Label, "Sublabel", $Sublabel,"STN", $STN};
				push @Jmessage, $ref;
				#print "$Jmessage[scalar @Jmessage - 1]\n";
			}
		}
		foreach my $I (0.. scalar @Jmessage-1){
			print "Selected = $Jmessage[$I]->{Select}\n";
			print "$Jmessage[$I]->{Label}\n";
			print "$Jmessage[$I]->{Sublabel}\n";
		}
		close Fin;		
		# on affiche le fichier dans une fenêtre
		# on ajoute un menu spécifique pour ajouter ou supprimer un message et sauvegarder le fichier de configuration
	}
	else {
		print "filtreMessage.flt n'exite pas ! \n";
		#on crée un fichier de base , on l'affiche dans une fenêtre 
	}
	my $mw = MainWindow->new;
    	$mw->title( "$0" );
	my $menu_main = $mw->Frame()->pack(-side => 'top');
	my $configure_mb = $menu_main->Menubutton(-text =>'Configure',
						-relief => 'raised',
						-borderwidth => 2,
						)->pack(-side => 'left',
							-padx => 2);
	$configure_mb->command(-label => 'J Messages filter',
				-command => [\&jmessagesFilter, @Jmessage]);
	$configure_mb->command(-label => 'XHD Messages filter',
				-command => \&jmessagesFilter,);
	$configure_mb->command(-label => 'J log file',
				-command => \&jLog,);
	$configure_mb->command(-label => 'XHD log file',
				-command => \&xhdLog,);
	$configure_mb->command(-label => 'save filterMessage.flt',
				-command => [\&saveFiltreMessage_flt, %startTime, %stopTime, @Jmessage]);
			
	my $execute_mb = $menu_main->Menubutton(-text => 'Execute',
						-relief => 'raised',
						-borderwidth => 2,
						)->pack(-side => 'left',
							-padx => 2);
	my $startFrame = $mw->Frame->pack(-side => 'top');
	$startFrame->Label(-text => 'Start time')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTime{Heure}, -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$startFrame->Label(-text => 'Hour')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTime{Minute},  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$startFrame->Label(-text => 'Minute')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTime{Seconde},  -width => 6, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$startFrame->Label(-text => 'Second')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	my $stopFrame = $mw->Frame->pack(-side => 'top');
	$stopFrame->Label(-text => 'Stop time')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTime{Heure}, -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$stopFrame->Label(-text => 'Hour')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTime{Minute},  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$stopFrame->Label(-text => 'Minute')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTime{Seconde},  -width => 6, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1, 
							-anchor => 'n');
	$stopFrame->Label(-text => 'Second')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	MainLoop();
	
	sub saveFiltreMessage_flt {
		if (-f "./filtreMessage.flt"){
			system("mv ./filtreMessage.flt filtreMessage.flt.bak");
		}
		open Fin, ">./filtreMessage.flt" or die "Impossible ouvrir ./filtreMessage.flt\n";
		print Fin "# start time\n";
		print Fin "start:$startTime{'Heure'}:$startTime{'Minute'}:$startTime{'Seconde'}\n";
		print Fin "# stop time\n";
		print Fin "stop:$stopTime{Heure}:$stopTime{Minute}:$stopTime{Seconde}\n";
		foreach my $I (0.. scalar @Jmessage-1){
			if ($Jmessage[$I]->{Select} == 0) {
				print Fin  "#";
			}
			print Fin "j:$Jmessage[$I]->{Label}:$Jmessage[$I]->{Sublabel}:STN:$Jmessage[$I]->{STN}\n";
		}
		close Fin;
	}
	sub jmessagesFilter {
		my @Hframe;
		# on crée une fenêtre
		my $topLevelConfig=$mw->Toplevel();
	       	$topLevelConfig->title("filtreMessage.flt");
		#$topLevelConfig->Scrollbar(-command =>[yview => $topLevelConfig]);
		foreach my $I (0.. scalar @Jmessage-1){
			#my $Select;
			$Hframe[$I]=$topLevelConfig->Frame->pack(-side => 'top');
			#$Hframe[$I]->Label(-text => "Label")->pack(-side => 'left');
			my $frame=$Hframe[$I]->Frame->pack;  
			$frame->Checkbutton(	-text => 'Select', 
			       			-variable => \$Jmessage[$I]->{'Select'},	
						-anchor => 'w', 
						-width => 5)->pack(-side =>'left' 												, -padx => 5, -anchor => 'n',
								);	
			$frame->Label(-text =>"J$Jmessage[$I]->{Label}.$Jmessage[$I]->{Sublabel}", -anchor => 'w', -width => 5)->pack(-side =>'left' 												, -padx => 5, -anchor => 'n');
			$frame->Entry(-text => 'STN', -textvariable => \$Jmessage[$I]->{STN}, -width => 15)->pack(-side =>'left' 												, -padx => 5, -anchor => 'n');
			
		}
	
		# on affiche le fichier existant
		# on crée un menu spécifique
	}

}	


