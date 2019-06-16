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

my $count = 0;

$levelMax = $opt_l if($opt_l);
print "level max = $levelMax\n";

$dir = "/media/stephane/Photos1/Images/Images/";
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
 			if($file =~ s/embedded_1/embedded/){				
 				print "move $old_name, $file ?\n";
 				#<>;
 				#print `pwd`;
 				File::Copy::move($old_name, $file);
 			}
 			if ( -d $file){
 				#print "dir : $file\n";
 				chdir($file);
 				processDirectory ("$current_directory/$file");
 			}
 			else {
 				$count += 1;
 				next;
 						
  			}
 			
 	}
 	print "file count = $count\n";
 	$level -= 1;
 	chdir("..");
 	close DIR;
 }

exit 0;



