#!/usr/bin/perl -w
# xfilterMessage permet de générer le fichier filtremessage.flt de façon graphique
#
# Mise à jour le 23 juillet 2007 par S. Mouchot

package xMessageFilter;

use Conversion;

my $debug = 1;
my $testDir;
my $testFile;
my $filterDir;
my $filterFile;
my $r_extList;
my $startChrono;
my $stopChrono;
my $startTimeHour = 0;
my $startTimeMinute = 0;
my $startTimeSecond = 0;
my $stopTimeHour = 0;
my $stopTimeMinute = 0;
my $stopTimeSecond = 0;
my @JMessage;
my @XHDMessage;
my @XDHMessage;
my $mw;

sub xMessageFilter(){
  use strict;
  use Tk;

  # on récupère le répertoire local, le nom du fichier d'entrée, le repertoire filtre, le nom du fichier filtré
 
  (my $dump, $testDir, $testFile, $filterDir, $filterFile, $r_extList) = (@_);
   
  if ($debug == 1) {
	print "$testDir, $testFile, $filterDir, $filterFile\n";
  }
	my @Select;
	my $I;

	# initialisation de la structure de donnée refleter par le fichier filtremessage.flt"
	# si le message n'est pas sélectionné la ligne commence par #/s*
	if(! -d "$testDir\\$filterDir"){
      system("mkdir $testDir\$filterDir") or die "$testDir\\$filterDir creation failed..\n";
      }
	if ( -f "$testDir\\$filterDir\\filtremessage.flt") {
		print "filtreMessage.flt exite !\n";
		# on lit le fichier dans une structure
		open (Fin, "<$testDir\\$filterDir\\filtremessage.flt") or die "Impossible ouvrir ./filtremessage.flt\n";
		while(<Fin>){
			my $line = $_;
			chomp $line;
			if ($line =~ /^Start/){
               (my $dump,$startTimeHour, $startTimeMinute, $startTimeSecond) = split (":", $line);
 			}
			if ($line =~ /^Stop/){
               (my $dump,$stopTimeHour, $stopTimeMinute, $stopTimeSecond) = split (":", $line);
               
			}
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
				push @JMessage, $ref;
				#print $Jmessage[scalar @Jmessage - 1]."\n";
			}
			if ($_ =~ /^#*\s*xhd/ ){
				if ($_ =~ s/^#\s*(xhd.*)/$1/ ){
					$Jselect=0;
				}else{
					$Jselect=1;
				}
				(my $Type, my $XHD_ID) = split (":", $_);
			
				#print "J$Label.$Sublabel with STN = $STN\n";	
				my $ref={"Select", $Jselect,"XHD_ID", $XHD_ID};
				push @XHDMessage, $ref;
				#print $Jmessage[scalar @Jmessage - 1]."\n";
			}
			if ($_ =~ /^#*\s*xdh/){
				if ( $_ =~ s/^#\s*(xdh.*)/$1/){
					$Jselect=0;
				}else{
					$Jselect=1;
				}
				(my $Type, my $XDH_ID) = split (":", $_);
			
				#print "J$Label.$Sublabel with STN = $STN\n";	
				my $ref={"Select", $Jselect,"XDH_ID",$XDH_ID};
				push @XDHMessage, $ref;
				#print $Jmessage[scalar @Jmessage - 1]."\n";
			}
		}
		foreach my $I (0.. scalar @JMessage-1){
			print "Selected = ".$JMessage[$I]->{Select}."\n";
			print $JMessage[$I]->{Label}."\n";
			print $JMessage[$I]->{Sublabel}."\n";
		}
		close Fin;		
		# on affiche le fichier dans une fenêtre
		# on ajoute un menu spécifique pour ajouter ou supprimer un message et sauvegarder le fichier de configuration
	}
	else {
		print "filtreMessage.flt n'exite pas ! \n";
		#on crée un fichier de base , on l'affiche dans une fenêtre 
	}

	$mw = MainWindow->new;
    	$mw->title( "$0" );

	my $startFrame = $mw->Frame->pack(-side => 'top');
	$startFrame->Label(-text => 'Start time')->pack(-side =>'left',
	       						-padx => 5, 
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTimeHour, -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$startFrame->Label(-text => 'Hour')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTimeMinute,  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$startFrame->Label(-text => 'Minute')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	$startFrame->Entry(-textvariable => \$startTimeSecond,  -width => 6, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$startFrame->Label(-text => 'Second')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	my $stopFrame = $mw->Frame->pack(-side => 'top');
	$stopFrame->Label(-text => 'Stop time')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTimeHour, -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$stopFrame->Label(-text => 'Hour')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTimeMinute,  -width => 2, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$stopFrame->Label(-text => 'Minute')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
	$stopFrame->Entry(-textvariable => \$stopTimeSecond,  -width => 6, -borderwidth => 2)->pack(-side =>'left',
	       						-padx => 1,
							-anchor => 'n');
	$stopFrame->Label(-text => 'Second')->pack(-side =>'left',
	       						-padx => 5,
							-anchor => 'n');
# Affichage du bouton "Configure"	
    my $menu_main = $mw->Frame()->pack(-side => 'top');
	my $configure_mb = $menu_main->Menubutton(-text =>'Configure',
						-relief => 'raised',
						-borderwidth => 2,
						)->pack(-side => 'left',
							-padx => 2);
	$configure_mb->command(-label => 'J Messages filter',
				-command => [\&JMessagesFilter, @JMessage]);
	$configure_mb->command(-label => 'XHD Messages filter',
				-command => \&XHDMessagesFilter, @XHDMessage);
	$configure_mb->command(-label => 'XDH Messages filter',
				-command => \&XDHMessagesFilter, @XDHMessage);
	$configure_mb->command(-label => 'save filterMessage.flt',
				-command => [\&saveFiltreMessage_flt]);
# Affichage du bouton "Apply Filter"
	my $execute_mb = $menu_main->Menubutton(-text => 'Apply filter',
						-relief => 'raised',
						-borderwidth => 2,
						)->pack(-side => 'left',
							-padx => 2);
        $execute_mb->command(-label => 'Apply Filter',
				-command => [\&applyFilter]);
	MainLoop();

    sub applyFilter {
    	my $chrono = 0;
    	if(! -f "$testDir\\$filterDir\\$filterFile.conf"){
        	print " create filter.conf   \n";
         	open Fout, "> $testDir\\$filterDir\\$filterFile.conf" or die "impossible creating $filterFile.conf\n";
          	print Fout "Link_Output_File = $filterFile.fom\n";
          	print Fout "Link_Input_File = $filterFile.fim\n";
          	print Fout "Host_Output_File_1 = $filterFile.xdh\n";
          	print Fout "Host_Input_File_1 = $filterFile.xhd\n";
          	close Fout;
    	}
    	my (@startTime) = ($startTimeHour, $startTimeMinute, $startTimeSecond,0);
    	my (@stopTime) = ($stopTimeHour, $stopTimeMinute, $stopTimeSecond,0);
    	$startChrono = Conversion::toChrono(@startTime);
    	$stopChrono = Conversion::toChrono(@stopTime);
    	if($debug == 1){
    		print "startTime @startTime\n";
    		print "start = $startChrono\n";
    		print "stop = $stopChrono\n";
    	}
       	foreach my $ext (@$r_extList){
    		print "process ext $ext\n" if($debug == 1);
    		if(-f "$testDir\\$testFile.$ext"){  			
    			open Fin, "<$testDir\\$testFile.$ext" or die "open $testDir\\$testFile.$ext impossible...\n";
    			open Fout, ">$testDir\\$filterDir\\$filterFile.$ext" or die "open $testDir\\$filterDir\\$filterFile.$ext impossible...\n";
    			while(<Fin>){
    				my $line = $_;
    				print "$line" if($debug == 1);
    				if($line =~ /(^\d{2}):(\d{2}):(\d{2})\.(\d{3})/){
    					#$line = select_XHD($line) if($ext eq "xhd");
    					#$line = select_XDH($line) if($ext eq "xdh");
    					#$line = select_FOM($line) if($ext eq "fom");
    					#$line = select_FIM($line) if($ext eq "fim");
    					#next if($line == -1);
    					my (@time)=  ($1, $2, $3, $4);
    					print "Time = @time\n" if($debug == 1);
	   					$chrono = Conversion::toChrono(@time);
      					$chrono = Conversion::formatSec($chrono);
      					print "chrono line : $startChrono <? $chrono <? $stopChrono\n" if($debug == 1);
						if($chrono > $startChrono && $chrono < $stopChrono){
      						print Fout "$line";
      					}
    				}
    				else {
    					print Fout "$line";
    				}
    				#<>;
    			}
    		}
    		close Fout;
    		close Fin;
    	}
    }

    sub saveFiltreMessage_flt {
		if (-f "$testDir\\$filterDir\\filtreMessage.flt"){
			system("XCOPY /Y $testDir\$filterDir\filtreMessage.flt $testDir\$filterDir\filtreMessage.flt.bak");
		}
		open Fin, ">$testDir\\$filterDir\\filtreMessage.flt" or die "Impossible ouvrir $testDir\$filterDir\\filtreMessage.flt\n";
		print Fin "# start time\n";
		print Fin "Start:$startTimeHour:$startTimeMinute:$startTimeSecond\n";
		print Fin "# stop time\n";
		print Fin "Stop:$stopTimeHour:$stopTimeMinute:$stopTimeSecond\n";
		foreach my $I (0.. scalar @JMessage-1){
			if ($JMessage[$I]->{Select} == 0) {
				print Fin  "#";
			}
			print Fin "j:$JMessage[$I]->{Label}:$JMessage[$I]->{Sublabel}:STN:$JMessage[$I]->{STN}\n";
		}
		close Fin;
	}
	sub select_XHD  {
		chomp;
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;
		my $AHD_id;
		print "$MOT[14]\n";
		exit 0;
		# récupération de l'ADH id
		if($MOT[2] =~ /......(..)/){
			$AHD_id = hex($1);
			print "AHD$AHD_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($AHD_id == 109){
				return $LIGNE;
			}
			else {
				return -1;
			}
		}
		else {
			return -1;
		}
	}
	sub select_XDH {
		my $LIGNE = $_;
		my @MOT = split " ",$LIGNE;
		my $ADH_id;
		#print "$MOT[14]\n";
		# récupération de l'ADH id
		if($MOT[2] =~ /01....(..)/){
			$ADH_id = hex($1);
			print "ADH : $ADH_id\n";
			# Le xdh du test driver ne tagge pas les messages recus
			if($ADH_id == 109 ){
				return $LIGNE;
			}
			else{
				return -1;
			}
		}
		else{
			return -1;
		}
	}
	sub select_FOM {
		my $LIGNE = $_;
		return $LIGNE;
	}
	sub select_FIM {
		my $LIGNE = $_;
		return $LIGNE;
	}
	sub JMessagesFilter {
		my @Hframe;
		# on crée une fenêtre
		my $topLevelConfig=$mw->Toplevel();
	       	$topLevelConfig->title("filtreMessage.flt");
		#$topLevelConfig->Scrollbar(-command =>[yview => $topLevelConfig]);
		foreach my $I (0.. scalar @JMessage - 1){
			#my $Select;
			$Hframe[$I]=$topLevelConfig->Frame->pack(-side => 'top');
			#$Hframe[$I]->Label(-text => "Label")->pack(-side => 'left');
			my $frame=$Hframe[$I]->Frame->pack;  
			$frame->Checkbutton(	-text => 'Select', 
			       			-variable => \$JMessage[$I]->{'Select'},	
						-anchor => 'w', 
						-width => 5)->pack(-side =>'left' , -padx => 5, -anchor => 'n',
								);	
			$frame->Label(-text =>"J$JMessage[$I]->{Label}.$JMessage[$I]->{Sublabel}        STN ", -anchor => 'w', -width => 15)->pack(-side =>'left' , -padx => 5, -anchor => 'n');
			$frame->Entry(-text => 'STN', -textvariable => \$JMessage[$I]->{STN}, -width => 10)->pack(-side =>'left' , -padx => 5, -anchor => 'n');
			
		}
	
		# on affiche le fichier existant
		# on crée un menu spécifique
	}
	sub XHDMessagesFilter {
		my @Hframe;
		# on crée une fenêtre
		my $topLevelConfig=$mw->Toplevel();
	       	$topLevelConfig->title("filtreMessage.flt");
		#$topLevelConfig->Scrollbar(-command =>[yview => $topLevelConfig]);
		foreach my $I (0.. scalar @XHDMessage - 1){
			#my $Select;
			$Hframe[$I]=$topLevelConfig->Frame->pack(-side => 'top');
			#$Hframe[$I]->Label(-text => "Label")->pack(-side => 'left');
			my $frame=$Hframe[$I]->Frame->pack;  
			$frame->Checkbutton(	-text => 'Select', 
			       			-variable => \$XHDMessage[$I]->{'Select'},	
						-anchor => 'w', 
						-width => 5)->pack(-side =>'left' , -padx => 5, -anchor => 'n',
								);	
			$frame->Label(-text =>"XHD$XHDMessage[$I]->{XHD_ID}", -anchor => 'w', -width => 15)->pack(-side =>'left' , -padx => 5, -anchor => 'n');		
		}

	}
	sub XDHMessagesFilter {
		my @Hframe;
		# on crée une fenêtre
		my $topLevelConfig=$mw->Toplevel();
	       	$topLevelConfig->title("filtreMessage.flt");
		#$topLevelConfig->Scrollbar(-command =>[yview => $topLevelConfig]);
		foreach my $I (0.. scalar @XDHMessage - 1){
			#my $Select;
			$Hframe[$I]=$topLevelConfig->Frame->pack(-side => 'top');
			#$Hframe[$I]->Label(-text => "Label")->pack(-side => 'left');
			my $frame=$Hframe[$I]->Frame->pack;  
			$frame->Checkbutton(	-text => 'Select', 
			       			-variable => \$XDHMessage[$I]->{'Select'},	
						-anchor => 'w', 
						-width => 5)->pack(-side =>'left' , -padx => 5, -anchor => 'n',
								);	
			$frame->Label(-text =>"XDH$XHDMessage[$I]->{XDH_ID}", -anchor => 'w', -width => 15)->pack(-side =>'left' , -padx => 5, -anchor => 'n');
			
		}

	}
	
}
1
