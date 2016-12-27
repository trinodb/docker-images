#!/bin/bash

PIDS=""
RESULT=0

for i in teradatalabs/*; do
  set -o pipefail
  docker pull ${i} | grep -v 'Downloading|Extracting' | sed -e "s/^/[ ${i#teradatalabs/} ] /" &
  PIDS="$PIDS $!"
done

for PID in $PIDS; do
  wait $PID || let "RESULT=$?"
done

exit $RESULT