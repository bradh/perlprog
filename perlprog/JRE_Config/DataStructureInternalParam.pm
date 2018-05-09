package DataStructureInternalParam;

use XML::Simple;
use Data::Dumper;

my $initialFile = "jrep_internal_file.xml";
my $JREP_Internal_Configuration;

sub new {
	$JREP_Internal_Configuration = XMLin("$initialFile", ForceArray => ['config_jrep', 'track_number', 'jrep_ip_link']);
  	print Dumper($JREP_Internal_Configuration);
  	exit 0;
	
}

1