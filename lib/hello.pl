use Tk;

$top = MainWindow->new();
$top->title("Hello");
$button = $top->Button( -text => 'Start', -command => \&change_label);

$button->pack();
$l = $top->Label(-text => "world !")->pack();
MainLoop();

sub change_label {
	print "toto\n";
}
