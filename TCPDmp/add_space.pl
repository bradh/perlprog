open Fin, "<MARTHA_FREE_TEXT.hexa" or die "toto";
open Fout, ">MARTHA_FREE_TEXT.tcf" or die "titi";
while(<Fin>){
	my $ligne = $_;
	$ligne =~ s/(\S\S)/$1 /g;
	print Fout $ligne;
}
close Fin ;
close Fout;
exit 0;