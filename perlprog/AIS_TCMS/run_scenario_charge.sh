#!/bin/sh
echo "démarrage $0 $1"

MAIN="./host_test_driver host_test_driver.conf"
RUN_DIR="/jfacc/Ops/DLIP"
LOG_DIR="/jfacclog/DLIP"
SCRIPT_DIR="/jfacc/Scripts"

cd $RUN_DIR

SCRIPT_NUM = $0

# ------------------
# Launching scenario
# ------------------
echo "Launching host test driver, Pid = $HOST_TD_PID"
$MAIN > /dev/null 2>&1 &
HOST_TD_PID=$!

echo "Waiting end of scenario (1 hour)..."
sleep 3600

echo " killing host test driver..."
kill -9 $HOST_TD_PID

echo "Restart new script"
$0 $SCRIPT_NUM & 

echo "exit previous script"

exit 0
