open (F, "oscar.txt") || die "Could not open database: $:";
%category_index = (); %year_index = ();
while (defined($line = <F>)) {
    chomp $line;
    ($year, $category, $name) = split (/:/, $line);
    create_entry($year, $category, $name) if $name;
}

print "Entries for the year 1995:\n";
print_entries_for_year(1995);

exit(0);


sub create_entry {             # create_entry (year, category, name)
    my($year, $category, $name) = @_;
    # Create an anonymous list for each entry
    $rlEntry = [$year, $category, $name];
    # Add this to the two indexes
    push (@{$year_index {$year}}, $rlEntry);         # By Year
    push (@{$category_index{$category}}, $rlEntry);  # By Category
}  


sub print_entries_for_year {
    my($year) = @_;
    print ("Year : $year \n");
    foreach $rlEntry (@{$year_index{$year}}) {
        print ("\t",$rlEntry->[1], "  : ",$rlEntry->[2], "\n");
    }
}


sub print_all_entries_for_year {
    foreach $year (sort keys %year_index) {
        print_entries_for_year($year);
    }
}

sub print_entry {
    my($year, $category) = @_;
    foreach $rlEntry (@{$year_index{$year}}) {
        if ($rlEntry->[1] eq $category) {
            print "$category ($year), ", $rlEntry->[2], "\n";
            return;
        }
    }
    print "No entry for $category ($year) \n";
}


sub displayIPNotebook{
	my $paramFrame = $IPframe->new_ttk__frame();
	my $textFrame = $IPframe->new_ttk__frame();
	my @keys = (keys %IP_value);
	my $i = 1;
	foreach my $key (sort @keys) {
		my $label1 = $paramFrame->new_ttk__label(-text => $key,-background => 'yellow')-> g_grid(-column => 1, -row => $i);
		$label1 = $paramFrame->new_ttk__label(-text => $IP_label{$key}, -anchor => 'w', -background => 'lightblue')-> g_grid(-column => 2, -row => $i);
		my $entry = $paramFrame->new_ttk__entry(-textvariable => \$IP_value{$key})-> g_grid(-column => 3, -row => $i);
		$i++;
	}
	(my $lb = $textFrame->new_tk__text(-width => 5, -height => 5))->g_grid(-column => 5, -row => 0, -sticky => "nwes");
	(my $s = $textFrame->new_ttk__scrollbar(-command => [$lb, "yview"], 
        -orient => "vertical"))->g_grid(-column =>6, -row => 0, -sticky => "ns");
	$lb->configure(-yscrollcommand => [$s, "set"]);
	
	for ($i=0; $i<100; $i++) {
  	 	$lb->insert("end", "Line " . $i . " of 100");
	}
	$paramFrame->g_grid(-column => 1, -row => 1);
	$textFrame->g_grid(-column => 2, -row => 1);
}

sub displayTCPportNotebook{
	my @keys = (keys %TCP_port_value );
	my $i = 1;
	foreach my $key (sort @keys) {
		my $label1 = $TCPframe->new_ttk__label(-text => $key,-background => 'yellow')-> g_grid(-column => 1, -row => $i);
		$label1 = $TCPframe->new_ttk__label(-text => $TCP_port_label{$key}, -anchor => 'w', -background => 'lightblue')-> g_grid(-column => 2, -row => $i);
		my $entry = $TCPframe->new_ttk__entry(-textvariable => \$TCP_port_value{$key})-> g_grid(-column => 3, -row => $i);
		$i++;
	}
}

sub process_toplink_configuration_file {
	open Fin, "<TDL_ROUTER/tdl_router_main.cfg" or die "file do not exist";
	open Fout, ">temp_file.cfg" or die "could not create file";
	while (<Fin>){
		my $line = $_;
		print "$line";
		$line =~ s/%(I\d\d)%/$IP_value{$1}/;
		$line =~ s/%(P\d\d)%/$TCP_port_value{$1}/;
		print Fout "$line";
	}
	close Fin;
	close Fout;
	open Fin, "<JREP/param_jrep.xml" or die "file do not exist";
	open Fout, ">temp_file2.cfg" or die "could not create file";
	while (<Fin>){
		my $line = $_;
		print "$line";
		$line =~ s/%(I\d\d)%/$IP_value{$1}/;
		$line =~ s/%(P\d\d)%/$TCP_port_value{$1}/;
		print Fout "$line";
	}
	close Fin;
	close Fout;
}



sub display_IP_value {
	my @key = (keys %IP_value);
	foreach my $key (@key){
		print "$IP_value{$key}, $key\n"; 
	}
}

sub display_IP_label {
	my @key = keys %IP_value;
	foreach my $key (@key){
		print "$IP_label{$key}, $key\n"; 
	}
}
