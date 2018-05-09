#!/usr/bin/perl -w

# Affaire : SAMPT
# Tâche : automatisation des tests
# Auteur : S. Mouchot
# Mis à jour : le 02/05/2007
# Description :
# A partir d'un nom de test, le script transforme les fichiers .fim et .xdh en .fim.expected et .xdh.expected au format suivant :
#Info_Message:Fim/Jx.x/00:00:02.000
#Mask:       <FFFFFFFF FFFFFFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF> 
#00:07:26.117 00000032 06000001 2801 5388 0D29 0000 C3E8 5400 1041 0000 2830 5002 0100 6401 0000 0005 0010 8000 C71C 0001 0009 0F00 9005 7EC1 0020
# Modifié le 9/05/07 prise en compte d'un fichier de masque pour les messages xdh; 
use Getopt::Std;

my @MOT;
my $Delta_Error = "00:00:02.000";
my %Mask_nonC2 = (
'ADH104'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF 80F8 8000 0000 0000 0000 00FF FFFF FFFF FFFF C0FF FFFF FF80 FFFF FFFF FFFF FFFF FFFF FFFF FFF0 00FF 80FF FF80 FFFF FFFF FFFF FFFF FFFF 80FF FFFF FFFF FFFF FFFF FF>",
'ADH102'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FF00 FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF00 00>",
'ADH109'
=>"	       <FFFFFFFF F1FF006D FFFF 0000 FFFF FFFF 0000 0000 FFFF FF00 FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH116'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF80 FFC0 FFFF FFFF 80FF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 80FF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH101'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF FF00 0000 0000 0000 00FF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF E0FF FF>",
'ADH113'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH105'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF FF00 0000 0000 0000 00FF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH107'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH106'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH117'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF00 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 00FF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH121'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH126'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH127'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 80>",
'ADH129'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH130'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FF>",
'ADH213'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH119'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH132'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH133'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH360'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH137'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH142'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FF>",
'ADH168'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>",
'ADH222'
=>"            <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF>"
);

getopts("ht:");

my $Offset_motI=11; # offset du mot I dans le tableau @MOT $MOT[11] est le 1er boctet
sub getJValue {
	my $Bit_offset = shift; # compris entre 0 et 79
	my $Bit_number = shift; # compris entre 1 et 80
	# Calcul des boctets utiles
	my $First_boctet = int($Bit_offset/16);
	my $Last_boctet = int(($Bit_offset+$Bit_number)/16);
	my $First_bit_of_first_boctet = $Bit_offset%16;
	my $Last_bit_of_last_boctet = ($Bit_offset+$Bit_number)%16;
	my $String = getBoctetHexaString($Last_boctet);
	$String = toHexaString(maskBoctetLastBit($String, $Last_bit_of_last_boctet));
	if($Last_boctet>$First_boctet){
		for $I (($Last_boctet-1).. $First_boctet) {
		$String = $String . getBoctetHexaString($I);
		}
	}
	my $JValue = int(hex($String)/(2**$First_bit_of_first_boctet));
	#print "Jvalue : $JValue\n";
	return $JValue;
}

sub getBoctetHexaString {
	my $Boctet_number = shift;
	my $Boctet_index = getIndexforBoctet($Boctet_number);
	my $String = $MOT[$Boctet_index];
	#print "BoctetHexaString : $String\n";
	return $String;
}

sub getIndexforBoctet {
	my $Boctet_number = shift;
	my $IndexforBoctet = $Offset_motI + $Boctet_number;
	#print "index : $IndexforBoctet\n";
	return $IndexforBoctet;
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
sub toOctalString {
    my@tab = (0..7);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "0000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%8;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/8);
	}
    }
    $string = substr("0000"."$string", -4, 4);
    #print "Octal : $string \n";
    return $string;
}

sub getIndexBoctetMotI {
	my $Position_Mot_I = 8;
	my $BIT_Position = shift;
	return 14-int($BIT_Position/16);
}
sub maskBoctetLastBit {
	my $Boctet = shift;
	my $Last_bit_position = shift;
	#print "$Boctet : $Last_bit_position\n";
	my $Mask = (2**($Last_bit_position))-1;
	my $Boctet_value = hex($Boctet) & $Mask;
	#print "$Mask : $Boctet_value \n";
	return $Boctet_value;
}
sub getMask{
	my $Msg_ID = shift;
	my $Mask = 0;
	print "ADH$Msg_ID\n";
	my $key = "ADH$Msg_ID";
	if (! $Mask_nonC2{$key} ) {
		print "$key n'existe pas\n";
	}
	else {
		$Mask = "$Mask_nonC2{$key}\n";
	}
	return $Mask;
}

if ($opt_h) { 
  print "create_expected_file.pl -t nom_test : A partir d'un nom de test, le script transforme les fichiers .fim et .xdh en .fim.expected et .xdh.expected";
  exit(0);
}
if( ! $opt_h && $opt_t) {
	my $Test_Name = $opt_t;
	my $Test_Name_Lc = lc $Test_Name;

  my $fichierInput = "${Test_Name_Lc}.fim";
  my $fichierOutput = "${Test_Name_Lc}.fim.expected";

  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
  print "Create from $fichierInput to $fichierOutput, please wait...\n";	
	
  while(<Fin>){
    chomp;
    my $LIGNE = $_;
    (@MOT) = (split " ",$LIGNE);
    my $Length_fxm = scalar @MOT;
    #print "$MOT[14]\n";
    # Recherche du label et du sublabel
    my $Label_bit_offset=2;
    my $Label_bit_number=5;
    my $Label = getJValue($Label_bit_offset, $Label_bit_number);
    my $Sublabel_bit_offset=7;
    my $Sublabel_bit_number=3;
    my $Sublabel = getJValue($Sublabel_bit_offset, $Sublabel_bit_number);
    print "Label : $Label SubLabel : $Sublabel\n";
    print Fout "Info_Message:Fim/J$Label.$Sublabel/$Delta_Error\n";
    print Fout "Mask:       <FFFFFFFF FFFFFFFF FFFF FFFF 0000 0000";
    for (my $i=7; $i<$Length_fxm; $i++){
      print Fout " FFFF";
    }
    print Fout ">\n";
    print Fout "$LIGNE\n";
  }
  close Fin;
  close Fout;
#  --  Generate by to_expected software
#Info_Message:ADH/101/00:00:01.000
#Mask:       <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FF00 FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000 0000 0000 FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0000 0000>
#00:00:28.792 0000005A 01000065 0000 0001 0065 0500 1391 48B8 0000 000A 0100 0000 0102 0000 0000 0001 1391 4867 0000 0000 0000 0080 0000 0080 0000 0080 0000 00C3 5000 0000 0000 0000 0003 0000 0000 0080 0000 0000 0000 0000 0000 0000 0000 0000 0000
  $fichierInput = "${Test_Name_Lc}.xdh";
  $fichierOutput = "${Test_Name_Lc}.xdh.expected";
  $fichierMasque = "${Test_Name_Lc}.xdh.mask";
  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";

  print "Create from $fichierInput to $fichierOutput, please wait...\n";
   while(<Fin>){
    chomp;
    my $LIGNE = $_;
    (@MOT) = (split " ",$LIGNE);
     next if (! ($MOT[2] =~ /^01/));
    #print "$MOT[2]\n";
    my $Length_xdh = scalar @MOT;
    my $Msg_ID = hex (substr($MOT[2],-2,2));
    # Ne traite pas les messages techniques
	#print "$Msg_ID\n";
    if($Msg_ID > 100){
	
   	my $Masque = getMask($Msg_ID);
	print Fout "Info_Message:ADH/$Msg_ID/$Delta_Error\n";
	if ($Masque ne "0"){
		print Fout"Mask:$Masque";
      	}
	else {
		print "Attention Msg_ID = $Msg_ID masque à adapter manuellement !\n";
      		print Fout "Mask:       <FFFFFFFF FFFFFFFF FFFF 0000 FFFF FFFF 0000 0000 FFFF FF00";
      		for (my $i=11; $i<$Length_xdh; $i++){
			print Fout " FFFF" if (length( $MOT[$i])== 4);
			print Fout " FF" if (length( $MOT[$i])== 2);
      		}
     		print Fout ">\n";
	}
     	print Fout "$LIGNE\n";
    }
  }
  close Fin;
  close Fout;
  exit 0;
}
