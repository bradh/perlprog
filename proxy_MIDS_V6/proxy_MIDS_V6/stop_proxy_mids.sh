#! /bin/bash
#echo "Arret du proxy mids"

#perl -e 'my $PID = `ps -edf | grep /PROJECTS/Applicatifs/proxy_MIDS/proxy_MIDS_V6.pl | grep -v grep | grep -v sh | grep -v perl`;(@PID) = split(" ",$PID); print "kill -9 $PID[1]\n";system("kill -9 $PID[1]");'

perl -e 'my $PID = `ps -edf | grep /PROJECTS/Applicatifs/proxy_MIDS/proxy_MIDS_V6.pl | grep -v grep | grep -v sh`;(@PID) = split(" ",$PID); print "kill -9 $PID[1]\n";system("kill -9 $PID[1]");'

exit 0



