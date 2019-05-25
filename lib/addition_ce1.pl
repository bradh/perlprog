    #!/usr/bin/perl -w
    use Tk;
    use strict;


    	
# Main window Take top and the bottom - now implicit top is in the middle
    	my $mw = MainWindow->new;
    	$mw->title( "$0" );
    	$mw->Label(-text => "s suivantes :")->pack;
	my @testList;
	my @Hframe;	
    	my @frame;
	my @rackCible = ("P0", "P1", "S000","S001", "S002");
	my $rack;
	my @testConfigList = ("C2 UMAT", "C2 DLS", "C2 SIMPLE",
	       			"NONC2 AT UMAT", "NONC2 AT DLS", "NONC2 AT SIMPLE",
				"NONC2 AA UMAT", "NONC2 AA DLS", "NONC2 AA SIMPLE");
	my $testConfig;
	my $configNbr;
	my $testName;
	my @testEnvList =("STANDARD","CAPA");
	my $testEnv;
       	my $ent;
 	my @entry;
	my @label;,
       	my %hash;
       	my @configFile; #=( "Aladdin_Out.conf",  		"Aladdin_In.conf", "Aladdin_Out2.conf",      		"Aladdin_In2.conf", "Aladdin_Out.conf");      
	my $Vframe1=$mw->Frame->pack;
	$Vframe1->Label(-text => 'salut Nicolas, à toi de jouer...')->pack(-side => 'top');
	my $Hframe1->$
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

	$Hframe1->Label(-text => 'Test name :')->pack(-side => 'left');
   	my $lbTestName = $Hframe1->Listbox(	-width => 30,   
	    					-relief => 'sunken',
						-height  => 1,
						-listvariable => \@testList);
					#foreach my $test (@testList){
					#	$lbTestName->insert('end',"$test");
					#}
	my $scTestName= $Hframe1->Scrollbar(	-orient => 'vertical',
						-command => ['yview', $lbTestName]);
	$lbTestName->configure(-yscrollcommand => ['set', $scTestName]);
	#$box->configure(-yscrollcommand => ['set', $scroll]);
        $lbTestName->pack(-side => 'left', -fill => 'x', -expand => 1);
        $scTestName->pack(-side => 'left', -fill => 'x');

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
	
	my $buttonViewConfigFile = $Hframe13->Button(	-text => 'View config files',
	       						-state => 'disabled',	
       							-command => \&viewConfigFile)->pack(-side => 'left',
							-padx => '5');
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	
	my $buttonSetTestEnv = $Hframe13->Button(	-text => 'Set Test Env', 
							-state => 'disabled',
       							-command => \&setTestEnv)->pack(-side => 'left',
											-padx => '5');
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	
	my $buttonRunTest = $Hframe13->Button(	-text => 'Run test', 
						-state => 'disabled',
       						-command => \&runTest)->pack(	-side => 'left',
										-padx => '5');
	$Hframe13->Label(-text => '->')->pack(-side => 'left');
	my $buttonCheckTest=$Hframe13->Button(	-text => 'Check result', 
						-state => 'disabled',
       						-command => \&checkResult)->pack(	-side => 'left',
											-padx => '5');
						
	my $Hframe14=$mw->Frame->pack;
	my $lbl=$Hframe14->Label(-text => 'What?')->pack;
	
    	MainLoop;
    
	sub getTestList{
		getInput();
		my $configDir= "C2 SIMPLE";
		$configDir =~ s/\s/\//g;
		$configDir =~ s/DLS/UMAT/;
		$configDir = "$testDir/$configDir/$version";
		print "$configDir\n";
		@testList=(`ls $configDir`);
		for my $i (1..scalar @testList){
			chomp $testList[$i-1];
			print "$testList[$i-1] ";
		}
			
		$buttonGetTestList->configure(-state =>'disabled');
		$buttonViewConfigFile->configure(-state =>'active');
		$buttonSetTestEnv->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestConfig->configure(-state => 'normal');
		$lbTestName->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');
	}
	

 	sub viewConfigFile {
		getInput();
		my $configDir= "C2 SIMPLE";
		$configDir =~ s/\s/\//g;
		$configDir =~ s/DLS/UMAT/;
		$configDir = "$testDir/$configDir/$version/$testName/ATR/";
		print "$configDir\n";
		@configFile=(`ls $configDir/*.c*`);
		for my $i (1..scalar @configFile){
			chomp $configFile[$i-1];
			print "$configFile[$i-1] ";
		}
		my $fileNbr=scalar @configFile;
		my $topLevelNbr=int($fileNbr/3)+1;
		print "$topLevelNbr\n";
		my @topLevelConfig;
		foreach my $i (1..$topLevelNbr){
		       $topLevelConfig[$i]=$mw->Toplevel;
	       		$topLevelConfig[$i]->title("Config files $i");
 		}			
		my $index = 0;	
		foreach my $file (@configFile){
			open Fin, "<$file" or die " impossible d'ouvrir $file\n";
			$Hframe[$index]=$topLevelConfig[int($index/3)+1]->Frame->pack(-side => 'left');
			$Hframe[$index]->Label(-text => "$file")->pack(-side => 'top');
			my $index2 = 0;
			while (<Fin>) {
				my $ligne = $_;
				chomp $ligne;
				#print "$ligne\n";
				if($ligne =~ /\s*(.?)\s*=\s*(.?)\s*/ ) {
			       		my ($param, $sepa, $value) = split (" ",$ligne);	
					$frame[$index2]=$Hframe[$index]->Frame->pack;  	
					$label[$index][$index2]=$frame[$index2]->Label(-text =>"$param = ",-anchor => 'e', -width => 25)->pack(-side =>'left' 												, -padx => 10, -anchor => 'n');
					$entry[$index][$index2]=$frame[$index2]->Entry(-text => "$value",-relief => 'sunken', -width => 25
					)->pack(-side => 'left', -padx => 0, -anchor =>'n');
					#print "$param =  $value\n";
				}
				$index2 += 1;
			}
			$index += 1;
		}
		$buttonGetTestList->configure(-state =>'disabled');
		$buttonViewConfigFile->configure(-state =>'active');
		$buttonSetTestEnv->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestConfig->configure(-state => 'normal');
		$lbTestName->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');
	}
    
	sub setTestEnv {		
		$buttonGetTestList->configure(-state =>'disabled');
		$buttonViewConfigFile->configure(-state =>'active');
		$buttonSetTestEnv->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestConfig->configure(-state => 'normal');
		$lbTestName->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');	
		
	}

	sub runTest {
		getInput();
		$buttonGetTestList->configure(-state =>'disabled');
		$buttonViewConfigFile->configure(-state =>'active');
		$buttonSetTestEnv->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestConfig->configure(-state => 'normal');
		$lbTestName->configure(-state => 'normal');
		$lbTestEnv->configure(-state => 'normal');	
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
		$buttonViewConfigFile->configure(-state =>'active');
		$buttonSetTestEnv->configure(-state =>'active');
		$buttonRunTest->configure(-state =>'active');
		$buttonCheckTest->configure(-state =>'active');	
		
		$lbRack->configure(-state => 'normal');
		$lbTestConfig->configure(-state => 'normal');
		$lbTestName->configure(-state => 'normal');
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
		($index, $last) = $scTestName->get;
		$index = $index * $lbTestName->size;
		$testName = $lbTestName->get($index);
		($index, $last) = $scTestEnv->get;
		$index = $index * $lbTestEnv->size;
		$testEnv = $lbTestEnv->get($index);
		$lbl->configure(-text => "xsampt_start_test -r $rack -c $testConfig -t $testName ; Test env = $testEnv");
	}		
	

