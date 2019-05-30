#!/usr/bin/perl -w

# Definir le nom du test
	opendir DIR , ".";
	@dir = readdir(DIR);
		foreach $dir (@dir) {	
			next if($dir =~ /^\./);
			next if($dir =~ /^_/);
			if(-d $dir){
				chdir $dir;
				$file = `pwd`; 
				print $file;
				system("../../configTest.sh");
				chdir("..");
			}			
		}
	close DIR;
	exit 0;



