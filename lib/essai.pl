    #!/usr/bin/perl -w  
    use Tk;
    use strict;

    my $mw = MainWindow->new;
    $mw->Label(-text => 'Hello, world!')->pack;
    $mw->Button(
        -text    => 'Quit',
        -command => sub { exit },
    )->pack;
    my $frame1=$mw->Frame->pack;
    my $self;
my $sl = $frame1->SlideSwitch(
     -bg          => 'gray',
     -orient      => 'horizontal',
     -command     => [$self => 'on'],
     -llabel      => [-text => 'OFF', -foreground => 'blue'],
     -rlabel      => [-text => 'ON',  -foreground => 'blue'],
     -troughcolor => 'tan',
 )->pack(qw/-side left -expand 1/);

    MainLoop;

