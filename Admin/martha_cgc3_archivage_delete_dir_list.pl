#!:usr/bin/perl

use Getopt::Std;

getopts("d:l:");

my $sum = 0;
my $levelMax = 0;
my $level = 0;

$levelMax = $opt_l if($opt_l);
print "level max = $levelMax\n";

my $dir = "Z:/t0028369/Mes documents/Tools/perlprog";

$dir = $opt_d if($opt_d);
chdir ($dir) or die "$dir n est pas un directory";

print "****enter LEVEL $level*************************\n";
print "$dir\n";

processDirectory("$dir");

exit 0;

sub processDirectory {
	my $current_directory = shift;
	return if ($level > $levelMax);
	#print "current directory : $current_directory\n";
	opendir(DIR, $current_directory);
	my @dir = readdir(DIR);	
 	foreach my $dir (@dir) {
 			next if($dir =~ /^\./);
 			if ( -d $dir){
 				$level += 1;
 				#print "****enter LEVEL $level*************************\n";
 				print "$level;$dir;;;;\n";
 				chdir($dir);
 				processDirectory ("$current_directory/$dir");
 				chdir("..");
 				$level -= 1;
 			}
 			else {
 				#print "file : $dir\n"
 			}
 			
 	}
 	
 	#chdir("..");
 	close DIR;
 	return
 }




exit 0;

sub du {
	my $Dir = shift;
	my $level = shift;
	$level += 1;
	#print "$level\n";
	my $Sum1  = 0;
	print "$Dir\n";
	opendir (Dir, $Dir) or die "$Dir not a directory\n";
	exit;
	@dots = grep { -f "$Dir\\$_" } readdir(Dir);

	foreach my $File (@dots){
		#print "$File\n";
		my $Taille = `ls -l $Dir/$File`;
		$Taille = (split(" ", $Taille))[6];
		$Sum1 += $Taille;
		#print "$Taille\n";
	} 
	close Dir;
	opendir (Dir, $Dir) or die "$Dir not a directory\n";
	my @Dir1 = grep { ! /^\./ && -d "$Dir/$_" } readdir(Dir);
	foreach my $Dir2 (@Dir1){
		#print "1 $Dir\\$Dir2\n";
		$Sum1 += du("$Dir\\$Dir2", $level);
		#print "2 $Dir\\$Dir2\n";
	}
	close Dir;
	print "Taille $Dir = $Sum1 \n" if($level < $levelMax);
	return $Sum1;
}


