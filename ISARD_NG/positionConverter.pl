#/usr/bin/perl -w

use Tkx;

use Conversion_coordonate;

my $degreLat = 0;
my $minLat = 0;
my $secLat = 0;

my $degreLong = 0;
my $minLong = 0;
my $secLong = 0;

my $geoPosition = "MNKL4931";

my $mw = Tkx::widget->new(".");
$mw->g_wm_title("$0" );

my $Vframe1 = $mw->new_ttk__frame->g_grid(-column => 2, -row => 0, -sticky => "w");
$mw->new_ttk__label(-text => "Lat / Long\n")
	->g_grid(-column => 0, -row => 0, -sticky => "e", -columnspan => 4);
$mw->new_ttk__label(-text => "Lat : ", -width => 6)
	->g_grid(-column => 1, -row => 1, -sticky => "w");
$mw->new_ttk__entry(-textvariable => \$degreLat, -width => 4)
	->g_grid(-column => 2, -row => 1, -sticky => "w");
$mw->new_ttk__label(-text => ' ° ', -width => 2)
	->g_grid(-column => 3, -row => 1, -sticky => "w");
$mw->new_ttk__entry(-textvariable => \$minLat, -width => 3)
	->g_grid(-column => 4, -row => 1, -sticky => "w");
$mw->new_ttk__label(-text => " \' ", -width => 2)
	->g_grid(-column => 5, -row => 1, -sticky => "w");
$mw->new_ttk__entry(-textvariable => \$secLat, -width => 3)
	->g_grid(-column => 6, -row => 1, -sticky => "w");
$mw->new_ttk__label(-text => ' \'\' ', -width => 2)
	->g_grid(-column => 7, -row => 1, -sticky => "w");

my $buttonConvert = $mw->new_ttk__button(-text => " > ", -state => 'active', -command => \&convert, -width => 3)
		->g_grid(-column => 8, -row => 1, -sticky => "w");
		
$mw->new_ttk__label(-text => " Geo Ref : ", -width => 11)
	->g_grid(-column => 9, -row => 1, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$geoPosition, -width => 10)
	->g_grid(-column => 10, -row => 1, -sticky => "w");


$mw->new_ttk__label(-text => "Long : ", -width => 7)
	->g_grid(-column => 1, -row => 2, -sticky => "e");
$mw->new_ttk__entry(-textvariable => \$degreLong, -width => 4)
	->g_grid(-column => 2, -row => 2, -sticky => "w");
$mw->new_ttk__label(-text => ' ° ', -width => 2)
	->g_grid(-column => 3, -row => 2, -sticky => "w");
$mw->new_ttk__entry(-textvariable => \$minLong, -width => 3)
	->g_grid(-column => 4, -row => 2, -sticky => "w");
$mw->new_ttk__label(-text => " \' ", -width => 2)
	->g_grid(-column => 5, -row => 2, -sticky => "w");
$mw->new_ttk__entry(-textvariable => \$secLong, -width => 3)
	->g_grid(-column => 6, -row => 2, -sticky => "w");
$mw->new_ttk__label(-text => ' \'\' ', -width => 2)
	->g_grid(-column => 7, -row => 2, -sticky => "w");

my $buttonReverse = $mw->new_ttk__button(-text => " < ", -state => 'active', -command => \&reverse, -width => 3)
		->g_grid(-column => 8, -row => 2, -sticky => "w");

Tkx::MainLoop();


sub convert {
	$geoPosition = Conversion_coordonate::translateLatLong2Geo($degreLat, $minLat, $degreLong, $minLong);
}

sub reverse {
	($degreLat, $minLat) = Conversion_coordonate::translate2Lat($geoPosition);
	($degreLong, $minLong) = Conversion_coordonate::translate2Long($geoPosition);
}