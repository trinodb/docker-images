#!/bin/bash

set -xeuo pipefail

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

supervisord -c /etc/supervisord.conf &

retry kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master@LABS.TERADATA.COM
retry hdfs dfsadmin -safemode leave

retry kinit -kt /etc/hive/conf/hive.keytab hive/hadoop-master@LABS.TERADATA.COM
while ! beeline -n hive -e "SELECT 1"; do
    echo "Waiting for HiveServer2 ..."
    sleep 10s
done

# the default directory must be empty before enabling encryption
hiveUrl="jdbc:hive2://hadoop-master:10000/default;principal=hive/hadoop-master@LABS.TERADATA.COM"
beeline -u "$hiveUrl" -e "drop schema information_schema cascade; drop schema sys cascade;"
hadoop fs -rm -f -r /user/hive/warehouse/.Trash

retry kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master@LABS.TERADATA.COM
hadoop key create key1 -size 256
hdfs crypto -createZone -keyName key1 -path /user/hive/warehouse
hdfs crypto -listZones

# Create `information_schema` and `sys` schemas in Hive
retry kinit -kt /etc/hive/conf/hive.keytab hive/hadoop-master@LABS.TERADATA.COM
/usr/hdp/current/hive-client/bin/schematool -userName hive -metaDbType mysql -dbType hive \
    -url "$hiveUrl" -driver org.apache.hive.jdbc.HiveDriver \
    -initSchema

su -s /bin/bash hdfs -c 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master@LABS.TERADATA.COM'
for username in alice bob charlie; do
    su -s /bin/bash hdfs -c "/usr/bin/hadoop fs -mkdir /user/$username"
    su -s /bin/bash hdfs -c "/usr/bin/hadoop fs -chown $username /user/$username"
done

supervisorctl stop all
pkill -F /var/run/supervisord.pid
wait

# Purge Kerberos credential cache of root user
kdestroy

find /var/log -type f -name \*.log -printf "truncate %p\n" -exec truncate --size 0 {} \; && \
# Purge /tmp, this includes credential caches of other users
find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} +
