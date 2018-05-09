#!/bin/sh
echo "demarrage $0 $1"

MAIN="./host_test_driver host_test_driver.conf"
RUN_DIR="/jfacc/Ops/DLIP"
LOG_DIR="/jfacclog/DLIP"
SCRIPT_DIR="/jfacc/Scripts"
SCRIPT_LOOP_MAX=10
SCRIPT_NUM=`expr $1 + 1`

if [ $SCRIPT_NUM -le $SCRIPT_LOOP_MAX ] 
then
	
	echo "Launching recording..."
	snoop -d bge0 -o fxm$1.pcap -r -t a host 192.168.0.31 port 9000 tcp &

	SNOOP_PID=$!

	$MAIN > /dev/null 2>&1 &
	HOST_TD_PID=$!
	echo "Launching host test driver, Pid = $HOST_TD_PID"

	echo "Waiting end of scenario (1 hour)..."
	sleep 10

	echo " killing host test driver..."
	kill -9 $HOST_TD_PID

	echo "Stop recording ..."
	kill -9 $SNOOP_PID

	echo "Restart new script"
	$0 $SCRIPT_NUM & 

	echo "exit previous script"
fi

exit 0
