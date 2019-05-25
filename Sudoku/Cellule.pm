package Cellule;

sub new {
	my ($indice, $valeur) = @_;
	my $r_cellule = {
		"indice" => $indice,
		"valeur" => $valeur,
		"valeur_possible" => []};
	bless $r_cellule;
	my $nbre_valeur_possible = 0;
	return $r_cellule;
}

sub get_value {
	my $r_cellule = shift;
	return $r_cellule->{valeur};
}
sub get_indice {
	my $r_cellule = shift;
	return $r_cellule->{indice};
}

sub get_nbre_valeur_possible  {
	my $r_cellule = shift;
	my $r_array = $r_cellule->{valeur_possible};
	return 	$#{$r_array};
}

sub get_valeur_possible {
	my $r_cellule = shift;
	my $r_array =  $r_cellule->{"valeur_possible"};
	print $r_array->[0];
	return $r_cellule->{"valeur_possible"};
}

sub add_valeur_possible {
	my $r_cellule = shift;
	my $new_value = shift;
	#print $new_value;
	my $r_array = $r_cellule->{valeur_possible};
	push @$r_array , $new_value;
	#push @{$r_cellule->{valeur_possible}}, $new_value;
	#foreach my $I (0..$#{$r_array}){
	#	print "$r_array->[$I]\n";
	#}
	return 	$#{$r_array};
}

sub del_valeur_possible {
	my $r_cellule = shift;
	my $value_to_del = shift;
	my $r_array = $r_cellule->{valeur_possible};
	my $ind = 0;
       	my $find = false;	
	foreach my $value (@$r_array) {
		if ( $value == $value_to_del ){
			$find = true;
			last;
		}
		$ind += 1;
	}
	if ( $find == "true" ){
		foreach my $i ($ind..$#{$r_array}-2) {
			$r_array->[$i] = $r_array->[$i+1];
		
		}
		pop @$r_array;
	}
	return $#{$r_array};
}
			
1	
      			       
