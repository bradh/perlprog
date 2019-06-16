#!:usr/bin/perl

use Getopt::Std;
#use Digest qw(md5_hex);
use Digest::MD5 qw( md5_hex );
use File::Basename;
use File::Copy;

getopts("d:l:");

my $sum = 0;
my $levelMax = 3;
local $level = 0;

$levelMax = $opt_l if($opt_l);
print "level max = $levelMax\n";

$dir = "/mnt/stephane/Photos/Photos";
chdir ($dir) or die "$dir n est pas un directory";
$dir = $opt_d if($opt_d);
 chomp $dir;
 #$dir = quotemeta $dir;
 print "$dir\n";

 processDirectory("$dir");

 exit 0;

sub processDirectory {
	my $current_directory = shift;
	print "current directory : $current_directory\n";
	my $old_dir = $current_directory;
	opendir(DIR, $current_directory);
	my @files = readdir(DIR);
	$level += 1;
	my @files2compare;
	print "****LEVEL $level*************************\n";
 	foreach my $file (@files) {
 			next if($file =~ /^\./);
 			my $old_name = $file;
 			if($file =~ s/é/e/g | $file =~ s/è/e/g | $file =~ s/ê/e/g | $file =~ s/ë/e/g | $file =~ s/à/a/g | $file =~ s/\s/_/g){				
 				print "move $old_name, $file ?\n";
 				#<>;
 				print `pwd`;
 				File::Copy::move($old_name, $file);
 			}
 			if ( -d $file){
 				print "dir : $file\n";
 				chdir($file);
 				processDirectory ("$current_directory/$file");
 			}
 			else {
 				#print "file : $file\n";
 				
 				
 #				open my $fh, '<', $file;
#my $md5 = Digest::MD5->new->addfile($fh)->hexdigest;
#close $fh;

 				open my $handle, "<$file" or die "impossible open $file\n";
 				
 				my $hash = Digest::MD5->new->addfile($handle)->hexdigest;
 				#$hash = $hash->addfile($handle)->md5_hex();
 				#	print $handle;
 				close $handle;
 				my $old_name = $file;
 				if($file =~ s/é/e/g | $file =~ s/è/e/g | $file =~ s/ê/e/g | $file =~ s/ë/e/g | $file =~ s/à/a/g  | $file =~ s/â/a/g | $file =~ s/\s/_/g){
 					
 					print "rename $old_name, $file ?\n";
 					#<>;
 					print `pwd`;
 					rename $old_name, $file;
 				}
 				next if($file =~ /\.pp3$/);
 				# on vérifie :
 				# qu'aucun fichier n' a le même nom
 				my $toAdd = 1;
 				foreach my $tab_file (@files2compare){
 					# si il a le même nom et la même signature => on supprime le fichier
 					if($tab_file->{'name'} eq $file && $tab_file->{'fingerprint'} eq $hash){
 						#system("rm -f $file");
 						print "suppression fichier $file\n";
 						unlink $file;
 						$toAdd = 0;
 						#<>;
 					}
 					# si il a le même nom mais pas la même signature => on renomme le fichier avec un indice
 					if($tab_file->{'name'} eq $file && $tab_file->{'fingerprint'} ne $hash){
 						#system("rm -f $file");
 						my ($file_name, $file_ext) = fileparse($file);
 						print "renommer  fichier $file -> $file_name_02\.$file_ext\n";
 						File::Copy::move($file, "$file_name_02\.$file_ext");
 						$toAdd = 1;
 						#<>;
 					}
 					# si il n'a pas le même nom et qu'il a la même signature => on supprime le fichier
 					if($tab_file->{'name'} ne $file && $tab_file->{'fingerprint'} eq $hash){
 						#system("rm -f $file");
 						print "Suppression du fichier $file ?\n";
 						unlink $file;
 						$toAdd = 0;
 						#<>;
 					}
 				}
 							
 				# qu'aucun fichier n'a la même signature
 				
 				#print "fingerprint  :  $hash\n";
 				
 				push @files2compare, {'name' => $file,
 										'fingerprint' => $hash
 				} if($toAdd);
 						
  			}
 			
 	}
 	
 	foreach my $file (@files2compare){
 		print $file->{'name'} . "\t\t";
 		#my $fingerprint = $file->{'fingerprint'};
 		#print $$fingerprint;
 		print "$file->{'fingerprint'}\n"
 	}
 	#<>;
 	$level -= 1;
 	chdir("..");
 	close DIR;
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


