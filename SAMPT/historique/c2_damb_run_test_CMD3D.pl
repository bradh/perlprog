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
				print "run $file";
				$duration  = `cat duration.info`;
				chomp $duration;
				print "Durée du test $duration sec...\n";
				system("./martha_launcher $duration normal");
				system("compas");
				chdir("..");
				sleep 10;
			}			
		}
	close DIR;
	exit 0;



