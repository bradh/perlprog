use Tkx;

my $mw = Tkx::widget->new(".");
my $content = $mw->new_ttk__frame;
my $frame = $content->new_ttk__frame(-borderwidth => 5, -relief => "sunken", -width => 200, -height => 100);
my $namelbl = $content->new_ttk__label(-text => "Name");
my $name = $content->new_ttk__entry;
$option_one = 1; $option_two = 0; $option_three = 1;
my $one = $content->new_ttk__checkbutton(-text => "One", -variable => \$option_one, -onvalue => 1); 
my $two = $content->new_ttk__checkbutton(-text => "Two", -variable => \$option_two, -onvalue => 1);
my $three = $content->new_ttk__checkbutton(-text => "Three", -variable => \$option_three, -onvalue => 1);
my $ok = $content->new_ttk__button(-text => "Okay");
my $cancel = $content->new_ttk__button(-text => "Cancel");

$content->g_grid(-column => 0, -row => 0);
$frame->g_grid(-column => 0, -row => 0, -columnspan => 3, -rowspan => 2);
$namelbl->g_grid(-column => 3, -row => 0, -columnspan => 2);
$name->g_grid(-column => 3, -row => 1, -columnspan => 2);
$one->g_grid(-column => 0, -row => 3);
$two->g_grid(-column => 1, -row => 3);
$three->g_grid(-column => 2, -row => 3);
$ok->g_grid(-column => 3, -row => 3);
$cancel->g_grid(-column => 4, -row => 3);

Tkx::MainLoop;
