#!/bin/perl

use Cwd ;
use File::Find ;

$gElementAComparer  = "" ;
$gVersionLabel1     = "" ;
$gVersionLabel2     = "" ;
$gLabel1            = "" ;
$gLabel2            = "" ;
$gRepertoireCourant = cwd() ;
@gTableauLabel      = () ;

format STDOUT =
nb created lines  = @<<<<<<<<
    $lignesAjoutees
nb deleted lines  = @<<<<<<<<
    $lignesSupprimees
nb modified lines = @<<<<<<<<
    $lignesModifiees
.

&init ;

sub init {
    @gTableauLabel = `cleartool lstype -s -kind lbtype` ;
    
    verifierAffecterParametre() ;

    comparerFichiers() ;
}

sub verifierAffecterParametre {
    $gElementAComparer = $ARGV[0] ;
    
    not -f $gElementAComparer
	and die "Error : file $gElementAComparer not exist." ;
    
    $gLabel1 = $ARGV[1] ;
    
    verifierLabel($gLabel1)
	or die "Error : label $gLabel1 not exist." ;
    
    $gLabel2 = $ARGV[2] ;

    verifierLabel($gLabel2)
	or die "Error : label $gLabel2 not exist." ;

    $gVersionLabel1 =
	`cleartool find $gRepertoireCourant -name $gElementAComparer -version 'lbtype_sub($gLabel1)' -print` ;
    chomp($gVersionLabel1) ;
    $gVersionLabel2 =
	`cleartool find $gRepertoireCourant -name $gElementAComparer -version 'lbtype_sub($gLabel2)' -print` ;
    chomp($gVersionLabel2) ;
}

sub verifierLabel {
    my ($label) = @_ ;
    my $trouve = 0 ;
    my $element ;
    
    chomp($label) ;

    foreach $element (@gTableauLabel) {
	chomp($element) ;
	if ($element eq $label) {
	    $trouve = 1 ;
	    last ;
	}
    }
    return $trouve ;
}

sub comparerFichiers {
    my $changements ;

    $changements = `diff -w $gVersionLabel1 $gVersionLabel2` ;

    if ($changements ne "") {
	@tableauChangements = split /\n/, $changements ;
	
	@lignesChangees = grep !/^[>|<]/, @tableauChangements ;

	($lignesAjoutees, $lignesSupprimees, $lignesModifiees) =
	    traiterModifications(@lignesChangees) ;

	write(STDOUT) ;
    }
}

sub traiterModifications {
    my @lignesChangees = @_ ;
    my $lignesAjoutees   = 0 ;
    my $lignesSupprimees = 0 ;
    my $lignesModifiees  = 0 ;
    my $numeroAvant ;
    my $numeroApres ;
    my @numeroLigne ;
    my $nombreAvant = 0 ;
    my $nombreApres = 0 ;
    
    foreach (@lignesChangees) {
	if ($_ =~ /c/) {
	    ($numeroAvant, $numeroApres) = split(/c/, $_) ;
	    if ($numeroAvant =~ /,/) {
		@numeroLigne = split /,/, $numeroAvant ;
		$nombreAvant = $numeroLigne[1] - $numeroLigne[0] + 1 ;
	    } else {
		$nombreAvant = 1 ;
	    }
	    if ($numeroApres =~ /,/) {
		@numeroLigne = split /,/, $numeroApres ;
		$nombreApres = $numeroLigne[1] - $numeroLigne[0] + 1 ;
	    } else {
		$nombreApres = 1 ;
	    }
	    if ($nombreAvant == $nombreApres) {
		$lignesModifiees += $nombreAvant ;
	    } elsif ($nombreAvant > $nombreApres) {
		$difference = $nombreAvant - $nombreApres ;
		$lignesModifiees += $nombreApres ;
		$lignesSupprimees += $difference ;
	    } elsif ($nombreAvant < $nombreApres) {
		$difference = $nombreApres - $nombreAvant ;
		$lignesModifiees += $nombreAvant ;
		$lignesAjoutees += $difference 
	    }
	} elsif ($_ =~ /a/) {
	    ($numeroAvant, $numeroApres) = split(/a/, $_) ;
	    if ($numeroApres =~ /,/) {
		@numeroLigne = split /,/, $numeroApres ;
		$insertion = $numeroLigne[1] - $numeroLigne[0] + 1 ;
	    } else {
		$insertion = 1 ;
	    }
	    $lignesAjoutees += $insertion ;
	} elsif ($_ =~ /d/) {
	    ($numeroAvant, $numeroApres) = split(/d/, $_) ;
	    if ($numeroAvant =~ /,/) {
		@numeroLigne = split /,/, $numeroAvant ;
		$suppression = $numeroLigne[1] - $numeroLigne[0] + 1 ;
	    } else {
		$suppression = 1 ;
	    }
	    $lignesSupprimees += $suppression ;
	}
    }
    return ($lignesAjoutees, $lignesSupprimees, $lignesModifiees) ;
}
