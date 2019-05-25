package ConfiguratorFile;

use ConfiguratorProject;
use ConfiguratorMenu;
my $rscript_dir;
my $rproject_dir;
my $rproject_file;
my $rproject_name;
my $rproject_version;
my $rprocess_list;
my $rconfigurator_data;
my $rprojectName;

						
sub init_data {
	$rscript_dir = shift;
	$rproject_dir = shift;
	$rproject_file = shift;
	$rproject_name = shift;
	$rproject_version = shift;
	$rprocess_list = shift;
	$rconfigurator_data = shift;
}

sub applyConfiguration {
	my $dirname = Tkx::tk___chooseDirectory(-initialdir => $$rproject_dir );
	$dirname =~ s/\//\\\\/g;
	print "$dirname\n";
	foreach my $process ( @$rprocess_list){
		# on recupere la version du process
		print "get process : $process\n";
		print "$$rscript_dir\n";
		my $process_version = ConfiguratorProject::getProcessVersion($process);
		print "$process_version\n";
		#On verifie la presence du repertoire template
		if( ! -d "$$rscript_dir\\Template\\$process\\$process_version"){
			print "$$rscript_dir\\Template\\$process\\$process_version\n";
			ConfiguratorMenu::acquittementAction("Sorry ! Template for $process version $process_version not available ...");
			return -1;
		}
		else{
			# On verifie la presence du repertoire cible sinon on le cree
			my $dir = "$dirname\\$$rproject_name";
			mkdir ($dir) if( ! -d $dir);
			$dir = "$dirname\\$$rproject_name\\$$rproject_version";
			mkdir ($dir) if( ! -d $dir);
			$dir = "$dirname\\$$rproject_name\\$$rproject_version\\$process";
			mkdir ($dir) if( ! -d $dir);
			chdir ($dir);
			# pour chaque fichier template , on cree un fichier cible
			opendir DIR, "$$rscript_dir\\Template\\$process\\$process_version";
			while(readdir(DIR)){
				my $file = $_;
				next if($file =~ /^\./ || $file =~ /\~$/);
				print "process $file ...\n";
				print ">$dir\\$$rproject_name\\$$rproject_version\\$process\\$file\n";
				open Fin , "<$$rscript_dir\\Template\\$process\\$process_version\\$file" or die "not possible open $$rscript_dir/Template/$process/$process_version/$file... ";;
				open Fout, ">$dirname\\$$rproject_name\\$$rproject_version\\$process\\$file" or die "not possible open $dirname/$$rproject_name/$$rproject_version/$process/$file... ";
				# Modification des @IP
				while(<Fin>){
					$line = $_;
					chomp $line;
					print "$line\n";
					if ($line =~ /\%(I\d+)\%/) {
						my $index = $1;
						print "index : $index\n";
						#print "$line\n";
						foreach my $rarray (@{$rconfigurator_data->{'IP@'}->{'NULL'}}) {
							print "$rarray->[0]\n";
							if ($rarray->[0] eq "$index") {
								#print "$line\n";
								$line =~ s/\%I\d+\%/$rarray->[2]/;
								print "index = %$index%\n : $rarray->[2]\n";
								last;
							}
						}
					}
					# Modification des ports TCP
					if ($line =~ /\%(P\d+)\%/) {
						my $index = $1;
						print "index : $index\n";
						foreach my $rarray (@{$rconfigurator_data->{'TCP port'}->{'NULL'}}) {
							print "$rarray->[0]\n";
							if ($rarray->[0] eq "$index") {
								print "$rarray->[0]\n";
								$line =~ s/\%P\d+\%/$rarray->[2]/;
								print "index = %$index%\n : $rarray->[2]\n";
								last;
							}					
						}
					}
					if ($line =~ /\%([DTJ]\d+)\%/) {
						my $index = $1;
						print "index : $index\n";
						foreach my $rarray ( @{$rconfigurator_data->{$process}->{$file}}) {
							print "mct_main.cfg $rarray->[0]\n";
							if ($rarray->[0] eq "$index") {
								#print "$line\n";
								$line =~ s/\%[DTJ]\d+\%/$rarray->[2]/;
								print "index = %$index% : $rarray->[2]\n";
								print "$line\n";
								last;
							}					
						}
					}
					print Fout "$line\n";		
				}
				close Fin;
				close Fout;
				
				# Modification des parametres propres
				foreach my $rparam_param (@{$rconfiguration_data->{'$process'}->{'$file_template'}}){
					
				} 
				
			}
			close DIR;
		}
		
	}
}

sub update_DLIP_files {
	mkdir ("$$rprojectName") if (! -d "$$rprojectName" );
	mkdir ("$$rprojectName\\DLIP")  if (! -d "$$rprojectName/DLIP" );
	foreach my $file (@DLIP_file) {
		print "process $file ...\n";
		open Fin , "<V7\\DLIP\\$file" or die "not possible open V7/DLIP/$file... ";;
		open Fout, ">$$rprojectName\\DLIP\\$file" or die "not possible open $$rprojectName/DLIP/$file... ";
		while(<Fin>){
			$line = $_;
			chomp $line;
			print "$line\n";
			if ($line =~ /\%(I\d+)\%/) {
				my $index = $1;
				print "index : $index\n";
				#print "$line\n";
				foreach my $rarray (@$rIP_address) {
					print "$rarray->[0]\n";
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%I\d+\%/$rarray->[2]/;
						print "index = %$index%\n : $rarray->[2]\n";
						last;
					}
				}
			}
			if ($line =~ /\%(P\d+)\%/) {
				my $index = $1;
				print "index : $index\n";
				foreach my $rarray (@$rTCP_port) {
					print "$rarray->[0]\n";
					if ($rarray->[0] eq "$index") {
						print "$rarray->[0]\n";
						$line =~ s/\%P\d+\%/$rarray->[2]/;
						print "index = %$index%\n : $rarray->[2]\n";
						last;
					}					
				}
			}
			if ($line =~ /\%(D\d+)\%/) {
				my $index = $1;
				print "index : $index\n";
				foreach my $rarray ( @$rDLIP_mct_main_cfg) {
					print "mct_main.cfg $rarray->[0]\n";
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%D\d+\%/$rarray->[2]/;
						print "index = %$index% : $rarray->[2]\n";
						print "$line\n";
						last;
					}					
				}
				#foreach my $rarray (@$rDLIP_mct_main_trc1) {
				#	if ($rarray->[0] eq "$index") {
				#		print "$rarray->[0]\n";
				#		#print "$line\n";
				#		$line =~ s/\%D\d+\%/$rarray->[2]/;
				#		print "index = %$index% : $rarray->[2]\n"
				#	}
				#}
				#foreach my $rarray (@$rDLIP_mct_main_trc2) {
				#	print "mct_main.trc2 $rarray->[0]\n";
				#	if ($rarray->[0] eq "$index") {
				#		print "$rarray->[0]\n";
				#		$line =~ s/\%D\d+\%/$rarray->[2]/;
				#		print "index = %$index% : $rarray->[2]\n"
				#	}
				#}			
			}
			print Fout "$line\n";		
		}
		close Fin;
		close Fout;
	}
}

sub update_TDL_ROUTER_files {
	mkdir ("$$rprojectName") if (! -d "$$rprojectName" );
	mkdir ("$$rprojectName\\TDL_ROUTER")  if (! -d "$$rprojectName\\TDL_ROUTER" );
	foreach my $file (@TDL_ROUTER_file) {
		print "process $file ...\n";
		open Fin , "<V7\\TDL_ROUTER\\$file" or die "not possible open V7\\TDL_ROUTER\\$file... ";;
		open Fout, ">$$rprojectName\\TDL_ROUTER\\$file" or die "not possible open $$rprojectName\\TDL_ROUTER\\$file... ";
		while(<Fin>){
			$line = $_;
			chomp $line;
			if ($line =~ /\%(I\d+)\%/) {
				my $index = $1;
				#print "$line\n";
				foreach my $rarray (@$rIP_address) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%I\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}
				}
			}
			if ($line =~ /\%(P\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rTCP_port) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%P\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
			}
			if ($line =~ /\%(T\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rTDL_ROUTER_tdl_router_main) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%T\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rTDL_ROUTER_l16_param) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%T\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}
				}
				foreach my $rarray (@$rTDL_ROUTER_mids_registration) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%T\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}
				}
				foreach my $rarray (@$rTDL_ROUTER_standalone) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%T\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}	
				}
				foreach my $rarray (@$rTDL_ROUTER_simple_if) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%T\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}	
				}			
			}
			print Fout "$line\n";		
		}
		close Fin;
		close Fout;
	}
}

sub update_JREP_files {
	mkdir ("$$rprojectName") if (! -d "$$rprojectName" );
	mkdir ("$$rprojectName\\JREP")  if (! -d "$$rprojectName\\JREP" );
	foreach my $file (@JREP_file) {
		print "process $file ...\n";
		open Fin , "<V7\\JREP\\$file" or  ConfiguratorMenu::acquittementAction(" V7\\JREP\\$file do not exist !");
		open Fout, ">$$rprojectName\\JREP\\$file" or ConfiguratorMenu::acquittementAction("$$rprojectName\\JREP\\$file");
		while(<Fin>){
			$line = $_;
			chomp $line;
			if ($line =~ /\%(I\d+)\%/) {
				my $index = $1;
				#print "$line\n";
				foreach my $rarray (@$rIP_address) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%I\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}
				}
			}
			if ($line =~ /\%(P\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rTCP_port) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%P\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
			}
			while ($line =~ /\%(J\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rJREP_internal_parameters) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%J\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rJREP_configuration_parameters) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%J\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rJREP_parameters) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%J\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
			}
			print Fout "$line\n";
		}
		close Fin;
		close Fout;
	}
}

sub update_Supervisor_files {
	mkdir ("$$rprojectName") if (! -d "$$rprojectName" );
	mkdir ("$$rprojectName\\Supervisor")  if (! -d "$$rprojectName\\Supervisor" );
	foreach my $file (@Supervisor_file) {
		print "process $file ...\n";
		open Fin , "<V7\\Supervisor\\$file" or  ConfiguratorMenu::acquittementAction(" V7\\Supervisor\\$file do not exist !");
		open Fout, ">$$rprojectName\\Supervisor\\$file" or ConfiguratorMenu::acquittementAction("$$rprojectName\\Supervisor\\$file");
		while(<Fin>){
			$line = $_;
			chomp $line;
			if ($line =~ /\%(I\d+)\%/) {
				my $index = $1;
				#print "$line\n";
				foreach my $rarray (@$rIP_address) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%I\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}
				}
			}
			if ($line =~ /\%(P\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rTCP_port) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%P\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
			}
			while ($line =~ /\%(S\d+)\%/) {
				my $index = $1;
				foreach my $rarray (@$rSupervisor_main) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_dlip) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_tdl_router) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_jrep) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_osim) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_tlcmgr) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
				foreach my $rarray (@$rSupervisor_jrem) {
					if ($rarray->[0] eq "$index") {
						#print "$line\n";
						$line =~ s/\%S\d+\%/$rarray->[2]/;
						#print "index = %$index%\n : $rarray->[2]\n"
					}					
				}
			}
			print Fout "$line\n";
		}
		close Fin;
		close Fout;
	}
}
1