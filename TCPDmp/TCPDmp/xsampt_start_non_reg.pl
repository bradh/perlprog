    #!/usr/bin/perl -w
    use Tkx;
    use strict;
    my $debug = 1;

    my $rootDir="S:\\tests";
 #   my $testDir="$rootDir\\tests";
    my $configFileDir="reference_ATP\\fichiers_communs";
    my $testListFile="sampt_non_reg_test_list.txt";
	my $VERSION_DLIP="SAMPT_V5";

	my $solarisCible = "smartha01";


# Main window Take top and the bottom - now implicit top is in the middle
    	my $mw = MainWindow->new;
    	$mw->title( "$0" );
    	$mw->Label(-text => "xsampt_start_non_reg.pl lance un test sampt avec les options suivantes :")->pack;
	my @testList;
	my @Hframe;
    	my @frame;
	my @rackCible = ("rack_P0");
	my $rack;
	my $rackNbr;
	my @testConfigList = ("C2","NON_C2");
	my $testConfig;
	my $testConfigNbr;
	my $configNbr;
	my $testName;
	my @testEnvList =("T_AUTOMATION");
	my $testEnv;
	my $r_test;
	my $testIndex;
	my $testVersion = "V10R3E9";
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
   	my $lbTestConfig = $Hframe1->Listbox(	-width => 10,
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
   	my $lbTestEnv = $Hframe1->Listbox(	-width => 15,
	    					-relief => 'sunken',
						-height  => 1,
						-listvariable => \@testEnvList);
					#foreach my $test (@testList){
					#	$lbTestName->insert('end',"$test");
					#}
	my $scTestEnv = $Hframe1->Scrollbar(	-orient => 'vertical',
						-command => ['yview', $lbTestEnv]);
	$lbTestEnv->configure(-yscrollcommand => ['set', $scTestEnv]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
        $lbTestEnv->pack(-side => 'left', -fill => 'x', -expand => 1);
        $scTestEnv->pack(-side => 'left', -fill => 'x');
 
        $Hframe1->Label(-text =>"Test Version : ",-anchor => 'w', -width => 10)->pack(-side =>'left', -padx => 10, -anchor => 'w');
		my $testVersionEntry = $Hframe1->Entry(-text => "$testVersion",-relief => 'sunken', -width => 15
					)->pack(-side => 'left', -padx => 10, -anchor =>'w');

	

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
        while(scalar @testList){
          pop @testList;
        }
        getInput();
        print "$testVersion\n";
        #print "$testConfig\n";
          open(Fin, "<$rootDir\\$testConfig\\$configFileDir\\$testListFile") or die "impossible ouvrir $rootDir\\$testConfig\\$configFileDir\\$testListFile\n";
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
        my $top=$mw->Toplevel;
		$top->title('Non Reg Tests List');
		$top->Label(-text => 'Non Reg Tests List')->pack();
		my $testNbr=scalar @testList;
		$testIndex = 0;


		foreach my $r_test (@testList){
                        my $a = $r_test->{name};
                        my $b = $r_test->{config};
                        my $c = $r_test->{duration};
                        my $d = $r_test->{env}; 
                        my $e = $r_test->{state};
                        $Hframe[$testIndex]=$top->Frame->pack;
		        my $label1=$Hframe[$testIndex]->Label(-text =>"Name : ",-anchor => 'e', -width => 10)->pack(-side =>'left' 												, -padx => 10, -anchor => 'n');
			my $entry1=$Hframe[$testIndex]->Entry(-text => "$a",-relief => 'sunken', -width => 25
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
       							-padx => 10);
                         $testIndex += 1;
                }

		$buttonGetTestList->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'disable');
		$buttonCheckTest->configure(-state =>'active');
		
		$lbRack->configure(-state => 'normal');
	}

	sub setTestEnv {



		$buttonGetTestList->configure(-state =>'disabled');
		$buttonRunTest->configure(-state =>'disable');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
	}

	sub runTest {
        $buttonRunTest->configure(-state =>'disable');
        my $index =0;
         foreach my $r_test (@testList){
           my $NOM_TEST = $r_test->{name};
           my $CONFIG_UMAT_SIMPLE = $r_test->{config};
           my $DUREE_TEST = $r_test->{duration};
           my $TEST_ENV = $r_test->{env};

           #print "$NOM_TEST, $CONFIG_UMAT_SIMPLE, $DUREE_TEST\n";
           if($CONFIG_UMAT_SIMPLE eq "UMAT"){

                                  print "Configuration de l'environnement de test, please wait...\n";
                                  system("rsh smartha02 -l samptivq sampt_init.pl -r $rack -c $ -t $TEST_ENV");
                                  print "start $NOM_TEST en mode $CONFIG_UMAT_SIMPLE duree $DUREE_TEST...\n";
                                  #system( "sampt_start_test.pl -r $rack -c $testConf -v $VERSION_DLIP -t $NOM_TEST -l -i -s $DUREE_TEST -x");
                                  # récupération des log
                                  #system( "sampt_retrieve_log.pl -r $rackNbr -c $testConfigNbr -v $VERSION_DLIP -t $NOM_TEST");


                                  $r_test->{state} = "OK";
		                          my $state = $r_test->{state};
                                  $buttonTestResult[$index]->configure(-state => 'active', -text => "$state");
           }
           $index +=1;
        }

		$buttonGetTestList->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'disable');
		$buttonCheckTest->configure(-state =>'active');
		
		$lbRack->configure(-state => 'normal');

  }

	sub checkResult {
		my $top=$mw->Toplevel;
		$top->title('Result check');
		$top->Label(-text => 'Result check')->pack();
		foreach my $r_test (@testList){
                my $testName = $r_test->{name};
                my $testUmatSimple = $r_test->{config};
            my $repTest = "$rootDir\\$testConfig\\$testUmatSimple\\$VERSION_DLIP\\$testName\\ATR\\$testVersion";
            print "$repTest\n";
            if(! -d $repTest){
                 $r_test->{state} = "Not run";
            }
            else {
                 #print "toto\n";
                 if( -f "$repTest\\compas.log"){
                   my $erreur = 1;
                    #print "OOOOK\n";
                   open Fin, "< $repTest\\compas.log" or die "impossible ...\n";
                   while(<Fin>){
                     my $ligne = $_;
                     #print "$ligne";
                     if ($ligne =~ "without Error"){
                       print "$ligne";
                       $erreur = 0;
                     }
                   }
                   if ($erreur == 0){
                      $r_test->{state} = "OK";
                   }
                   else {
                      $r_test->{state} = "NOK";
                   }
                 }
                 else{

                      $r_test->{state} = "Not run";
                 }
            }
            print "$repTest\n";
            #exit 0;
			my $frame=$top->Frame->pack;
			$frame->Label(-text => "$testName",-anchor => 'w', -width => 25)->pack(-side => 'left');
			my $buttonetat = $frame->Button(-text => 'Not run',
			       				-background => 'grey')->pack(-side => 'right',
											-padx => '5');
			my $testState = $r_test->{state};
			print   "$testState\n";
			if ($testState eq "OK"){
               $buttonetat->configure(-background => 'green');
               $buttonetat->configure(-text => 'OK');
               }
             if ($testState eq "NOK"){

               $buttonetat->configure(-background => 'red');
               $buttonetat->configure(-text => 'NOK');
               }
		}
		$buttonGetTestList->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'disable');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');
	}
	
	sub getInput {
		my ($index, $last) = $scRack->get;
		$index = $index * $lbRack->size;
		$rack =  $lbRack->get($index);
		$rackNbr = $index+1;
		print "rack : $rack \n";
		($index, $last) = $scTestConfig->get;
		$index = $index * $lbTestConfig->size;
		$testConfig = $lbTestConfig->get($index);
        print "$testConfig\n";
		($index, $last) = $scTestEnv->get;
		$index = $index * $lbTestEnv->size;
		$testEnv = $lbTestEnv->get($index);
		$testVersion = $testVersionEntry->get;
		$lbl->configure(-text => "sampt start non reg for version $testVersion sur $rack for SAMPT $testConfig  ; Test env = $testEnv");
	}
	

