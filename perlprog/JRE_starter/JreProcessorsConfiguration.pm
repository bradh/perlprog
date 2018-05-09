package JreProcessorsConfiguration ;
	use XML::Simple;
	use Data::Dumper;
	
	#my $dirName = "D:\\THALES\\JREM\\properties";
	my $dirName = "./";
	my $fileName = "JreProcessors.xml";
	my $jreProcessorsConfiguration;
	my $jreName;
	
	#readConfigFile();
	#$jreName = getJrepName();
	#print "jre name = $jreName\n";
	#print "$dirName\\$fileName";

	sub readConfigFile{
		print "$dirName/$fileName";
		die "Could not open $dirName\\$fileName \n" if(! -e "$dirName\\$fileName" ) ;
		$jreProcessorsConfiguration = XMLin("$dirName\\$fileName");
		print Dumper($jreProcessorsConfiguration);
  		return $jreProcessorsConfiguration;
	}
	sub getJrepName() {
		#my $jreProcessorsConfiguration = shift;
		return $jreProcessorsConfiguration->{'config_jrep'}->{'jrep_designator'};
	}

1