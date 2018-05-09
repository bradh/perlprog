use fom03;

my $fom03 = fom03::new("FEDCBA9876543210");
my $currentInitState = $fom03->{currentInitState};
my $netEntryStatus = $fom03->{netEntryStatus};
my $initSetsStatus = $fom03->{initSetsStatus};
print "Current init State\t=\t$currentInitState\n";
print "Net Entry Status \t=\t$netEntryStatus\n";
print "Init Sets Status\t=\t$initSetsStatus\n";
exit 0;