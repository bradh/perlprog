package ConfiguratorFile;

use ConfiguratorCSV;
my $debug = 1;

my $TEMPLATE_DIR = "Templates";
my $APPLICABLE_DIR = "Applicables";
my $VERSION_FILE = "GAN_Version.csv";
my $TARGET_FILE = "Machine_List.txt";
my $CONFIG_DIR = "Configuration";

my $rPROJECT_DIR;
my $rPROJECT_FILE;
my $rPROJECT_NAME;
my $rPROJECT_VERSION;
my $rprocess_list;
my $rconfigurator_data;
my $rprojectName;

my $TARGET_DIR;

						
sub init_data {
	$rPROJECT_DIR = shift;
	$rPROJECT_FILE = shift;
	$rPROJECT_NAME = shift;
	$rPROJECT_VERSION = shift;
	$rprocess_list = shift;
	$rconfigurator_data = shift;
	$TARGET_DIR = $$rPROJECT_DIR;
}

sub applyConfiguration {
	#my $dirname = Tkx::tk___chooseDirectory(-initialdir => $$rPROJECT_DIR );
	#$dirname =~ s/\/////g;
	#print "$dirname\n";	
	foreach my $process (@$rprocess_list){
		my @file_list;
		# on recupere la version du process
		print "get process : $process\n" if($debug);
		#On verifie la presence du repertoire template 
		if( ! -d "$$rPROJECT_DIR/Configuration/$TEMPLATE_DIR/$process"){
			print "$$rPROJECT_DIR/$TEMPLATE_DIR/$process not existing \n";
			exit -1;
		}
		else{
			ConfiguratorCSV::getFileList( $process, \@file_list );
			print "toto : $process, @file_list\n" if($debug);
			# On verifie la presence du repertoire cible sinon on le cree
			my $dir = "$$rPROJECT_DIR/Configuration/$APPLICABLE_DIR";
			mkdir ($dir) if( ! -d $dir);
			$dir = "$$rPROJECT_DIR/Configuration/$APPLICABLE_DIR/$process";
			mkdir ($dir) if( ! -d $dir);
			chdir ($dir);
			# pour chaque fichier template , on cree un fichier cible
			foreach my $file (@file_list){
				print "toto ::: $file $process\n" if($debug);
				#opendir DIR, "$$rPROJECT_DIR/Configuration/$TEMPLATE_DIR/$process" or die "not possible open $$rPROJECT_DIR/$TEMPLATE_DIR/$process\n";
				print "$$rPROJECT_DIR/Configuration/$TEMPLATE_DIR/$process/file\n" if($debug);
				if (-e "$$rPROJECT_DIR/Configuration/$TEMPLATE_DIR/$process/$file"){
					#exit 0;
					# on saute les fichiers commencant par un .
					#next if($file =~ /^\./ || $file =~ /\~$/);
					print "process file $file ...\n" if($debug);
					print "$dir/$file\n" if($debug);
					#exit 0;
					# on ouvre le fichier template et l'on cree le fichier applicable
					open Fin , "<$$rPROJECT_DIR/Configuration/$TEMPLATE_DIR/$process/$file" or die "not possibleopen $$rSCRIPT_DIR/Template/$process/$process_version/$file... ";;
					open Fout, ">$$rPROJECT_DIR/Configuration/$APPLICABLE_DIR/$process/$file" or die "not possible open $dirname/$$rPROJECT_NAME/$$rPROJECT_VERSION/$process/$file... ";
					# Modification des @IP
					while(<Fin>){
						$line = $_;
						chomp $line;
						#print "$line\n" if($debug);
						# on remplace l'index par sa valeur
						if ($line =~ /\%(I\d+)\%/) {
							my $index = $1;
							#print "index : $index\n" if($debug);
							#print "$line\n" if($debug);
							# on recherche l'index dans la hash table
							foreach my $rarray (@{$rconfigurator_data->{'IP@'}->{'NULL'}}) {
								#print "$rarray->[0]\n" if($debug);
								# si l'index est le bon , on le remplace par la valeur
								if ($rarray->[0] eq "$index") {
									#print "$line\n";
									$line =~ s/\%I\d+\%/$rarray->[2]/;
									#print "index = $index : $rarray->[2]\n" if($debug);
									last;
								}
							}
						}
						#exit 0;
						# Modification des ports TCP
						if ($line =~ /\%(P\d+)\%/) {
							my $index = $1;
							#print "index : $index\n" if($debug);
							foreach my $rarray (@{$rconfigurator_data->{'TCP port'}->{'NULL'}}) {
								#print "$rarray->[0], $rarray->[1], $rarray->[2]\n";
								if ($rarray->[0] eq "$index") {
									#print "$rarray->[0]\n" if($debug);
									$line =~ s/\%P\d+\%/$rarray->[2]/;
									#print "index = $index : $rarray->[2]\n"if($debug);
									last;
								}					
							}
						}
						#exit 0;
						# Modification des index specifique aux applicatifs
						if ($line =~ /\%([DTJCMFS]\d+)\%/) {
							my $index = $1;
							print "index : $index\n" if($debug);
							foreach my $rarray ( @{$rconfigurator_data->{$process}->{$file}}) {
								print "$rarray->[0]\n" if($debug);
								if ($rarray->[0] eq "$index") {
									#print "$line\n";
									$line =~ s/\%[DTJCMFS]\d+\%/$rarray->[2]/;
									print "index = $index : $rarray->[2]\n" if($debug);
									print "$line\n" if($debug);
									last;
								}					
							}
						}
						#print "entree\n";
						#<>;				
						print Fout "$line\n";		
					}
					close Fin;
					close Fout;
				}
			}
		}
	}
	return 0;
}

sub createVersionFile {
	open Fout, ">$$rPROJECT_DIR/$CONFIG_DIR/$VERSION_FILE" or die "Impossible creer $VERSION_FILE\n";	
		foreach my $process (  @{$rconfigurator_data->{'Project'}->{'NULL'}}  ){
			#while()
				print "$process->[0];$process->[1];\n" if($debug);
				print Fout "$process->[0];$process->[1];\n";
		}
	close Fout;
	return 0;
}

sub createTargetFile {
	open Fout, ">$$rPROJECT_DIR/$CONFIG_DIR/$TARGET_FILE" or die "Impossible creer $TARGET_FILE\n";	
		 	my $process =  $rconfigurator_data->{'IP@'}->{'NULL'}->[1];
			print "$process->[1];$process->[2];\n" if($debug);
			print Fout "$process->[1];$process->[2];\n";
	close Fout;
	return 0;
}

1
