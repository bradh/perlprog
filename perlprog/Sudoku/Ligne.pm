package Ligne;

my $MAX;

sub new {
	my $indice = shift;
	$MAX = shift;
	my $r_ligne = {
			"indice" => $indice,
			"MAX" => $MAX,
			"nbre_inconnue" => 0,
			"cellule" => [],
			"ligne" => undef,
			"colonne" => undef,
			"carre" => undef
		};
	bless $r_ligne;
	return $r_ligne;
}

sub checkHypothesis {
	my $r_ligne = shift;
	my $valeur = shift;
	my $test = 1;
	foreach $r_cellule (@{$r_ligne->{cellule}}){
		if ($r_cellule->{valeur} == $valeur){
			$test = 0;
			last;
		}
	}
	return $test;
}	

sub contientValeur {
	my $r_ligne = shift;
	my $valeur = shift;
	my $test = 0;
	my $r_array = $r_ligne->{cellule};
	my $indice_l = $r_ligne->{indice};
	#print "Recherche ligne n $indice_l value $valeur\n";
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
	my $r_ligne = shift;
	my $r_cellule = shift;
	my $r_array = $r_ligne->{cellule};
	push (@$r_array, $r_cellule);
	if ($r_cellule->{value} == 0) {
		$r_ligne->{"nbre_inconnue"} += 1;
	}
	return $r_ligne->{nbre_inconnue};
}

sub contientCellule {
	my $r_ligne = shift;
	my $r_cellule = shift;
	my $indice_ligne = $r_ligne->{indice};
	my $indice_cell = $r_cellule->{indice};
	#print "ligne $indice_ligne; cell $indice_cell\n";
	#my $a = $indice_cell % $MAX;
	my $a = int ($indice_cell / $MAX);
	if( $a == $indice_ligne ) {
		#print " $indice_cell % $MAX = $a\n";
		print "ligne $indice_ligne; cell $indice_cell\n";
		return 1;
	}
	else {
		return 0;
	}
}

1
	
	
