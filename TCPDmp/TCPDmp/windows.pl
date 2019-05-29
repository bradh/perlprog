    #!/usr/bin/perl -w
    use Tk;
    use strict;

    my $mw = MainWindow->new;
    $mw->configure(-background => 'yellow');
    fill_window($mw, 'Main');
    my $top1 = $mw->Toplevel;
    fill_window($top1, 'First top-level');
    my $top2 = $mw->Toplevel;
    fill_window($top2, 'Second top-level');
    MainLoop;
	
    sub fill_window {
        my ($window, $header) = @_;
	$window->configure(-background => 'blue');
        my $l=$window->Label(-text => $header)->pack;
	my $image=$l->Photo(-file => 'enfants.gif');
	$l->configure(-foreground => 'white', -image => $image);
        $b=$window->Button(
            -text    => 'close',
            -command => [$window => 'destroy']
        )->pack(-side => 'left');
	$b->configure(-background => 'red', -foreground => 'yellow', -image => $image);
         my $b2=$window->Button(
            -text    => 'exit',
            -command => [$mw => 'destroy']
        )->pack(-side => 'right');
	 $b2->configure(-background => 'green');
    }

