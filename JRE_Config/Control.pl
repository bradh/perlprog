use Tkx;
my $mw = Tkx::widget->new(".");
(my $l = $mw->new_ttk__label(-text => "Starting..."))->g_grid;
$l->g_bind("<Enter>",     sub {$l->configure(-text => "Moved mouse inside")});
$l->g_bind("<Leave>",     sub {$l->configure(-text => "Moved mouse outside")});
$l->g_bind("<1>",         sub {$l->configure(-text => "Clicked left mouse button")});
$l->g_bind("<Double-1>",  sub {$l->configure(-text => "Double clicked")});
$l->g_bind("<B3-Motion>", [sub { my($x,$y) = @_;
                                 $l->configure(-text => "right button drag to $x $y")
	                   }, Tkx::Ev("%x", "%y")]);
Tkx::MainLoop();
