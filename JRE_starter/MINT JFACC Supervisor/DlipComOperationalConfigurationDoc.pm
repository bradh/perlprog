package DlipComOperationalConfigurationDoc ;
	use XML::Simple;
	use Data::Dumper;
	use Tkx;

	my $dirName = ".";
	my $fileName = "DLIP-COM-MNG_OPERATIONAL_CONFIG.XML";
	my $r_networkName;
	my $r_routeNameArray;
	my $networkID;
	my $networkName;
	my @routeFrame;
	my @routeIDEntry;
	my @routeNameEntry;
	
	my $frame4;
	
	my $padx = 1;
	my $pady = 1;
	
	sub new {
		my $mw = shift;
		my $configRouteWindow = $mw->new_toplevel();
		my $r_dlipComOperationalConfig = readConfigFile();
		$r_networkName = $r_dlipComOperationalConfig->{'networkName'};
		$networkID = $r_networkName->{'linkName'}->{'NetworkId'};
		$networkName = $r_networkName->{'linkName'}->{'Name'};
		$r_routeNameArray = $r_networkName->{'linkName'}->{'routeName'};
		$configRouteWindow->g_wm_title("Routes Configuration" );
		my $newFrame = $configRouteWindow->new_ttk__frame();
		
		displayRouteConfigWindow($configRouteWindow);
		$configRouteWindow->g_wm_geometry("+250+20");
		Tkx::MainLoop();
	}
	
	sub displayRouteConfigWindow {
		$configRouteWindow = shift;
		my $frame1 = $configRouteWindow->new_ttk__frame();
		my $networkLabel = $frame1->new_ttk__label( -text =>'-- Network :  ID / Label', -anchor => 'w',-width => 20);
		
		$networkLabel->g_grid(-column => 1, -row => 1,  -padx => $padx,-pady => $pady, -sticky => 'w');
		$frame1->g_grid(-column => 1, -row => 1, -padx => $padx,-pady => $pady, -sticky => 'w');
		
		my $frame2 = $configRouteWindow->new_ttk__frame();
		my $networkIDEntry = $frame2->new_ttk__entry( -textvariable => \$networkID, -state => 'readonly',-width => 3);
		my $networkNameEntry = $frame2->new_ttk__entry( -textvariable => \$networkName,-width => 15);
	
		$networkIDEntry->g_grid(-column => 1, -row => 2, -padx => $padx,-pady => $pady, -sticky => 'e');
		$networkNameEntry->g_grid(-column => 2, -row => 2, -padx => $padx,-pady => $pady, -sticky => 'e');
		
		$frame2->g_grid(-column => 1, -row => 2, -padx => $padx,-pady => $pady, -sticky => 'w');
		
		$frame3 = $configRouteWindow->new_ttk__frame();
		my $routeLabel = $frame3->new_ttk__label( -text =>'-- Route :  ID / Label:', -anchor => 'w',-width => 20);
		$routeLabel->g_grid(-column => 1, -row => 3,  -padx => $padx,-pady => $pady, -sticky => 'w');
		$frame3->g_grid(-column => 1, -row => 3, -padx => $padx,-pady => $pady, -sticky => 'w');
		
		$frame4 = $configRouteWindow->new_ttk__frame();
		$i = 0;
		print "$r_routeNameArray\n";
		foreach my $route (@$r_routeNameArray){
			$routeID[$i] = \$route->{'RouteId'};
			$routeName[$i] = \$route->{'Name'};
			$routeIDEntry[$i] = $frame4->new_ttk__entry( -textvariable => $routeID[$i], -width => 5);
			$routeNameEntry[$i] = $frame4->new_ttk__entry( -textvariable => $routeName[$i],-width => 15);
			$routeIDEntry[$i]->g_grid(-column => 1, -row => 4+$i, -padx => $padx,-pady => $pady, -sticky => 'e');
			$routeNameEntry[$i]->g_grid(-column => 2, -row => 4+$i, -padx => $padx,-pady => $pady, -sticky => 'w');
			$i++;
		}
		
		$frame4->g_grid(-column => 1, -row => 4, -padx => $padx,-pady => $pady, -sticky => 'w');
		
		my $frame5 = $configRouteWindow->new_ttk__frame();
		my $cmdLabel = $frame5->new_ttk__label( -text =>'  ', -anchor => 'w',-width => 20);
		$cmdLabel->g_grid(-column => 1, -row => 1, -padx => $padx, -pady => $pady);
		$frame5->g_grid(-column => 1, -row => 5, -padx => $padx,-pady => $pady, -sticky => 'w');
		
		my $frame6 = $configRouteWindow->new_ttk__frame();
		$buttonSave = $frame6->new_ttk__button(-text => "Save", -command => \&saveConfiguration);
		$buttonAddRoute = $frame6->new_ttk__button(-text => "Add Route", -command => \&addRoute);
		$buttonDelRoute = $frame6->new_ttk__button(-text => "Del Route", -command => \&delRoute);
	

		$buttonSave->g_grid(-column => 1, -row => 1, -padx => $padx, -pady => $pady);
		$buttonAddRoute->g_grid(-column => 2, -row => 1, -padx => $padx, -pady => $pady);
		$buttonDelRoute->g_grid(-column => 3, -row => 1, -padx => $padx, -pady => $pady);
		
		$frame6->g_grid(-column => 1, -row => 6, -padx => $padx,-pady => $pady, -sticky => 'w');
	}
	
	sub displayFrame4 {
		$i = 0;
		#print "$r_routeNameArray\n";
		foreach my $route (@$r_routeNameArray){
			$routeID[$i] = \$route->{'RouteId'};
			$routeName[$i] = \$route->{'Name'};
			$routeIDEntry[$i] = $frame4->new_ttk__entry( -textvariable => $routeID[$i], -width => 5);
			$routeNameEntry[$i] = $frame4->new_ttk__entry( -textvariable => $routeName[$i],-width => 15);
			$routeIDEntry[$i]->g_grid(-column => 1, -row => 4+$i, -padx => $padx,-pady => $pady, -sticky => 'e');
			$routeNameEntry[$i]->g_grid(-column => 2, -row => 4+$i, -padx => $padx,-pady => $pady, -sticky => 'w');
			$i++;
		}
		
		$frame4->g_grid(-column => 1, -row => 4, -padx => $padx,-pady => $pady, -sticky => 'w');
	}

	sub readConfigFile{
		$dlipComOperationalConfiguration = XMLin("$dirName\\$fileName", ForceArray => ['routeName']);
  		print Dumper($dlipComOperationalConfiguration);
   		return $dlipComOperationalConfiguration;
	}
	sub addRoute {
		clearRouteList();
		my $i = scalar @$r_routeNameArray;
		$r_routeNameArray->[$i]->{'RouteId'} = "0";
		$r_routeNameArray->[$i]->{'Name'} = "new route";
		displayFrame4();
	}
	sub delRoute {
		clearRouteList();
		my $i = scalar @$r_routeNameArray;
		print "route nber $i\n";
		if($i>1){
			pop @$r_routeNameArray;
		}
		else {
			print "$i not possible suppress last route !\n";
		}
		displayFrame4();
	}
	sub saveConfiguration {
		open Fin, "$dirName\\$fileName" or die;
		open Fout, ">$dirName\\temp.txt" or die;
		while(<Fin>){
			my $line = $_;
			chomp $line;
			print "$line\n";
			if($line =~ /\<linkName NetworkId=/){
				
				print Fout "\t\t\<linkName NetworkId=\"$networkID\" Name=\"$networkName\">\n";
				foreach my $route (@$r_routeNameArray){
					my $routeID = $route->{'RouteId'};
					my $routeName = $route->{'Name'};
					print Fout "\t\t\t\<routeName RouteId=\"$routeID\" Name=\"$routeName\"\/\>\n"
				}
			}
			elsif($line =~ /\<routeName RouteId=/){
				next;
			}
			else {
				print Fout "$line\n";
			}
		}
		
		close Fout;
		close Fin;
		system("copy $dirName\\temp.txt $dirName\\$fileName");
		acquittementAction("DLIPCOM shall be restarted !");
 		$configRouteWindow->g_destroy();
	}
	
	sub clearRouteList{
		$i = 0;
		foreach my $route (@$r_routeNameArray){
			$routeIDEntry[$i]->g_grid_remove(); 
			$routeNameEntry[$i]->g_grid_remove(); 
			$i++;
		}
		#$frame4->g_grid_remove();
	}
	sub acquittementAction {
		my $text = shift;
		my $reponse = Tkx::tk___messageBox(
             -parent => $configRouteWindow,
             -icon => "info",
             -title => "Confirmation",
             -message => $text,
             -type => 'ok'
           );
    	#print "response = $reponse";
		return $reponse;
	}
	
1