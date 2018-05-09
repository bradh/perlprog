package Colonne;

my $MAX;

sub new {
	my $indice = shift;
	$MAX = shift;
	my $r_colonne = {
			"indice" => $indice,
			"MAX" => $MAX,
			"nbre_inconnue" => 0,
			"cellule" => [],
			"ligne" => undef,
			"colonne" => undef,
			"carre" => undef
		};
	bless $r_colonne;
	return $r_colonne;
}

sub checkHypothesis {
	my $r_colonne = shift;
	my $valeur = shift;
	my $test = 1;
	foreach $r_cellule (@{$r_colonne->{cellule}}){
		if ($r_cellule->{valeur} == $valeur){
			$test = 0;
			last;
		}
	}
	return $test;
}
sub contientValeur {
	my $r_colonne = shift;
	my $valeur = shift;
	my $test = 0;
	my $r_array = $r_colonne->{cellule};
	my $indice_l = $r_colonne->{indice};
	#print "Recherche colonne n $indice_l value $valeur\n";
	foreach my $r_cellule (@$r_array){
		my $valeur_contenue = $r_cellule->{valeur};
		my $indice =$r_cellule->{indice};
		#print "Cellule $indice Value $valeur_contenue\n";
		if ($valeur_contenue == $valeur){
			$test = 1;
			last;
		}
	}
	return $test;
}


sub addCell {
	my $r_colonne = shift;
	my $r_cellule = shift;
	my $r_array = $r_colonne->{cellule};
	push (@$r_array, $r_cellule);
	if ($r_cellule->{value} == 0) {
		$r_colonne->{"nbre_inconnue"} += 1;
	}
	return $r_colonne->{nbre_inconnue};
}

sub contientCellule {
	my $r_colonne = shift;
	my $r_cellule = shift;
	my $indice_colonne = $r_colonne->{indice};
	my $indice_cell = $r_cellule->{indice};
	#print "colonne $indice_colonne; cell $indice_cell\n";
	my $a = $indice_cell % $MAX;
	if( $a == $indice_colonne ) {
		print "colonne $indice_colonne; cell $indice_cell\n";
		#print " $indice_cell % $MAX = $a\n";
		return 1;
	}
	else {
		return 0;
	}
}

1
	
	
