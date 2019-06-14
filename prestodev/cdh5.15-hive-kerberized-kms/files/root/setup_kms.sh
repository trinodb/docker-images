#!/bin/bash

set -euo pipefail

function retry() {
  END=$(($(date +%s) + 600))

  while (( $(date +%s) < $END )); do
    set +e
    "$@"
    EXIT_CODE=$?
    set -e

    if [[ ${EXIT_CODE} == 0 ]]; then
      break
    fi
    sleep 5
  done

  return ${EXIT_CODE}
}

echo 127.0.0.2 `# must be different than localhost IP` hadoop-master >> /etc/hosts
supervisord -c /etc/supervisord.conf &

retry kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master@LABS.TERADATA.COM
retry hdfs dfsadmin -safemode leave

set -x
hadoop key create key1 -size 256
hdfs crypto -createZone -keyName key1 -path /user/hive/warehouse
hdfs crypto -listZones

supervisorctl stop all
killall supervisord
wait
