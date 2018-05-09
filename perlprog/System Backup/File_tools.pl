sub openDir {
	my $current_dir = shift;
	my $dir = Tkx::tk___getOpenFile(-initialdir => $current_dir);
	print $dir . "\n";
	return $dir;
}