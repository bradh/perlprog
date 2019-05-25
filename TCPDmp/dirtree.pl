
#!/usr/bin/perl -w
use Tk;
use Tk::DirTree;
use Tk::Tree;

my $mw = MainWindow->new;
$mw->title("$0");
my $DIR = "\.";
my $dirtree = $mw->Tree();
$dirtree->pack();

MainLoop;

exit 0;