#!/bin/bash

echo "#################################################"
echo "# setup container"
echo "#################################################"
/root/setup.sh

echo "#################################################"
echo "# start supervisord"
echo "#################################################"
trap 'kill -TERM $PID; wait $PID' TERM
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &
PID=$!
wait $PID

echo "#################################################"
echo "# shutdown container"
echo "#################################################"
exit 0
