use Getopt::Std;
#use strict;
use Tkx;
use Threads;

$mw = Tkx::widget->new(".");
$mw->g_wm_title( "THALES : Canvas" );
$cns =$mw->new_canvas( -bg => "lightblue", -width => 600, -heigh => 400
        
    );
$cns->g_pack();
$cns->create_line(3,3,40,50, 400, 200, -fill => "red");
$rect = $cns->create_rectangle(200, 200, 280, 250, -fill => "lightgreen" );
$text = $rect->create_text(50,5, -text => "Hello DLIP");
Tkx::MainLoop();
