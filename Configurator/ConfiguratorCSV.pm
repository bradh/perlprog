package ConfiguratorCSV;
# Read and populate the hash variable

use ConfiguratorMenu;

my $rPROJECT_DIR;
my $rPROJECT_FILE;
my $rPROJECT_NAME;
my $rPROJECT_VERSION;
my $rproject_param;
my $rIP_address;
my $rTCP_port;
my $rprocess_list;
my $rconfigurator_data;
my @project_data;

# prototype de la variable $rconfigurator_data
# $rconfigurator_data = { 'process_name' =>	{'configuration_file' => [
#						  												[0, 1 , 2]				  												
#						  											 ]
#						  					}
#						  };

sub init_data {
	$rPROJECT_DIR = shift;
	$rPROJECT_FILE = shift;
	$rPROJECT_NAME = shift;
	$rPROJECT_VERSION = shift;
	$rprocess_list = shift;
	$rconfigurator_data = shift;

	open Fin, "<$$rPROJECT_DIR\\$$rPROJECT_FILE" or die "file $$rPROJECT_DIR\\$$rPROJECT_FILE do not exist";
# Lecture du fichier CSV ligne par ligne
	my $i = 0;
	while(<Fin>){
		chomp;
		$project_data[$i] = $_;
		$i++;
	}
	close Fin;
	# init process list
	getProcessList();
	# init project data, IP @, TCP port
	my @line0;
	@line0 = (split ";" , $project_data[0]);
	$rconfigurator_data->{$line0[0]} = {
										'NULL' => []
	};
	$rconfigurator_data->{$line0[3]} = {
										'NULL' => []
	};
	$rconfigurator_data->{$line0[6]} = {
										'NULL' => []
	};
	# initailisa
	my @line;
	foreach my $i (0..2){
		my $col = $i*3;
		foreach my $j (1..($#project_data)){
			@line = (split ";" , $project_data[$j]);
			#print "nber col : $#line0\n";
			#print "nber col : $#line, $col \n";
			if($line[$col] ne  "0" ){
				$rconfigurator_data->{$line0[$col]}->{'NULL'}->[$j] = [];
				@{$rconfigurator_data->{$line0[$col]}->{'NULL'}->[$j]} = ($line[$col], $line[$col+1], $line[$col+2]);
				#print "$line0[$col]\n";
				#print "$line[$col], $line[$col+1], $line[$col+2]\n";
				#print "$rconfigurator_data->{$line0[$col]}->{\"NULL\"}->[$j]->[1]\n";
			}
			else {
				last;
			}
		}
	}
	#print "process list 2 = @$rprocess_list\n";
	foreach my $process (@$rprocess_list){
		my @fileList;
		#print "init $process\n";
		# initialize  of process
		# $rconfigurator_data = { 'process_name' =>	{'configuration_file' => [
		#						  												[0, 1 , 2]				  												
		#						  											 ]
		#						  					}
		#						};
		$rconfigurator_data->{$process} = {} ;
		getFileList($process, \@fileList);
		foreach my $file (@fileList) {
			#print "file $file !\n";
			$rconfigurator_data->{$process}->{$file} = [];
		}
	}

	# init project data
	foreach my $processus (keys %$rconfigurator_data) {
		print "Process $processus...\n";	
		foreach my $file (keys %{$rconfigurator_data->{$processus}}){
			#print "\tprocess file $file ...\n";
			#exit 0;		
			foreach my $j (0..int($#line0/3)){
				my $col = $j*3;
				if( $line0[$col] eq $processus && $line0[$col+1] eq $file){
					foreach my $i (1..($#project_data-1)){
						@line = (split ";" , $project_data[$i]);
						#print "nber col : $#line0\n";
						#print "nber col : $#line, $col \n";
						if($line[$col] ne  "0" ){
							$rconfigurator_data->{$processus}->{$file}->[$i] = [];
							@{$rconfigurator_data->{$processus}->{$file}->[$i]} = ($line[$col], $line[$col+1], $line[$col+2]);
					
						}
						else {
							last;
						}
					}
				}
			}
		}
	}
}

sub saveasProject{
	my $dirname = $rPROJECT_FILE_2;
	#my $dirname = Tkx::tk___chooseDirectory(-initialdir => $$rPROJECT_DIR );
	$dirname =~ s/\//\\\\/g;
	print "$dirname\n";
	#print "$dirname";
	chdir $dirname;
	mkdir "$$rPROJECT_NAME" if (! -d $$rPROJECT_NAME);
	chdir $$rPROJECT_NAME;
	mkdir "$$rPROJECT_VERSION" if (! -d $$rPROJECT_VERSION);
	chdir $$rPROJECT_NAME;
	$$rPROJECT_DIR = "$dirname\\$$rPROJECT_NAME\\$$rPROJECT_VERSION";
	print "$$rPROJECT_DIR\n";
	if( -d $$rPROJECT_DIR){
		saveProject() ;
	}else {
		ConfiguratorMenu::confirmAction("Project not save : unknown dir $$rPROJECT_DIR ");
	}
	return 0;
}

sub saveProject{
	open Fout, ">$$rPROJECT_DIR\\tmp.csv" or die "file $$rPROJECT_DIR\\$$rPROJECT_FILE do not exist";
	# calcul du nombre de ligne max @project_data
	# Pour toutes les lignes de 0 à max , on joint les 3 valeurs du tableau @{$rconfigurator_data->{$processus}->{$file}->[$i]}
	# Si le n° de ligne est supérieur à la taille du tableau $#{$rconfigurator_data->{$processus}->{$file}->[]}, on remplace par la valeur 0;
	my @config_file_array;
	my @line0;
	@line0 = (split ";" , $project_data[0]);
	my @col_array0 = (@line0[0..8]);
	foreach $process (@$rprocess_list){
		foreach my $config_file (keys %{$rconfigurator_data->{$process}}){
			push @config_file_array, $config_file;
		}
		@config_file_array = sort (@config_file_array);
		foreach $config_file (@config_file_array){
			push @col_array0,  $process;
			push @col_array0,  $config_file;
			push @col_array0,  "";
		}
	}
	my $first_line = join ';' , ( @col_array0);
	print Fout "$first_line\n";
	foreach my $line (1..$#project_data){
		my @col_array = ();
		# init project data, IP @, TCP port
		foreach my $j (0..2){
			if ( $line <= $#{$rconfigurator_data->{$line0[$j*3]}->{'NULL'}} ){
				push @col_array,  $rconfigurator_data->{$line0[$j*3]}->{'NULL'}->[$line][0];
				push @col_array,  $rconfigurator_data->{$line0[$j*3]}->{'NULL'}->[$line][1];
				push @col_array,  $rconfigurator_data->{$line0[$j*3]}->{'NULL'}->[$line][2];
			}
			else{
				push @col_array, 0;
				push @col_array, 0;
				push @col_array, 0;
			}
		}
		foreach $process (@$rprocess_list){
			my @config_file_array = ();
			foreach my $config_file (keys %{$rconfigurator_data->{$process}}){
				push @config_file_array, $config_file;
			}
			@config_file_array = sort (@config_file_array);
			foreach $config_file (@config_file_array){
				#print "$process, $config_file, $line\n";
				#print "$rconfigurator_data->{$process}->{$config_file}->[$line][0]\n";
				if ( $line < $#{$rconfigurator_data->{$process}->{$config_file}} ){
					push @col_array,  $rconfigurator_data->{$process}->{$config_file}->[$line][0];
					push @col_array,  $rconfigurator_data->{$process}->{$config_file}->[$line][1];
					push @col_array,  $rconfigurator_data->{$process}->{$config_file}->[$line][2];
				}
				else{
					push @col_array, 0;
					push @col_array, 0;
					push @col_array, 0;
				}
			}
		}
		my $new_line = join ';', (@col_array);
		print "$new_line\n";
		print Fout "$new_line\n";
	}
	close Fout;
	print "\n\nxcopy  $$rPROJECT_DIR\\tmp.csv $$rPROJECT_DIR\\configurator_$$rPROJECT_NAME.csv\n";
	system("xcopy  $$rPROJECT_DIR\\tmp.csv $$rPROJECT_DIR\\configurator_$$rPROJECT_NAME.csv");
}

sub displayAllParameters {
	foreach my $process (keys %$rconfigurator_data) {
			print "$process\n";
			
			foreach my $param (1.. $#{$rconfigurator_data->{$process}->{'NULL'}}){
				print "$rconfigurator_data->{$process}->{'NULL'}->[$param]->[0]\n";
				print "$rconfigurator_data->{$process}->{'NULL'}->[$param]->[1]\n";
				print "$rconfigurator_data->{$process}->{'NULL'}->[$param]->[2]\n";
			}	
	}
	foreach my $process (@$rprocess_list) {
		foreach my $file (keys %{$rconfigurator_data{$process}}){	
			foreach my $param (1.. $#{$rconfigurator_data->{$process}->{$file}}){
				print "$rconfigurator_data->{$process}->{$file}->[$param]->[0]\t";
				print "$rconfigurator_data->{$process}->{$file}->[$param]->[1]\t";
				print "$rconfigurator_data->{$process}->{$file}->[$param]->[2]\n";
			}	
		}
	}
}

sub getProcessList(){
	my @line = (split ";" , $project_data[0]);
	my $i = 3;
	my $process = 'NULL';
	while ( 3*$i < $#line ) {
		print "$process -> $line[$i*3],\n";
		push @$rprocess_list, $line[$i*3] if($process ne "$line[$i*3]" );
		$process = $line[$i*3];
		$i++;
	}
	#print "process list  = @$rprocess_list\n";
	return 1;
}

sub getFileList(){
	my $process = shift;
	my $rfile_list = shift;
	my @line = (split ";" , $project_data[0]);
	my $i = 3;
	while ( 3*$i < ($#line -1) ) {
		push @$rfile_list , $line[$i*3+1] if($process eq "$line[$i*3]" && $line[$i*3+1] !~ /^\s*$/);
		$i++;
	}
	#print " process file list  : $process :  @$rfile_list\n";
	return 1;
}

sub cleanValue(){
	my $value = shift;
	print "$value\n";
	$value =~ s/^\s*//;
	$value =~ s/\s*$//;
	$value =~ s/§/;/g;
	print "$value\n";
	return $value;
}

1