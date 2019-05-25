package ConfiguratorMenu;
use Tkx;
use ConfiguratorProject;
use ConfiguratorFile;
my $mw2;
my $mw;


sub mk_menu {
	$mw = shift;
	my $selectCommand = shift;
	my $updateFilesCommand = shift;
	my $saveCommand = shift;
	my $menu = $mw->new_menu ();
  	my $project = $menu->new_menu(	-tearoff => 0,
					          		-background => 'lightgrey'
					      			);
      $menu->add_cascade( -label => "Project",
				          -underline => 0,
				          -menu => $project,
				      	);
      $project->add_command(	-label => "Select",
					      		-underline => 0,
					      		-command => $selectCommand
					      );
      $project->add_command(	-label => "Save",
					      		-underline => 0,
					      		-command => $saveCommand
					      );
      $project->add_command(	-label => "Save as",
					      		-underline => 0,
					      		-command => $saveCommand 
					      );
	my $configuration = $menu->new_menu(	-tearoff => 0,
					          		-background => 'lightgrey'
					      			);
      $menu->add_cascade( -label => "Configuration",
				          -underline => 0,
				          -menu => $configuration,
				      	);
      $configuration->add_command(	-label => "Apply",
					      		-underline => 0,
					      		-command => $updateFilesCommand
					      );
      $configuration->add_command(	-label => "Transfert",
					      		-underline => 0,
					      		-command => \&selectProject
					      );
	return $menu;				       					     
}



sub apply{
	
}
sub transfert{
	
}

sub confirmAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Confirmation",
             -message => $text,
             -type => 'yesno'
           );
    #print "response = $reponse";
	return $reponse;
}

sub acquittementAction {
	my $text = shift;
	my $reponse = Tkx::tk___messageBox(
             -parent => $mw,
             -icon => "info",
             -title => "Acquittement",
             -message => $text,
             -type => 'ok'
           );
    #print "response = $reponse";
	return $reponse;
}
1	