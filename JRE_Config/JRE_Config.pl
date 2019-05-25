#!/usr/bin/perl -w

  use XML::Simple;
  use Data::Dumper;
	
	use Tkx;
    use strict;

  my $jrep_config = XMLin('.\\jrep_configuration_file.xml');
  print Dumper($jrep_config);
  my $jrep_internal_config = XMLin('.\\jrep_internal_file.xml');
  print Dumper($jrep_internal_config);
   
# Main window Take top and the bottom - now implicit top is in the middle
    	my $mw = MainWindow->new;
    	$mw->title( "Local JREP Configuration" );
    	#$mw->Label(-text => "Local JREP Configuration")->pack;
    	my $i =0;
    	my @label;
    	my @entry;
    	my @Hframe;
    	parcourirHash($jrep_config);
    	parcourirHash($jrep_internal_config);
    	$Hframe[$i]=$mw->Frame(-side => 'top');

    	MainLoop();
    	exit 0;
  
sub parcourirHash{
    		my $r_hash = shift;
    		foreach my $param (keys %{$r_hash}) {
    	 		my $value =  $r_hash->{$param};
    	 		print "$i : $value\n";
    	 		if($value =~ /HASH/){
    	 			$Hframe[$i]=$mw->Frame->pack(-side => 'top');
    	 			$label[$i]=$Hframe[$i]->Label(-text =>"$param ",-anchor => 'e', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
    	 			$i=$i+1;
    	 			parcourirHash($value);
    	 		}
    	 		else {	
    				$Hframe[$i]=$mw->Frame->pack(-side => 'top');
   	 				$label[$i]=$Hframe[$i]->Label(-text =>"$param ",-anchor => 'e', -width => 25)->pack(-side =>'left', -padx => 0, -anchor =>'n');
 					$entry[$i]=$Hframe[$i]->Entry(-text => "$value", -relief => 'sunken', -width => 25
						)->pack(-side => 'left', -padx => 0, -anchor =>'n');
					$i=$i+1;
    	 		}
    		}
		}	
 