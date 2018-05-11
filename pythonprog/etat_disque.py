'''
Created on 8 mai 2018

@author: root
'''
import sys
import fileinput

import os.path
from os import *

import subprocess

sum3 = 0
levelMax = 3
output=subprocess.check_output("dmesg | grep hda", shell=True)
print (output)
dirname = sys.argv[1]
#if os.path.exists(dirname):
#    print '{0} exits'.format(dirname)
#dirname = sys.argv[1]
dirname = "."

for path, dirs, files in os.walk(dirname):
    print ("Liste des chemins")
    output = subprocess.check_output(["ls", "-l", path])
    print (path, output)
'''
    print "Liste des directories"
    for dir in dirs:
        print dir
    print "Liste des fichiers"
    for filename in files:
        print(filename)
 '''
   


levelMax = int(sys.argv[2])

print ('file name is {0}'.format(dirname))
print ('level max = {0}'.format(levelMax))




'''
$dir = "Z:/t0028369/Mes documents/Tools/perlprog";
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
    opendir(DIR, $current_directory);
    my @files = readdir(DIR);
    $level += 1;
    print "****LEVEL $level*************************\n";
     foreach my $file (@files) {
             next if($file =~ /^\./);
             if ( -d $file){
                 print "dir : $file\n";
                 chdir($file);
                 processDirectory ("$current_directory/$file");
             }
             else {
                 print "file : $file\n"
             }
             
     }
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
'''