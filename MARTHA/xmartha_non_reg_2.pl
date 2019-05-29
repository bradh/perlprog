    #!/usr/bin/perl -w
    use Tkx;
    use strict;
    my $debug = 1;

    my $rootDir="/h7_usr/sil2_usr/marthivq/MARTHA_CGC3";
    my $testDir="$rootDir/C2/TESTS_CGC3_PEU/build2";
    my $configFileDir="$rootDir/configuration_files/non_reg";
    my $testListFile="test_list.txt";
	my $version="";


# Main window Take top and the bottom - now implicit top is in the middle
    my $mw = Tkx::widget->new(".");
    $mw->g_wm_title("$0" );
    #$mw->new_ttk__label(-text => "xmartha_non_reg.pl lance un test martha avec les options suivantes :")->g_grid();
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
	my $Vframe10 = $mw->new_ttk__frame
		->g_grid(-column => 1, -row => 12, -sticky => "w");
	my $Hframe1=$mw->new_ttk__frame;
	$Hframe1->new_ttk__label(-text => 'Rack cible:')->g_grid();
   	my $lbRack = $Hframe1->new_ttk__listbox(-width => 10,   
						    				-relief => 'sunken',
											-height  => 1,
											-listvariable => "@rackCible");
				
	my $scRack = $Hframe1->new_ttk_scrollbar(-orient => 'vertical',
				-command => ['yview', $lbRack]);
	$lbRack->configure(-yscrollcommand => ['set', $scRack]);
	$lbRack->g_grid();
     $scRack->g_grid();
	 
	$Hframe1->new_ttk__label(-text => 'Test configuration :')->g_grid();
   	my $lbTestConfig = $Hframe1->new_ttk__listbox(	-width => 20,
							    					-relief => 'sunken',
													-height  => 1,
													-listvariable => \@testConfigList);
	my $scTestConfig= $Hframe1->new_ttk_scrollbar(	-orient => 'vertical',
													-command => ['yview', $lbTestConfig]);
	$lbTestConfig->configure(-yscrollcommand => ['set', $scTestConfig]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
         $lbTestConfig->g_grid();
         $scTestConfig->g_grid();

	$Hframe1->new_ttk__label(-text => 'Test env :')->g_grid();
   	my $lbTestEnv = $Hframe1->new_ttk__listbox(	-width => 30,   
	    										-relief => 'sunken',
												-height  => 1,
												-listvariable => \@testEnvList);
					#foreach my $test (@testList){
					#	$lbTestName->insert('end',"$test");
					#}
	my $scTestEnv= $Hframe1->new_ttk_scrollbar(	-orient => 'vertical',
												-command => ['yview', $lbTestEnv]);
	$lbTestEnv->configure(-yscrollcommand => ['set', $scTestEnv]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
        $lbTestEnv->pack(-side => 'left', -fill => 'x', -expand => 1);
        $scTestEnv->pack(-side => 'left', -fill => 'x');
	

	my $Hframe13=$mw->new_ttk__frame->g_grid();
	my $buttonGetTestList = $Hframe13->new_ttk_button(	-text => 'Get tests list', 
		       											-command => \&getTestList)->pack(	-side => 'left',
														-padx => '5');
	$Hframe13->new_ttk__label(-text => '->')->g_grid();
	

	my $buttonRunTest = $Hframe13->new_ttk_button(	-text => 'Run Non Reg',
													-state => 'disabled',
       												-command => \&runTest)->g_grid();
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	my $buttonCheckTest=$Hframe13->new_ttk_button(	-text => 'Check result', 
													-state => 'disabled',
       												-command => \&checkResult)->g_grid();
						
	my $Hframe14=$mw->new_ttk_lrame->g_grid();
	my $lbl=$Hframe14->new_ttk__label(-text => 'Tests List :')->g_grid();
	
    Tkx::MainLoop();
    
	sub getTestList{
          open(Fin, "<$configFileDir/$testListFile") or die "impossible ouvrir $configFileDir/$testListFile\n";
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
                        $Hframe[$testIndex]=$mw->new_ttk__frame->g_grid();
		        my $label1=$Hframe[$testIndex]->new_ttk__label(-text =>"Name : ",-anchor => 'e', -width => 10)->g_grid();
			my $entry1=$Hframe[$testIndex]->new_ttk_entry(-text => "$a",-relief => 'sunken', -width => 15
					)->g_grid();
			my $label2=$Hframe[$testIndex]->new_ttk__label(-text =>"Test Config : ",-anchor => 'e', -width => 10)->g_grid();
                        my $label3=$Hframe[$testIndex]->new_ttk__label(-text =>"Duration : ",-anchor => 'e', -width => 10)->g_grid();
			$buttonTestResult[$testIndex] = $Hframe[$testIndex]->new_ttk_button(
                                                   -width => '15',
                                                   -text => "$e",
	       						-state => 'disable',
	       						-activebackground => 'green',
       							-command => \&viewConfigFile)->g_grid();
                         $testIndex += 1;
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
		$top->new_ttk__label(-text => 'Result check')->g_grid();
		foreach my $test (@testList){
			my $frame=$top->new_ttk_frame->g_grid();
			$frame->new_ttk__label(-text => "$test",-anchor => 'w', -width => 25)->g_grid();
			my $buttonetat = $frame->new_ttk__button(-text => 'OK',
			       				-background => 'green')->g_grid();
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
	

