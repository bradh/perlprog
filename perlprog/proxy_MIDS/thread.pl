#!/usr/bin/perl -w
        
use POSIX ":sys_wait_h"; # for nonblocking read

my %children;

$SIG{CHLD} = sub {
	# don't change $! and $? outside handler
	local ($!, $?);
	print " $! and $?\n";
	while ( (my $pid = waitpid(-1, WNOHANG)) > 0 ) {
		delete $children{$pid};
		#cleanup_child($pid, $?);
	}
};

print "Hello world !\n";
sleep 1;
while(1){
	die "can't fork: $!" unless defined($kidpid = fork());
	if($kidpid){
		while(kill 0 => $kidpid){
			print "parent is running...\n";
			print "kid $kidpid is alive...\n";
			sleep 1;
		}
		print "kid is dead !\n";
		print "a new will be done...\n";
		#exit 0;
	}
	else{
		$children{$kidpid} = 1;
		my $i = 10;
		while($i){
			print "Kid $kidpid is running...\n";
			sleep 1;
			$i--;
		}
		exit 0;       	
	}
}
exit 0;
