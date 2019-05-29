package ConfiguratorFile;

my $TEMPLATE_DIR = "Templates";
my $APPPLICABLE_DIR = "Applicable";

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
	
	my $TARGET_DIR = $$rPROJECT_DIR;
}

sub applyConfiguration {
	#my $dirname = Tkx::tk___chooseDirectory(-initialdir => $$rPROJECT_DIR );
	#$dirname =~ s/\//\\\\/g;
	#print "$dirname\n";
	foreach my $process ( @$rprocess_list){
		# on recupere la version du process
		print "get process : $process\n";
		#On verifie la presence du repertoire template 
		if( ! -d "$$rPROJECT_DIR\\$TEMPLATE_DIR\\$process"){
			print "$$rPROJECT_DIR\\$TEMPLATE_DIR\\$process not existing \n";
			exit -1;
		}
		else{
			# On verifie la presence du repertoire cible sinon on le cree
			my $dir = "$TARGET_DIR\\$APPLICABLE_DIR";
			mkdir ($dir) if( ! -d $dir);
			$dir = "$TARGET_DIR\\$APPLICABLE_DIR\\$process";
			mkdir ($dir) if( ! -d $dir);
			chdir ($dir);
			# pour chaque fichier template , on cree un fichier cible
			opendir DIR, "$$rPROJECT_DIR\\$TEMPLATE_DIR\\$process";
			while(readdir(DIR)){
				my $file = $_;
				# on saute les fichiers commencant par un .
				next if($file =~ /^\./ || $file =~ /\~$/);
				print "process $file ...\n";
				print ">$dir\\$APPLICABLE_DIR\\$process\\$file\n";
				# on ouvre le fichier template et l'on crée le fichier applicable
				open Fin , "<$$rPROJECT_DIR\\$TEMPLATE_DIR\\$process\\$file" or die "not possible open $$rSCRIPT_DIR/Template/$process/$process_version/$file... ";;
				open Fout, ">$TARGET_DIR\\$APPLICABLE_DIR\\$process\\$file" or die "not possible open $dirname/$$rPROJECT_NAME/$$rPROJECT_VERSION/$process/$file... ";
				# Modification des @IP
				while(<Fin>){
					$line = $_;
					chomp $line;
					print "$line\n";
					# on remplace l'index par sa valeur
					if ($line =~ /\%(I\d+)\%/) {
						my $index = $1;
						print "index : $index\n";
						#print "$line\n";
						# on recherche l'index dans la hash table
						foreach my $rarray (@{$rconfigurator_data->{'IP@'}->{'NULL'}}) {
							print "$rarray->[0]\n";
							# si l'index est le bon , on le remplace par la valeur
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
					# Modification des index specifique aux applicatifs
					if ($line =~ /\%([DTJC]\d+)\%/) {
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
	mkdir ("$APPLICABLE_DIR") if (! -d "$APPLICABLE_DIR" );
	mkdir ("$APPLICABLE_DIR\\DLIP")  if (! -d "$APPLICABLE_DIR/DLIP" );
	foreach my $file (@DLIP_file) {
		print "process $file ...\n";
		open Fin , "<V7\\DLIP\\$file" or die "not possible open V7/DLIP/$file... ";;
		open Fout, ">$APPLICABLE_DIR\\DLIP\\$file" or die "not possible open $APPLICABLE_DIR/DLIP/$file... ";
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
	mkdir ("$APPLICABLE_DIR") if (! -d "$APPLICABLE_DIR" );
	mkdir ("$APPLICABLE_DIR\\TDL_ROUTER")  if (! -d "$APPLICABLE_DIR\\TDL_ROUTER" );
	foreach my $file (@TDL_ROUTER_file) {
		print "process $file ...\n";
		open Fin , "<V7\\TDL_ROUTER\\$file" or die "not possible open V7\\TDL_ROUTER\\$file... ";;
		open Fout, ">$APPLICABLE_DIR\\TDL_ROUTER\\$file" or die "not possible open $APPLICABLE_DIR\\TDL_ROUTER\\$file... ";
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
	mkdir ("$APPLICABLE_DIR") if (! -d "$APPLICABLE_DIR" );
	mkdir ("$APPLICABLE_DIR\\JREP")  if (! -d "$APPLICABLE_DIR\\JREP" );
	foreach my $file (@JREP_file) {
		print "process $file ...\n";
		open Fin , "<V7\\JREP\\$file" or  ConfiguratorMenu::acquittementAction(" V7\\JREP\\$file do not exist !");
		open Fout, ">$APPLICABLE_DIR\\JREP\\$file" or ConfiguratorMenu::acquittementAction("$APPLICABLE_DIR\\JREP\\$file");
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
	mkdir ("$APPLICABLE_DIR") if (! -d "$APPLICABLE_DIR" );
	mkdir ("$APPLICABLE_DIR\\Supervisor")  if (! -d "$APPLICABLE_DIR\\Supervisor" );
	foreach my $file (@Supervisor_file) {
		print "process $file ...\n";
		open Fin , "<V7\\Supervisor\\$file" or  ConfiguratorMenu::acquittementAction(" V7\\Supervisor\\$file do not exist !");
		open Fout, ">$APPLICABLE_DIR\\Supervisor\\$file" or ConfiguratorMenu::acquittementAction("$APPLICABLE_DIR\\Supervisor\\$file");
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