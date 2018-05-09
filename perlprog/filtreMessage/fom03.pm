package fom03;

use decodeHexaString;
my $debug =0;

sub new {
	my $messageHexa = shift;
	my (@netEntryStatusInterpret) = (  "Net Entry has not begun",
	                               "Net Entry in progress",
	                               "Coarse Synchronization Confirmed",
                                   "Fine Synchronization Achieved",
                                   "Coarse Synchronization Achieved",
                                   "Not Used",
                                   "Not Used",
                                   "Not Used");

    my $netEntryStatusMapping = {   "firstWord" => 1,
                                    "lastWord" => 1,
                                    "firstBit" =>  7,
                                    "lastBit" => 9};

    my (@currentInitStateInterpret) = (   "No Statement",
                                   "Awaiting Load",
                                   "Load In Progress",
                                   "Load Complete, Validity Test In Progress",
                                   "Load Complete, Valid data",
                                   "Load Complete, Segment Count in Error",
                                   "Load Complete, Data Conflict",
                                   "Not used") ;

    my $currentInitStateMapping = {   "firstWord" => 1,
                                      "lastWord" => 1,
                                      "firstBit" =>  11,
                                      "lastBit" => 13};
     my (@initSetsStatusInterpret) = (   "No Statement",
                                   "Set Validity Test In Progress",
                                   "Set Validity Test Complete - Valid Data",
                                   "Set Validity Test Complete - Data Conflict or Set rejected",
                                   "Not used") ;

    my $initSetsStatusMapping = {   "firstWord" => 1,
                                      "lastWord" => 1,
                                      "firstBit" =>  5,
                                      "lastBit" => 6};

    my $currentInitState = @currentInitStateInterpret[decodeHexaString::new(\$messageHexa, $currentInitStateMapping)];
    my $netEntryStatus = @netEntryStatusInterpret[decodeHexaString::new(\$messageHexa, $netEntryStatusMapping)];
    my $initSetsStatus = @initSetsStatusInterpret[decodeHexaString::new(\$messageHexa, $initSetsStatusMapping)];

	my $r_fom03 = {
			"currentInitState" => $currentInitState,
			"netEntryStatus" => $netEntryStatus,
			"initSetsStatus" => $initSetsStatus
		};
    if ($debug){
         my $currentInitState = $r_fom03->{currentInitState};
         print "currentInitState = $currentInitState\n";
    }


	bless $r_fom03;
	return $r_fom03;
}

1
	
	
