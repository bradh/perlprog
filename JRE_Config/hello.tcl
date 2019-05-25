use Tkx;

use Tkx;

my $mw = Tkx::widget->new(".");
$mw->g_wm_title("Feet to Meters");
my $frm = $mw->new_ttk__frame(-padding => "3 3 12 12");
$frm->g_grid(-column => 0, -row => 0, -sticky => "nwes");
$mw->g_grid_columnconfigure(0, -weight => 1);
$mw->g_grid_rowconfigure(0, -weight => 1);

my $ef = $frm->new_ttk__entry(-width => 7, -textvariable => \$feet);
$ef->g_grid(-column => 2, -row => 1, -sticky => "we");
my $em = $frm->new_ttk__label(-textvariable => \$meters);
$em->g_grid(-column => 2, -row => 2, -sticky => "we");
my $cb = $frm->new_ttk__button(-text => "Calculate", -command => sub {calculate();});
$cb->g_grid(-column => 3, -row => 3, -sticky => "w");

$frm->new_ttk__label(-text => "feet")->g_grid(-column => 3, -row => 1, -sticky => "w");
$frm->new_ttk__label(-text => "is equivalent to")->g_grid(-column => 1, -row => 2, -sticky => "e");
$frm->new_ttk__label(-text => "meters")->g_grid(-column => 3, -row => 2, -sticky => "w");

foreach (Tkx::SplitList($frm->g_winfo_children)) {
    Tkx::grid_configure($_, -padx => 5, -pady => 5);
}
$ef->g_focus;
$mw->g_bind("<Return>", sub {calculate();});

sub calculate {
   $meters = int(0.3048*$feet*10000.0+.5)/10000.0 || '';
}

Tkx::MainLoop();


