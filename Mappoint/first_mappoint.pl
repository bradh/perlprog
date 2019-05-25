use Win32::OLE qw(in with);
use Win32::OLE::Const;
use Win32::OLE::Const 'Microsoft MapPoint';
$Win32::OLE::Warn = 3;


# die on errors...

@states = ("Paris","Alaska","Arizona","Arkansas","California","Colorado","Connecticut",
"Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
"Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota",
"Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey",
"New Mexico","New York","North Carolina", "North Dakota","Ohio","Oklahoma","Oregon",
"Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah",
"Vermont","Virginia","Washington","Washington, DC","West Virginia","Wisconsin","Wyoming");

my $MapPoint = Win32::OLE->new('MapPoint.Application', 'Quit');
my $Map = $MapPoint->NewMap();

for ($i = 0; $i <= 5; $i++) {
  my $Results = $Map->FindPlaceResults($states[$i]);
  print "$states[$i]\n";
  my $Location = $Results->Item(1);
  $Location->GoTo;
  $Map->SaveAs($states[$i], 2);
}
$Map->{Saved} = -1;

