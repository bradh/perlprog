#! /usr/bin/perl -w

#use strict;
use XML::Simple;

my $host_dico_xml = XMLin('./d_loc1_block_v96.xml', forcearray => 1);
my $r_array = [];
whatMessageIs($r_array);
exit 0;

sub whatMessageIs {
	my $r_array = shift;
	#print "\nFields messages\n"; 
	my $y =  $host_dico_xml->{formats}->[0]->{record}->{"ADH101 AIR TRACK"};	
	my $structureMsg = getStructure($y);
	#exit 0;
	#my $z = $host_dico_xml->{formats}->[0]->{record}->{"TDH442 DLIP STATUS"}->{fields}->[0]->{record};
	#foreach my $record (keys %$z){
	#	print "\nRECORD : $record : $z->{$record}\n";
	#	my $a = $z->{$record}->{fields}->[0]->{field};
	#	foreach my $field (keys %$a){
	#		print "\n$field\n";
	#		my $b = $a->{$field}; 
	#		my $structureField = {"field name" => "$field"};
	#		foreach my $key(keys %$b){
			#print "$key\n";
			#			my $c = $b->{$key};
			#	$structureField->{"$key"} = "$c";
			#	print "$key : $c\n";
			#}
			#push @$structureMsg, $structureField;
			#}
			#}
	my @ordonne = sort {$a->{(keys %$a)}->{position} <=> $b->{(keys %$b)}->{position}} (@$structureMsg);
	foreach my $field (@$structureMsg) {
		while(my($key, $value) = each (%$field)){
			print "$key\n"; 
			print "position = $value->{position} :\t longueur = $value->{length}\n";		
		}
	}
	exit 0;
	$z = $host_dico_xml->{formats}->[0]->{record}->{"TDH442 DLIP STATUS"}->{fields}->[0]->{switch};
	foreach my $record (keys %$z){
		my $x = $z->{$record};
		print "\nSWITCH : $record : $x\n";
		#browseHash ($x);
		my $a = $x->{switch}->[0]->{field}->[0]->{record};
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
	
	$z = $host_dico_xml->{formats}->[0]->{record}->{"TDH442 DLIP STATUS"};#->{array}->{array152};
	my $dir = "\$host_dico_xml->{formats}->[0]->{record}->{\"TDH442 DLIP STATUS\"}";
	#browseArray($z);
	browseHash($z, $dir);
	
	foreach my $record (keys %$z){
		my $x = $z->{$record};
		print "\nSWITCH : $record : $x\n";
		browseHash ($x);
		exit 0;
		my $a = $x->{switch}->[0]->{field}->[0]->{record};
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
}

sub getStructure{
	my $r_hash = shift;
	my $structureMsg=[];
	while(my ($key, $value) = each (%$r_hash)) {
		#print "$key : $value\n";
		if($key =~/record$/){
			print "$key -> $value\n";
			push @$structureMsg, $r_hash->{record};
		}
		if($key =~/field$/){
			print "$key -> $value\n";
			push @$structureMsg, $r_hash->{field};
		}
		if($key =~/switch$/){
			#print "$key -> $value\n";
			push @$structureMsg, $r_hash->{switch};
		}
		if ($key !~/field$/ && $key !~/switch$/){
		       	if($value =~/HASH/){
				push @$structureMsg, (@{getStructure($r_hash->{$key})});
			}
			if($value =~/ARRAY/){
				push @$structureMsg, (@{getStructure($r_hash->{$key}->[0])});
			}
		}
	}
	return $structureMsg;
}
sub browseHash {
my $r_hash = shift;
my $dir = shift;
while (my ($key, $value) = each (%$r_hash)) {

		if ($value =~/HASH/){
			browseHash($value, $dir. "->\{$key\}");
		}
		else {
			if($value =~/ARRAY/){
				browseArray($value, $dir . "->\{$key\}");
			}
			else {
				print "$dir->\{$key\}  = $value\n\n";
			}
		}
	}
}
sub browseArray {
	my $r_array = shift;
	my $dir = shift;
	my $i = 0;
	foreach my $value (@$r_array){
		if ($value =~/HASH/){
			browseHash($value, $dir. "->[$i]");
		}
		else {
			if($value =~/ARRAY/){
				browseArray($value, $dir. "->[$i]");
			}
			else {
				print " $dir->[$i] = $value\n\n";
			}
		}
		$i++;
	}
}

