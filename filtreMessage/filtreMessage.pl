#!/usr/bin/perl -w
# filterMessage permet le filtre et le tri des messages ADH AHD TDH THD FIM et FOM
# entrant et sortant du DLIP Ä partir des fichiers mhi.log et loc1_main.log
#
# Cette version fonctionne avec le DLIP LOC1 version L4.12.1
# Mise Ä jour le 16/06/09 par S. Mouchot
#

use Getopt::Std;

getopts("hf:r:");

# print $ENV{PWDb;
if ($opt_h) { print "filtreMessages [-f nom_fichier_filtre] [-r rãpertoire_fichier_sortie]\n";
print "filtreMessages permet d'extraire les msg ADH, AHD, THD, TDH  du fichier mhi.log  .\n et les messages j du fichier loc1_main.log \n";
exit(0);}

my $heureDebut=0;
my $minuteDebut=0;
my $secondeDebut=0;
my $chronoDebut=0;
my $chronoFin;

# lecture du fichier de filtrage

my $fichierInput = "filtreMessage.flt";
if($opt_f) { $fichierInput = "$opt_f";}

 $repOut=".";
if($opt_r) { $repOut= "./$opt_r";}

open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput !\n";

my @tableauFiltre;
while(<Fin>){
	chomp($_);
	if($_ =~ /^#/ or length $_ == 0) {next;}
	else {
		push @tableauFiltre, $_;
		print "$_\n";
	}
}
close Fin;

# extraction des fichiers de base

extractVersion();

extractDate();

# Calcul des variables $chronoDebut et $chronoFin
my @filtre;
foreach (@tableauFiltre) {
	chomp;
	@filtre = split ":", $_;
	if($filtre[0] =~ /debut/) {
		$chronoDebut = conv2Chrono($filtre[1], $filtre[2], $filtre[3] );
		print "chrono debut : $chronoDebut\n";
	}
	if($filtre[0] =~ /fin/) {
		$chronoFin = conv2Chrono($filtre[1], $filtre[2], $filtre[3] );
		print "chrono fin : $chronoFin\n";
	}
}

extractAlert();

extractWarning();

extractError();

#extractAdh();

#extractAhd();

extractFom();

#extractFim();

# filtrage des messages J TDH THD

#selectFim("1");
#selectFom("1");

foreach (@tableauFiltre){
	my @filtre = split ":", $_;
	#print $filtre[0];
#	if ($filtre[0] =~ /fim/) {
#	    push @tableauFichier, selectFim($filtre[1]);
#	}
	if ($filtre[0] =~ /fom/) {
	    push @tableauFichier, selectFom($filtre[1]);
	    print " toto $filtre[1]";
	}
#	if ($filtre[0] =~ /j/) {
#	    push @tableauFichier, selectJout($filtre[1], $filtre[2]);
#	    push @tableauFichier, selectJin($filtre[1], $filtre[2]);
#	}
#	if ($filtre[0] =~ /dh/) {
#	    push @tableauFichier, selectAdh($filtre[1], $filtre[3]);
#	}
#	if ($filtre[0] =~ /hd/) {
#	    push @tableauFichier, selectAhd($filtre[1], $filtre[3]);
#	}
    }

#### Concatenation des fichiers dans final.rslt
	#system ( "rm $repOut/final.rslt" );
	foreach(@tableauFichier) {
	    system("more $_ >> $repOut/final.rslt ");
	}
#### Tri chronologique de final.rslt dans finalsort.rslt
	system("more $repOut/final.rslt | sort -o $repOut/finalsort.rslt");

#### Conversion du fichier finalsort.rslt au format aladdin finalsort.xdh
	$fichierInput = "$repOut/finalsort.rslt";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree finalsort.rslt\n";
	open Fout, ">$repOut/finalsort.xdh" or die "impossible de creer le fichier de sortie $repOut/finalsort.xdh\n ";
	open Foutj, ">$repOut/finalsort.jo" or die "impossible de creer le fichier de sorite $repOut/finalsort.jo\n";

	while (<Fin>) {
	    @tableauLigne = split ":", $_;
	    my $Imax = scalar @tableauLigne; # indice max du tableau
	    # print $Imax ."\n";
	    # print $tableauLigne[1];
	    if ($tableauLigne[1] eq "ADH" or $tableauLigne[1] eq "AHD") {
		if ($tableauLigne[$Imax-1] =~ /^\d{4}(.{4})(.*)/){
		    my ($heure, $minute, $seconde) = conv2Time($tableauLigne[0]);

		    if ($seconde < 10) {
			printf Fout ( "%02d:%02d:0%2.3f 0000$1$2\n", $heure, $minute, $seconde);
		    }
		    else {
			printf Fout ( "%02d:%02d:%2.3f 0000$1$2\n", $heure, $minute, $seconde);
		    }
		}
	    }
	    elsif ($tableauLigne[1] eq "fom") {
		if ($tableauLigne[2]== 20 ){
			my $length = (length ($tableauLigne[3]-1))/2;
			#print "deci : $length\n";
			$length = hex $length;
			#print "hexa : $length\n";
			$length = "00000000$length";
			$length = substr($length,-8,8);
			#print "string : $length\n";
			#print "$tableauLigne[0]\n";
			 my ($heure, $minute, $seconde) = conv2Time($tableauLigne[0]);
			$heure = "0$heure";
			$heure = substr($heure, -2, 2);
			$minute = "0$minute";
			$minute = substr($minute,-2,2);
			$seconde = "0$seconde"."000";
			$seconde =~ /(\d{2}.\d{3})/;
			$seconde = $1;
			#print "time : $heure:$minute:$seconde\n";
			print Fout "$heure:$minute:$seconde $length 04000001 $tableauLigne[3]\n";
		# le format 000000xx 0400000y corps du fom
		# le format fim 000000xx 060000y corps du fim xx longueur y n∑ du fom/fim
			}
		}
	    elsif ($tableauLigne[1] eq "fim") {}
	    elsif ($tableauLigne[1] eq "ji") {
	      my $hour = $tableauLigne[0];
	      my $label = $tableauLigne[2];
	      $label = hex $label;
	      $label = "00$label";		
	      $label = substr($label,-2,2);
	      my $sub_label = $tableauLigne[3];
	      $sub_label = hex $sub_label;
	      $sub_label = "00$sub_label";		
	      $sub_label = substr($sub_label,-2,2);
	      my $j_message =  $tableauLigne[4];
	      chomp $j_message;
	      #print "$j_message\n";
	      my $j_length = length $j_message;
	      my $length = int($j_length/2) + 18;
	      $length = toHexaString($length);
	      $length = "00000000$length";		
	      $length = substr($length,-8,8);
	      $j_message =~ s/(.{4})/$1 /g;
	      ($heure, $minute, $seconde) = conv2Time ($hour);
	      $heure = "0$heure";
	      $heure = substr($heure, -2, 2);
	      $minute = "0$minute";
	      $minute = substr($minute,-2,2);
	      $seconde = "0$seconde"."000";
	      $seconde =~ /(\d{2}.\d{3})/;
	      $seconde = $1;
	      #print " $heure, $minute, $seconde\n";
	      print Foutj "$heure:$minute:$seconde $length 0E$label"."$sub_label"."00 0000 0000 0000 0000 0000 0000 0000 $j_message\n"; 
	    }
	    elsif ($tableauLigne[1] eq "jo") {
	      my $hour = $tableauLigne[0];
	      my $label = $tableauLigne[2];
	      $label = hex $label;
	      $label = "00$label";		
	      $label = substr($label,-2,2);
	      my $sub_label = $tableauLigne[3];
	      $sub_label = hex $sub_label;
	      $sub_label = "00$sub_label";		
	      $sub_label = substr($sub_label,-2,2);
	      my $j_message =  $tableauLigne[4];
	      chomp $j_message;
	      my $j_length = length $j_message;
	      #print "j_length =  $j_length\n";
	      my $length = int($j_length/2) + 20;
	      $length = toHexaString($length);
	      #print "$length en hexa\n";
	      $length = "00000000$length";		
	      $length = substr($length,-8,8);
	      #print "$length en hexa\n";
	      $j_message =~ s/(.{4})/$1 /g;
	      ($heure, $minute, $seconde) = conv2Time ($hour);
	      $heure = "0$heure";
	      $heure = substr($heure, -2, 2);
	      $minute = "0$minute";
	      $minute = substr($minute,-2,2);
	      $seconde = "0$seconde"."000";
	      $seconde =~ /(\d{2}.\d{3})/;
	      $seconde = $1;
	      #print " $heure, $minute, $seconde\n";
	      print Foutj "$heure:$minute:$seconde $length 0F$label"."$sub_label"."00 0000 0000 0000 0000 0000 0000 0000 0000 $j_message\n"; 
	    }
	}
		
	close Fin;
	close Fout;
	close Foutj;
#### CrÈation du fichier de conf Aladdin
	open Fout, ">$repOut/finalsort.conf" or die "impossible de creer le fichier d'Ifom $repOut/finalsort.conf\n ";
	my $line1 = "Host_Output_File_1        = finalsort.xdh\n";
	my $line2 = "MESSAGE_Output_File_1     = finalsort.jo\n";
 	print Fout "$line1";
	print Fout "$line2";
	close Fout;
#### Suppression des fichiers intermediaire .rslt
	system("rm -f $repOut/*.rslt");

#### Appel du viewer
	#system("viewer $repOut/finalsort.vwr $repOut/ouput.vwr");
 	
	exit(0);


#### Sub-routines #####

# "extractAdh permet d'extraire les msg ADH, TDH  du fichier mhi.log  .\n";

sub extractAdh {
	my $fichierInput = "mhi.log";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree mhi.log\n";
	open Fout, ">$repOut/adh.rslt" or die "impossible de creer le fichier d'Ifom $repOut/Adh.rslt\n ";
	my $label=0;
	my $Msg_ID=999;
	my $SEC;
	while(<Fin>){
		if($_ =~ /Msg_ID=(\d+), Cnx_ID=(\d+)\s==>/ && $label == 0) {$Msg_ID = $1;$Cnx_ID=$2;$label = 1}
		if($_ =~ /^(\d+):(\d+):(\d+.\d+)\s(0000)(.*$)/ && $label == 1) {
			$label = 0;
			#print "$Msg_ID\n";
			my $mess = "0001".$5;
			# correction du timer mhi.log de 0.5 sec	
			$SEC = ($1*60*60)+($2*60)+$3 + 0.5;
			#print "$1:$2:$3\n";
			#print "$SEC\n";
			# sortie de la boucle si le temps est sup a $chronoFin
			if(isOutOfTime($SEC)){last;}
			if(isInTime($SEC)){
				if($SEC =~ /^\d\./) { $SEC = "000".$SEC; }
				if($SEC =~ /^\d\d\./) { $SEC = "00".$SEC;}
				if($SEC =~ /^\d\d\d\./) { $SEC = "0".$SEC;}
				print Fout "$SEC:ADH:$Msg_ID:Cnx_ID:$Cnx_ID:$mess\n";
			}
	 	} 
	}
	close Fin;
	close Fout;
	return;
}

# selectAdh permet de selectionner les ADH du fichier adh.rslt

sub selectAdh {
	my $messageID = shift;
	my $cnxID = shift;
	my $fichierInput = "$repOut/adh.rslt";
	my $fichierOutput = "${repOut}/adh_${messageID}_cnx_$cnxID.rslt";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree adh.rslt \n";
	open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'Ifom $repOut/Adh.rslt\n ";
	while(<Fin>){
	    @chrono = split ":", $_ ;
	    #print "$chrono[0]\n";
	    if($_ =~ /ADH:(\d+):Cnx_ID:(\d+)/ ) {
		if ($1 == $messageID && ($2 == $cnxID || $2 == "000") && isInTime($chrono[0])) {
		    print Fout $_;
		}
	    }
	}
	close Fin;
	close Fout;
	return $fichierOutput;
}

# selectAhd permet de selectionner les AHD du fichier ahd.rslt

sub selectAhd {
        my $messageID = shift;
	my $cnxID = shift;
        my $fichierInput = "$repOut/ahd.rslt";
	my $fichierOutput = "$repOut/ahd_${messageID}_cnx_$cnxID.rslt";
        open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
        open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'Ifom $fichierOutput\n ";
        while(<Fin>){
	    @chrono = split ":", $_ ;
	    if($_ =~ /AHD:(\d+):Cnx_ID:(\d+)/) {
		if ($1 == $messageID && $2 == $cnxID && isInTime($chrono[0])) {
		    print Fout $_;
		}
	    }
	}
	close Fin;
	close Fout;
	return $fichierOutput;
    }
# "extractAhd permet d'extraire les msg AHD, THD  du fichier mhi.log  .\n";

sub extractAhd {
	my $fichierInput = "mhi.log";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree mhi.log\n";
	open Fout, ">$repOut/ahd.rslt" or die "impossible de creer le fichier d'Ifom $repOut/Ahd.rslt\n ";
	my $Msg_ID=999;
	my $label=0;
	while(<Fin>){
        	if($_ =~ /Msg_ID=(\d+), Cnx_ID=(\d+)\s<==/ && $label == 0) {$Msg_ID = $1;$Cnx_ID = $2;$label=1;}
        	if($_ =~ /^(\d+):(\d+):(\d+.\d+)\s(\d\d\d\d)(.*$)/ && $label == 1) {
	  		$label = 0;
			$mess = "0002".$5;
			#print "$Msg_ID:$Cnx_ID\n";
			# correction du timer de mhi.log + 0.5 sec
	                $SEC = ($1*60*60)+($2*60)+$3+0.5 ;
        	        #print "$1:$2:$3\n";
                	#print "$SEC\n";
			if(isOutOfTime($SEC)){last;}
			if(isInTime($SEC)){
				if($SEC =~ /^\d\./) { $SEC = "000".$SEC; }
        	        	if($SEC =~ /^\d\d\./) { $SEC = "00".$SEC;}
                		if($SEC =~ /^\d\d\d\./) { $SEC = "0".$SEC;}	
	                	print Fout "$SEC:AHD:$Msg_ID:Cnx_ID:$Cnx_ID:$mess\n";
#	                	print  "$SEC:AHD:$Msg_ID:Cnx_ID:$Cnx_ID:$mess\n";
			}
		}
	}
	close Fin;
	close Fout;
}

# "extractFom permet d'extraire les msg Fom du fichier log de loc1_main.\n";}
sub extractFom {
	my $fichierLog = "./loc1_main.log";
	open Flog, "<$fichierLog" or die "impossible d'ouvrir le fichier de log";
	open fIfom, ">$repOut/fom.rslt" or die "impossible de creer le fichier d'Ifom $repOut/Ifom.rslt";
	my $ligne=0;
	my $heure = 0;
	my $minute = 0;
	my $seconde = 0;
	my $SEC;
	while(<Flog>){
          #        print "$_";
		if($_ =~ /(\d+):(\d+):(\d+\.\d+)\s+IFOM/) {
            $heure = $1;
            $minute = $2;
            $seconde = $3;
			$SEC=$1*3600+$2*60+$3;
			#print "$1 $2 $3 $SEC\n";
			#exit 0;
			if($SEC =~ /^\d\./) { $SEC = "000".$SEC; }
                	if($SEC =~ /^\d\d\./) { $SEC = "00".$SEC;}
                	if($SEC =~ /^\d\d\d\./) { $SEC = "0".$SEC;}
			if(isOutOfTime($SEC)){last;}
		}
		if($_ =~ /I(FOM)_id:\s+(\d+).+ data:\s+(.*)/) {
   #                     resource_id:  3 IFOM_id:  3 IFOM_word_count:  4 data:  00 03 40 40 21 80 00 09
			if(isInTime($SEC)){
				my $r1 = $1;
				my $r2 = $2;
				my $data = $3;
				$data =~ s/\s//g; 
				$data =~ s/^\d\d\d\d//;
				#print $2;
				print fIfom "$heure:$minute:$seconde\t$r1\t$r2\t$data\n";
			}
		} 
	}
	close fIfom;
	close Flog;
	return;
}


# "extractFim permet d'extraire les msg Fom du fichier log de loc1_main.\n";}

sub extractFim {
	my $fichierLog = "./loc1_main.log";
	open Flog, "<$fichierLog" or die "impossible d'ouvrir le fichier de log";
	open fIfim, ">$repOut/fim.rslt" or die "impossible de creer le fichier d'Ifom $repOut/fim.rslt";
	my $ligne=0;
	my $SEC;
	while(<Flog>){
		if($_ =~ /^\+\s*(-*\d+\.\d+)\s+EMITTING_IFIM/) {
		    	$SEC=$1;
	    		if($SEC =~ /^\d\./) { $SEC = "000".$SEC; }
			if($SEC =~ /^\d\d\./) { $SEC = "00".$SEC;}
			if($SEC =~ /^\d\d\d\./) { $SEC = "0".$SEC;}
			if(isOutOfTime($SEC)){last;}
		}
		if($_ =~ /i(fim)_id:\s+(\d+).+ data:\s+(.*$)/) {
			if(isInTime($SEC)){
				my $r1 = $1;
				my $r2 = $2;
				my $data = $3;
				$data =~ s/\s//g; 
				$data =~ s/^\d\d\d\d//;
				#print $2;
				print fIfim "$SEC:$r1:$r2:$data\n";
			}
		} 
	}
	close fIfim;
	close Flog;
	return;
}

# "selectFom permet de selectionner les msg fomN du fichier fom.rslt.\n";}

sub selectFom {
	my $num = shift;
	my $fichierInput = "$repOut/fom.rslt";
	my $fichierOutput = "$repOut/fom_$num.rslt";
	#print "$fichierOutput\n";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
	open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'Ifom $fichierOutput";
	while(<Fin>){
		#print $_;
		@chrono = split " ", $_ ;
		my ($heure, $minute, $seconde) =  split ":", $chrono[0];
		my $chrono0 = conv2Chrono ($heure, $minute, $seconde);
		if($_ =~ /\sFOM\s(\d+)\s/) {
			#print isInTime($chrono[0])."fom$1"."$chrono[0]"."\n";
			if($num == $1 && isInTime($chrono0)) {
				#print "oui\n";
				print Fout $_ ;
			}
		}
	}
	close Fin;
	close Fout;
	return $fichierOutput;
}



# "selectFim permet de selectionner les msg fomN du fichier fim.rslt.\n";}

sub selectFim {
	my $num = shift;
	my $fichierInput = "$repOut/fim.rslt";
	my $fichierOutput = "$repOut/fim_$num.rslt";


	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";

	open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'Ifim $repOut/Ifim.rslt";

	while(<Fin>){
		# print $_;
		@chrono = split ":", $_ ;
		if($_ =~ /:fim:(\d+):/) {
			if($num == $1 && isInTime($chrono[0])) {
				print Fout $_ ;
			}
		}
	}
	close Fin;
	close Fout;
	return $fichierOutput;
}


# "selectJout permet de selectionner les msg J du fichier fom1.rslt.\n";}

sub selectJin {
	# paramätre du label et du sub label
	my $mask_label = 0x007C;
	my $lsb_label = 2;
	my $mask_sublabel = 0x0380;
	my $lsb_sublabel = 7;
	my $fichierInput = "fom_1.rslt";
	my $lbl = shift;
	my $sbLbl = shift;
	my $fichierOutput = "$repOut/J_${lbl}_${sbLbl}_in.rslt";
	open Fin, "<$repOut/$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
	open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'fom $repOut/fom1.rslt";
	my $j=20;
	while(<Fin>){
		if($_ =~ /fom:1:(.+)/) { 
		  $mess = $1;
		  #print "fom $mess\n";
		  $mess =~ s/\w{$j}(\w+)/$1/;
		  # print "fom $mess\n\n";
		}
		if($_ =~ /(^.*):fom:1:\w{$j}(\w{4})/) {
			my $heure = $1;		
			my $mot1 = hex $2; 
			#print "mot : $mot1\n";
			my $mot2 = $3;
			my $i = $lsb_label;
			my $label =  $mot1 & $mask_label; 
			$label= $label>>$i;
			#print $label; print "\n";
			$i = $lsb_sublabel;
			my $sublabel = $mot1 & $mask_sublabel;
			$sublabel = $sublabel>>$i;
		        # print $label . " :". $sublabel."\n";
			if($label eq $lbl && $sbLbl eq $sublabel) {
				print Fout "$heure:ji:$label:$sublabel:$mess\n" ;
			}
		}
	}
	close Fin;
	close Fout;
	return $fichierOutput;
}

# "selectJin permet de selectionner les msg J du fichier fim1.rslt.\n";}

sub selectJout {
	# paramätre du label et du sub label
	my $mask_label = 0x007C;
	my $lsb_label = 2;
	my $mask_sublabel = 0x0380;
	my $lsb_sublabel = 7;
	my $lbl = shift;
	my $sbLbl = shift;
	my $fichierInput = "fim_1.rslt";
	my $fichierOutput = "$repOut/J_${lbl}_${sbLbl}_out.rslt";
	open Fin, "<$repOut/$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
	open Fout, ">$fichierOutput" or die "impossible de creer le fichier d'fim $repOut/fim1.rslt";
	my $j=32; 
	while(<Fin>){
		if($_ =~ /fim:1:(.+)/) { 
		  $mess = $1;
		  #print "fim $lbl $sbLbl\n$mess\n";
		  $mess =~ s/\w{$j}(\w+)/$1/;
		  # print "$mess\n\n";
		}
		if($_ =~ /(^.*):fim:1:\w{$j}(\w{4})/) {
			my $heure = $1;		
			my $mot1 = hex $2; 
			#print $mot1."mot1\n";
			my $mot2 = $3;
			my $i = $lsb_label;
			my $label =  $mot1 & $mask_label; 
			$label= $label>>$i;
			#print $label; print "\n";
			$i = $lsb_sublabel;
			my $sublabel = $mot1 & $mask_sublabel;
			$sublabel = $sublabel>>$i;
			# print $label . " :". $sublabel."\n";
			if($label eq $lbl && $sbLbl eq $sublabel) {
				print Fout "$heure:jo:$label:$sublabel:$mess\n" ;
			}
		}
	}
	close Fin;
	close Fout;
	return $fichierOutput;
}

# extraction des alertes

sub extractAlert {
	my $fichierInput = "loc1_main.log";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
        open Fout, ">$repOut/alert.rslt" or die "impossible de creer le fichier d'fom $repOut/alert.rslt";
	while(<Fin>){
		if($_ =~ /^\*\*\s/) {print Fout $_;}
	}
	close Fin;
	close Fout;
	return;
}

# extraction des warning

sub extractWarning {
  	my $fichierInput = "loc1_main.log";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
	open Fout, ">$repOut/warning.rslt" or die "impossible de creer le fichier des warning $repOut/warning.rslt";
  	while(<Fin>){
		if($_ =~ /^\*\s/) {print Fout $_;}
  	}
  	close Fin;
	close Fout;
	return;
}

# extraction des erreurs

sub extractError {
  my $fichierInput = "loc1_main.log";
  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
  open Fout, ">$repOut/error.rslt" or die "impossible de creer le fichier d'erreurs $repOut/error.rslt";
  while(<Fin>){
	if($_ =~ /^\*\*\*\s/) {print Fout $_;}
  }
  close Fin;
  close Fout;
  return;
}

# extraction de la date du fichier log et calcule l'heure de dãbut du log

sub extractDate {
	my $fichierInput = "loc1_main.log";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
	open Fout, ">$repOut/date.rslt" or die "impossible de creer le fichier $repOut/date.rslt";
	my $boucle = 1;
 	my $boucle2=1;
	while(<Fin>) {
		#recherche de  Launch date    : 8 OCTOBER 2004 08:58:06
		if($_ =~ /Launch date/ && $boucle && $boucle2){
		    my @date = split ( " ", $_);
		    $dateDebut = "$date[3] $date[4] $date[5]";
		    ($heureDebut, $minuteDebut, $secondeDebut) = split(":", $date[6]);
		    #conv2Time($chrono);
		    #$heureDebut = $heureDebut - $heure;
		    #$minuteDebut = $minuteDebut - $minute;
		    #$secondeDebut = $secondeDebut - $seconde;
		    
		    print Fout "Date:$dateDebut\n";
		    print Fout "Heure:$heureDebut\n";
		    print Fout "Minute:$minuteDebut\n";
		    print Fout "Seconde:$secondeDebut\n";
		    $boucle = 0;		
		    $boucle2 = 0;
		}
	    }
	close Fin;
	close Fout;
	return;
}

# extraction de la version loc1

sub extractVersion {

	$fichierInput = "loc1_main.log";
        open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree";
        open Fout, ">$repOut/version.rslt" or die "impossible de creer le fichier $repOut/version.rslt";
	while(<Fin>) {
                 my $line = lc($_);
		    if($line =~ /version/) {print Fout $_;}
	}
        close Fin;
        close Fout;
	return;
}

# convertit un chrono en nombre d'heure de minute et de seconde

sub conv2Time {

	my $chrono = shift;
	# print "chron : $chrono \n";
	my $heure = int $chrono/3600;
	# print "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);
	# print "$minute\n";
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	# print "$seconde\n";
	return ($heure, $minute, $seconde);
}

# convertit une heure en chrono rãfãrence log
sub conv2Chrono {
	my $heure = shift;
	my $minute = shift;
	my $seconde = shift;
	my $chrono1 = $heure*3600 + $minute*60 + $seconde;
	my $chrono2 = $heureDebut*3600 + $minuteDebut*60 + $secondeDebut;
	#print "heure : $heure\n";
	#print "heure debut : $heureDebut\n";
	#print "chrono2 : $chrono2\n";
	return ($chrono1 - $chrono2);
}

# test si le chrono est compris entre chronoDebut et chronoFin
sub isInTime {
	my $chronox = shift;
	#print "chrono: $chronox \n";
	#print "fin   : $chronoFin \n";
	#print "debut : $chronoDebut) \n";
	return ($chronox < $chronoFin && $chronox > $chronoDebut);
}

sub isOutOfTime{
	my $chronox = shift;
	my $toto = $chronox > $chronoFin;
	#print "chronox = $chronox > chrono fin = $chronoFin -> $toto\n";
	return ($chronox > $chronoFin);
}
sub toHexaString {
    my@tab = (0..9,A..F);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "00000000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%16;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/16);
	}
    }
    $string = substr("0000000000"."$string", -8, 8);
    #print "hexa : $string \n";
    return $string;
}
exit(0);

