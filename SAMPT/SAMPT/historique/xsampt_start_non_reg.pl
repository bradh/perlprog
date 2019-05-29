    #!/usr/bin/perl -w
    use Tk;
    use strict;
    my $debug = 1;

    my $rootDir="/h7_usr/sil2_usr/samptivq/tests";
    my $testDir="$rootDir/tests";
    my $configFileDir="reference_ATP/fichiers_communs";
    my $testListFile="sampt_non_reg_test_list.txt";
	my $version="SAMPT_V5";


# Main window Take top and the bottom - now implicit top is in the middle
    	my $mw = MainWindow->new;
    	$mw->title( "$0" );
    	$mw->Label(-text => "xsampt_start_non_reg.pl lance un test sampt avec les options suivantes :")->pack;
	my @testList;
	my @Hframe;
    	my @frame;
	my @rackCible = ("rack_P0");
	my $rack;
	my @testConfigList = ("C2","NON_C2");
	my $testConfig;
	my $configNbr;
	my $testName;
	my @testEnvList =("T_AUTOMATION");
	my $testEnv;
	my $r_test;
	my $testIndex;
	my @buttonTestResult;
       	my $ent;
 	my @entry;
	my @label;
       	my %hash;
       	my @configFile; #=( "Aladdin_Out.conf",  		"Aladdin_In.conf", "Aladdin_Out2.conf",      		"Aladdin_In2.conf", "Aladdin_Out.conf");
	my $Hframe1=$mw->Frame->pack;
	$Hframe1->Label(-text => 'Rack cible:')->pack(-side => 'left');
   	my $lbRack = $Hframe1->Listbox(	-width => 10,   
	    				-relief => 'sunken',
					-height  => 1,
					-listvariable => "@rackCible");
				
	my $scRack = $Hframe1->Scrollbar(-orient => 'vertical',
				-command => ['yview', $lbRack]);
	$lbRack->configure(-yscrollcommand => ['set', $scRack]);
	$lbRack->pack(-side => 'left', -fill => 'x', -expand => 1);
        $scRack->pack(-side => 'left', -fill => 'x');
	 
	$Hframe1->Label(-text => 'Test configuration :')->pack(-side => 'left');
   	my $lbTestConfig = $Hframe1->Listbox(	-width => 20,
	    					-relief => 'sunken',
						-height  => 1,
						-listvariable => \@testConfigList);
	my $scTestConfig= $Hframe1->Scrollbar(	-orient => 'vertical',
						-command => ['yview', $lbTestConfig]);
	$lbTestConfig->configure(-yscrollcommand => ['set', $scTestConfig]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
         $lbTestConfig->pack(-side => 'left', -fill => 'x', -expand => 1);
         $scTestConfig->pack(-side => 'left', -fill => 'x');

	$Hframe1->Label(-text => 'Test env :')->pack(-side => 'left');
   	my $lbTestEnv = $Hframe1->Listbox(	-width => 30,   
	    					-relief => 'sunken',
						-height  => 1,
						-listvariable => \@testEnvList);
					#foreach my $test (@testList){
					#	$lbTestName->insert('end',"$test");
					#}
	my $scTestEnv= $Hframe1->Scrollbar(	-orient => 'vertical',
						-command => ['yview', $lbTestEnv]);
	$lbTestEnv->configure(-yscrollcommand => ['set', $scTestEnv]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
        $lbTestEnv->pack(-side => 'left', -fill => 'x', -expand => 1);
        $scTestEnv->pack(-side => 'left', -fill => 'x');
	

	my $Hframe13=$mw->Frame->pack;
	my $buttonGetTestList = $Hframe13->Button(	-text => 'Get tests list', 
       							-command => \&getTestList)->pack(	-side => 'left',
												-padx => '5');
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	

	my $buttonRunTest = $Hframe13->Button(	-text => 'Run Non Reg',
						-state => 'disabled',
       						-command => \&runTest)->pack(	-side => 'left',
										-padx => '5');
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	my $buttonCheckTest=$Hframe13->Button(	-text => 'Check result', 
						-state => 'disabled',
       						-command => \&checkResult)->pack(	-side => 'left',
											-padx => '5');
						
	my $Hframe14=$mw->Frame->pack;
	my $lbl=$Hframe14->Label(-text => 'Tests List :')->pack;
	
    	MainLoop;
    
	sub getTestList{
          open(Fin, "<$rootDir/$testConfigList/$configFileDir/$testListFile") or die "impossible ouvrir $rootDir/$configFileDir/$testListFile\n";
          while(<Fin>){
            next if($_ =~ /^#/);
            my($testName, $testConfig, $testDuration, $testEnv) = split(":", $_);
            $r_test = {
              "name" => $testName,
              "config" => $testConfig,
              "duration" => $testDuration,
              "env" => $testEnv,
              "state" => "Not Run"
            };
            push ( @testList, $r_test) ;

            if ($debug == 1){
               my $a = $r_test->{name};
               my $b = $r_test->{config};
               my $c = $r_test->{duration};
               my $d = $r_test->{env};
               print " $a, $b, $c, $d\n";
            }
          }
          displayListOfTest();
          }


 	sub displayListOfTest {

		my $testNbr=scalar @testList;
		$testIndex = 0;

		foreach my $r_test (@testList){
                        my $a = $r_test->{name};
                        my $b = $r_test->{config};
                        my $c = $r_test->{duration};
                        my $d = $r_test->{env}; 
                        my $e = $r_test->{state};
                        $Hframe[$testIndex]=$mw->Frame->pack;
		        my $label1=$Hframe[$testIndex]->Label(-text =>"Name : ",-anchor => 'e', -width => 10)->pack(-side =>'left' 												, -padx => 10, -anchor => 'n');
			my $entry1=$Hframe[$testIndex]->Entry(-text => "$a",-relief => 'sunken', -width => 15
					)->pack(-side => 'left', -padx => 0, -anchor =>'n');
			my $label2=$Hframe[$testIndex]->Label(-text =>"Test Config : ",-anchor => 'e', -width => 10)->pack(-side =>'left' 												, -padx => 10, -anchor => 'n');
		        my $entry2=$Hframe[$testIndex]->Entry(-text => "$b",-relief => 'sunken', -width => 15
					)->pack(-side => 'left', -padx => 0, -anchor =>'n');
                        my $label3=$Hframe[$testIndex]->Label(-text =>"Duration : ",-anchor => 'e', -width => 10)->pack(-side =>'left' 												, -padx => 10, -anchor => 'n');
		        my $entry3=$Hframe[$testIndex]->Entry(-text => "$c",-relief => 'sunken', -width => 15
					)->pack(-side => 'left', -padx => 0, -anchor =>'n');
			$buttonTestResult[$testIndex] = $Hframe[$testIndex]->Button(
                                                   -width => '15',
                                                   -text => "$e",
	       						-state => 'disable',
	       						-activebackground => 'green',
       							-command => \&viewConfigFile)->pack(-side => 'left',
       							-padx => '1 5');
                         $testIndex =+ 1;
                }

		$buttonGetTestList->configure(-state =>'disabled');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');
		
		$lbRack->configure(-state => 'normal');
	}

	sub setTestEnv {



		$buttonGetTestList->configure(-state =>'disabled');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
	}

	sub runTest {
           foreach my $index (0.. 1){
		my $state = "OK";
		$buttonTestResult[$index]->configure(-state => 'active', -text => "$state");
           }

		$buttonGetTestList->configure(-state =>'disabled');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');
		
		$lbRack->configure(-state => 'normal');

    	}

	sub checkResult {
		my $top=$mw->Toplevel;
		$top->title('Result check');
		$top->Label(-text => 'Result check')->pack();
		foreach my $test (@testList){
			my $frame=$top->Frame->pack;
			$frame->Label(-text => "$test",-anchor => 'w', -width => 25)->pack(-side => 'left');	
			my $buttonetat = $frame->Button(-text => 'OK',
			       				-background => 'green')->pack(-side => 'right',
											-padx => '5');
		}
		$buttonGetTestList->configure(-state =>'disabled');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');
	}
	
	sub getInput {
		my ($index, $last) = $scRack->get;
		$index = $index * $lbRack->size;
		#print "$index \n";
		$rack = $lbRack->get($index);
		print "$rack\n @testList \n";
		($index, $last) = $scTestConfig->get;
		$index = $index * $lbTestConfig->size;
		$testConfig = $lbTestConfig->get($index);
		($index, $last) = $scTestEnv->get;
		$index = $index * $lbTestEnv->size;
		$testEnv = $lbTestEnv->get($index);
		$lbl->configure(-text => "xsampt_start_non_reg.pl -r $rack -c $testConfig -t $testName ; Test env = $testEnv");
	}		
	

