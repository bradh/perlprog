#!/usr/bin/perl

use Getopt::Std;

getopts("d:l:");

my $sum = 0;
my $levelMax = 3;
my $level = 0;

$levelMax = $opt_l if($opt_l);
print "level max = $levelMax\n";

$dir = "Z:/t0028369/Mes documents/Tools/perlprog";
$dir = $opt_d if($opt_d);
chdir ($dir) or die "$dir n est pas un directory";
 chomp $dir;
 #$dir = quotemeta $dir;
 print "$dir\n";

 processDirectory("$dir");

 exit 0;

sub processDirectory {
	$level += 1;
	#print "****LEVEL $level*************************\n";
	my $current_directory = shift;
	#print "current directory : $current_directory\n";
	if( $level < $levelMax + 1) {
		opendir(DIR, $current_directory);
		my @files = readdir(DIR);
		#print "@files\n";
 		foreach my $file (@files) {
 			next if($file =~ /^\./);
 			if ( -d $file && ! -l $file ){
			        print "****LEVEL $level*************************\n";
				print "current directory : $current_directory/$file\n";
 				#print "dir : $file\n";
 				chdir($file);
				calculTailleRep() if($level < $levelMax + 1);
 				processDirectory ("$current_directory/$file");
				chdir("..");
				#my $pwd = `pwd`;
				#print "$pwd";
				$level = $level - 1;
					
				
 			}
 			else {
 				#print "file : $file\n"
 			}
 		}		
		#$level = $level - 1;
		#chdir("..");
 		close DIR;
	}
 }

sub calculTailleRep() {
	my $taileRep ;
	$tailleRep = `du -ks .`;
	print "$tailleRep\n";
	return 0;
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


