use Tkx;
my $mw = Tkx::widget->new(".");

($lb = $mw->new_tk__text(-width => 5, -height => 5))->g_grid(-column => 0, -row => 0, -sticky => "nwes");
($s = $mw->new_ttk__scrollbar(-command => [$lb, "yview"], 
        -orient => "vertical"))->g_grid(-column =>1, -row => 0, -sticky => "ns");
$lb->configure(-yscrollcommand => [$s, "set"]);
($mw->new_ttk__label(-text => "Status message here", 
        -anchor => "w"))->g_grid(-column => 0, -row => 1, -sticky => "we");
($mw->new_ttk__sizegrip)->g_grid(-column => 1, -row => 1, -sticky => "se");
$mw->g_grid_columnconfigure(0, -weight => 1); $mw->g_grid_rowconfigure(0, -weight => 1);
for ($i=0; $i<100; $i++) {
   $lb->insert("end", "Line " . $i . " of 100");
}

Tkx::MainLoop();