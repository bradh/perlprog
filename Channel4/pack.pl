#! /usr/bin/perl -w

use strict;
use XML::Simple;
my $host_dico_xml;

while (1) {
print "Entrer une valeur :\n";
my $value = <>;
my $string =uc unpack("H8", pack("N", $value));
print "$string\n";
$string = hex($string);
print "$string\n";
}
exit 0;

sub whatMessageIs {
	my $r_array = shift;
	
	#my $host_dico_xml = XMLin('./d_loc1_block_v96.xml', forcearray => 1);
	#print "$host_dico_xml\n\n";


	print "\nFields messages\n"; 
	my $y =  $host_dico_xml->{formats}->[0]->{record}->{"ADH101 AIR TRACK"};
	foreach my $field (keys %$y){
		my $v = $y->{$field};
		print "$field : $v\n";
	}
	#print "Record :\n";	
	my $z = $host_dico_xml->{formats}->[0]->{record}->{"ADH101 AIR TRACK"}->{fields}->[0]->{record};
	foreach my $record (keys %$z){
		my $x = $z->{$record};
		print "\nRECORD : $record : $x\n";
		my $a = $x->{fields}->[0]->{field};
		foreach my $field (keys %$a){
			print "\n$field\n";
			my $b = $a->{$field};
			foreach my $key(keys %$b){
			#print "$key\n";
				my $c = $b->{$key};
				print "$key : $c\n";
			}
		}
	}
	my $w = $y->{fields}->[0]->{field};
	foreach my $field (%$w){
		my $r = $w->{$field};
		print "\nFIELD : $field\n";
		foreach my $key (%$r){
			my $value = $r->{$key};
			print "$key : $value\n" if (defined($value)&& defined($key));
		}
		#print "$field : $r\n";
	}
	exit;
	

		
	#browseArray($a);
	#browseHash($a);
	#print "$a\n";
}

#->{"HOST ICD FOR THE DLIP SOFTWARE PRODUCT LINE"}
#->{mip}
#->[0]
#->{messages}
#->[0]
#->{message}
#->{"AHD104 SYSTEM LAND POINT"}
#->{format}
#->[0]
#->{reference}
#->[0];
sub browseHash {
my $r_hash = shift;
foreach my $key (keys %$r_hash) {
		print "Key : $key\n";
		my $a = $r_hash->{$key};
		print "Value : $a\n\n";
		if ($key =~/HASH/){
			#browseHash($key);
		}
		if ($a =~/HASH/){
			#	browseHash($a);
		}
		if($a =~/ARRAY/){
			#browseArray($a);
		}
	}
}
sub browseArray {
	my $r_array = shift;
	foreach my $value (@$r_array){
		print "Array : $value\n\n";
		if ($value =~/HASH/){
			#browseHash($value);
		}
		if($value =~/ARRAY/){
			#browseArray($value);
		}
	}
}

#print "$host_dico_xml\n\n";

#my $a = $host_dico_xml
#->{dictionary}
#->{"HOST ICD FOR THE DLIP SOFTWARE PRODUCT LINE"}
#->{mip}
#->[0]
#->{messages}
#->[0]
#->{message}
#->{"AHD104 SYSTEM LAND POINT"}
#->{format}
#->[0]
#->{reference}
#->[0];
##browseArray($a);
#browseHash($a);
#print "$a\n";
