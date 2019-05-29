#!/usr/bin/perl

print "$ARGV[0]\n";
print "$ARGV[1]\n";

foreach my $file (`ls`) {
	chomp $file;
	if($file =~ /$ARGV[0]/){
		print "$file\n";	
		my $old_file = $file;
		$file =~ s/$ARGV[0]/$ARGV[1]/;
		print"$file\n";
		system("mv $old_file $file");
	}
}

exit 0;
