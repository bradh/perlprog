use Cellule;
use Ligne;
use Colonne;
use Carre;
use Getopt::Std;

my $MAX = 9;
my @Cellule;
my @Ligne;
my @Carre;
my @value;
my $niveauMax;

getopts("hf:");

# Initialisation du Sudoku
if ( ! $opt_f) {die "option -f not defined \n";}

open Fin, "<$opt_f" or die "Impossible ouvrir $opt_f\n";
my $I = 0;
# Initialisation du tableau de cellules
while(<Fin>){
	chomp $_;
	@value = split ('/', $_);
	#print @value;
	foreach my  $value (@value) {
		@Cellule[$I] = Cellule::new($I,$value);
		$I += 1;
	}
}
# Determiner automatiquement la valeur MAX
$MAX = scalar @value;
# Verifier la coherence du fichier lu
if ( $I > $MAX*$MAX ) {die "$opt_f n'est pas un fichier valide\n";}
# Affichage des valeur par cellule	
foreach my $cellule (@Cellule){
	my $indi = $cellule->get_indice;
	my $valeur =  $cellule->get_value;
	print "$indi : $valeur \n";
}
# Création du tableau de lignes
foreach my $I (0..$MAX-1){
	my $r_ligne = Ligne::new($I, $MAX);
	push @Ligne, $r_ligne;
}
# ajout des cellules dans les lignes 
foreach my $cellule (@Cellule) {
	foreach my $ligne (@Ligne){
		my $indi = $ligne->{"indice"};
		#print " ligne indice $indi\n";
		if ($ligne->contientCellule($cellule)){
			#print "Ajout Cell \n";
			$ligne->addCell($cellule);
			#print "Ajout Ligne \n";
			$cellule->{ligne}=$ligne;
			last;
		}
		else {
			#print "Cell not add\n";
		}
	}
}
# Création du tableau de colonnes
foreach my $I (0..$MAX-1){
	my $r_colonne = Colonne::new($I, $MAX);
	push @Colonne, $r_colonne;
}
# ajout des cellules dans les colonnes
foreach my $cellule (@Cellule) {
	foreach my $colonne (@Colonne){
		my $indi = $colonne->{"indice"};
		#print " colonne indice $indi\n";
		if ($colonne->contientCellule($cellule)){
			#print "Ajout Cell \n";
			$colonne->addCell($cellule);
			#print "Ajout Colonne \n";
			$cellule->{colonne}=$colonne;
			last;
		}
		else {
			#print "Cell not add\n";
		}
	}
}
# Création du tableau de carres
foreach my $I (0..$MAX-1){
	my $r_carre = Carre::new($I, $MAX);
	push @Carre, $r_carre;
}
# ajout des cellules dans les carres
foreach my $cellule (@Cellule) {
	foreach my $carre (@Carre){
		my $indi = $carre->{"indice"};
		#print " carre indice $indi\n";
		if ($carre->contientCellule($cellule)){
			#print "Ajout Cell \n";
			$carre->addCell($cellule);
			#print "Ajout Carre \n";
			$cellule->{carre}=$carre;
			last;
		}
		else {
			#print "Cell not add\n";
		}
	}
}
# Calcul des valeurs possibles pour chaque cellule
foreach my $r_cellule (@Cellule){
	if ($r_cellule->{valeur}==0){
	#if ($r_cellule->{valeur}==0){
		my $r_ligne = $r_cellule->{ligne};
		my $r_colonne = $r_cellule->{colonne};
		my $r_carre = $r_cellule->{carre};
		my $indice = $r_cellule->{indice};
		#print "$indice OK\n";
		foreach my $valeur (1..$MAX){
			if (! $r_ligne->contientValeur($valeur) && ! $r_colonne->contientValeur($valeur)&& ! $r_carre->contientValeur($valeur)){
			       print "$valeur ajoutee a cellule $indice\n";
			       $r_cellule->add_valeur_possible($valeur);
		       }
	       }
	}
}

# Algorithme de résolution : les choses sérieuses commencent !
my $I=0;
my $hypothesis = makeHypothesis($I);
if($hypothesis){
	# Affichage des valeurs trouvées
	#my $toto = scalar @Cellule;
	#print "nbre cell $toto\n";
	foreach my $r_cellule (@Cellule){
		my $indice = $r_cellule->{indice};
		my $valeur = $r_cellule->{valeur};
		print "Cell $indice : valeur $valeur\n";
	}
	# Sortie du resultat dans le fichier result.txt
	open Fout, ">result.txt" or die "Impossible d'ouvrir result.txt ! \n";
	foreach my $I (1..$MAX){
		print Fout "....";
	}
	print Fout "\n";
	foreach my $r_ligne ( @Ligne){
		print Fout ":";
		foreach my $r_cellule ( @{$r_ligne->{cellule}}){
			my $value = $r_cellule->{valeur};
			#chomp $value;
			print Fout " $value :";
		}
		print Fout "\n";
		foreach my $I (1..$MAX){
			print Fout "....";
		}
		print Fout "\n";
	}
	close Fout;
	print "That all folk's !\n";
}
else {
	print " Resolution impossible , changer de journal !\n";
	print " Niveau max atteint = $niveauMax\n";
}
exit 0;

sub makeHypothesis {
	my $I = shift;
	$niveauMax = $I if($I > $niveauMax);
	my $r_cellule = @Cellule[$I];
	my $hyposthesis = 0;
	if (scalar @{$r_cellule->{valeur_possible}} !=0 ){
		my $indice = $r_cellule->{indice};
		#print "process cell $indice\n";
		my $r_ligne = $r_cellule->{ligne};
	       	my $r_colonne = $r_cellule->{colonne};
		my $r_carre = $r_cellule->{carre};	
		foreach my $valeur (@{$r_cellule->{valeur_possible}}	){
			print "process cell $indice $I\n";
			if ( $r_ligne->checkHypothesis($valeur) && $r_colonne->checkHypothesis($valeur) && $r_carre->checkHypothesis($valeur) ){
				print "$valeur OK\n";
				$r_cellule->{valeur} = $valeur;
				$hypothesis = 1;
				$hypothesis = makeHypothesis($I+1) if ($I<$MAX*$MAX);
				if ($hypothesis == 1){
					last;
				}
				else {
					$r_cellule->{valeur} = 0;
				}
			}
			else {
				print "$valeur NOK\n";
				$hypothesis = 0;
			}
		}
	}
	else {
		$hypothesis = makeHypothesis($I+1) if($I<$MAX*$MAX);
	}
	return $hypothesis;
}
	
exit 0;
$cellule->add_valeur_possible(5);
$cellule->del_valeur_possible(5);
print $cellule->Cellule::get_nbre_valeur_possible();
my $r_array = $cellule->get_valeur_possible();
print $r_array->[0];
