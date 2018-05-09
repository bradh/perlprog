package ConfiguratorFile;

use ConfiguratorMenu;

my $rprojectName;
my $rIP_address;
my $rTCP_port;
my $rprocess_list;
my $rDLIP_mct_main_cfg;
#my $rDLIP_mct_main_trc1;
#my $rDLIP_mct_main_trc2;
my $rTDL_ROUTER_tdl_router_main;
my $rTDL_ROUTER_l16_param;
my $rTDL_ROUTER_mids_registration;
my $rTDL_ROUTER_standalone;
my $rTDL_ROUTER_simple_if;
my $rJREP_internal_parameters;
my $rJREP_configuration_parameters;
my $rJREP_parameters;
my $rSupervisor_main;
my $rSupervisor_dlip;
my $rSupervisor_tdl_router;
my $rSupervisor_jrep;
my $rSupervisor_jrem;
my $rSupervisor_tlcmgr;
my $rSupervisor_osim;

my @DLIP_file = ( 	"mct_main.cfg"
					#"mct_main.trc"
					);

my @TDL_ROUTER_file = ( "tdl_router_main.cfg",
						"L16_master.Param",
						"midsRegistration.xml",
						"standalone_master.xml",
						"SIMPLE_IF.xml");
						
my @JREP_file = ( 	"jrep_internal_parameters.xml",
					"jrep_configuration_parameters.xml",
					"parameters.txt");
					
my @Supervisor_file = ("MINT_JFACC_supervisor - V1R2E3_template.pl");
						
sub init {
	$rprojectName = shift;
	$rIP_address = shift;
	$rTCP_port = shift;
	$rprocess_list = shift;
	$rDLIP_mct_main_cfg= shift;
	#$rDLIP_mct_main_trc1 = shift;
	#$rDLIP_mct_main_trc2 = shift;
	$rTDL_ROUTER_tdl_router_main = shift;
	$rTDL_ROUTER_l16_param = shift;
	$rTDL_ROUTER_mids_registration = shift;
	$rTDL_ROUTER_standalone = shift;
	$rTDL_ROUTER_simple_if = shift;
	$rJREP_internal_parameters = shift;
	$rJREP_configuration_parameters = shift;
	$rJREP_parameters = shift;
	$rSupervisor_dlip = shift;
	$rSupervisor_tdl_router = shift;
	$rSupervisor_jrep = shift;
	$rSupervisor_osim = shift;
	$rSupervisor_tlcmgr = shift;
	$rSupervisor_jrem = shift;
}

sub update_DLIP_files {
	mkdir ("$$rprojectName") if (! -d "$$rprojectName" );
	mkdir ("$$rprojectName/DLIP")  if (! -d "$$rprojectName/DLIP" );
	foreach my $file (@DLIP_file) {
		print "process $file ...\n";
		open Fin , "<V7/DLIP/$file" or die "not possible open V7/DLIP/$file... ";;
		open Fout, ">$$rprojectName/DLIP/$file" or die "not possible open $$rprojectName/DLIP/$file... ";
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
	mkdir ("$$rprojectName/TDL_ROUTER")  if (! -d "$$rprojectName/TDL_ROUTER" );
	foreach my $file (@TDL_ROUTER_file) {
		print "process $file ...\n";
		open Fin , "<V7/TDL_ROUTER/$file" or die "not possible open V7/TDL_ROUTER/$file... ";;
		open Fout, ">$$rprojectName/TDL_ROUTER/$file" or die "not possible open $$rprojectName/TDL_ROUTER/$file... ";
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
	mkdir ("$$rprojectName/JREP")  if (! -d "$$rprojectName/JREP" );
	foreach my $file (@JREP_file) {
		print "process $file ...\n";
		open Fin , "<V7/JREP/$file" or  ConfiguratorMenu::acquittementAction(" V7/JREP/$file do not exist !");
		open Fout, ">$$rprojectName/JREP/$file" or ConfiguratorMenu::acquittementAction("$$rprojectName/JREP/$file");
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
	mkdir ("$$rprojectName/Supervisor")  if (! -d "$$rprojectName/Supervisor" );
	foreach my $file (@Supervisor_file) {
		print "process $file ...\n";
		open Fin , "<V7/Supervisor/$file" or  ConfiguratorMenu::acquittementAction(" V7/Supervisor/$file do not exist !");
		open Fout, ">$$rprojectName/Supervisor/$file" or ConfiguratorMenu::acquittementAction("$$rprojectName/Supervisor/$file");
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