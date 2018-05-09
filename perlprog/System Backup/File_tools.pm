package File_tools;

use Tkx;

sub chooseDir {
	my $current_dir = shift;
	my $dir = Tkx::tk___chooseDirectory(-initialdir => $current_dir);
	print $dir . "\n";
	return $dir;
}


1