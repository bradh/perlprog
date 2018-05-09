     #!/usr/bin/perl -w
     use Tk;
     use strict;

     my $mw = MainWindow->new;
     my $box = $mw->Listbox(
         -relief => 'sunken',
         -height  => 5,
         -setgrid => 1,
         );
         my @items = qw(One Two Three Four Five Six Seven
                   Eight Nine Ten Eleven Twelve);
         foreach (@items) {
       $box->insert('end', $_);
         }
         my $scroll = $mw->Scrollbar(-command => ['yview', $box]);
         $box->configure(-yscrollcommand => ['set', $scroll]);
         $box->pack(-side => 'left', -fill => 'both', -expand => 1);
         $scroll->pack(-side => 'right', -fill => 'y');

    MainLoop;

