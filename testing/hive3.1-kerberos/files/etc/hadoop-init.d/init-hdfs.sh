#!/bin/bash -xe

keytab_source_dir=/etc/security/keytabs

wait_for_keytab()
{
  local keytab_path="$1"
  for attempt in $(seq 1 60); do
    if [ -s "${keytab_path}" ]; then
      return 0
    fi
    sleep 1
  done
  echo "Timed out waiting for keytab: ${keytab_path}" >&2
  return 1
}

# Stage externally provided keytabs at legacy paths expected by Hadoop/Hive services.
for keytab in hdfs hive HTTP mapred yarn; do
  wait_for_keytab "${keytab_source_dir}/${keytab}.keytab"
  cp "${keytab_source_dir}/${keytab}.keytab" "/opt/hadoop/etc/hadoop/${keytab}.keytab"
done
cp "${keytab_source_dir}/hive.keytab" "/opt/hive/conf/hive.keytab"

hdfs_keytab="${keytab_source_dir}/hdfs.keytab"

# Wait for external KDC and verify keytab-based auth before starting Hadoop services.
for attempt in $(seq 1 30); do
  if kinit -kt "${hdfs_keytab}" hdfs/hadoop-master@TRINO.TEST; then
    break
  fi
  if [ "$attempt" -eq 30 ]; then
    echo "Failed to kinit against external KDC after ${attempt} attempts" >&2
    exit 1
  fi
  sleep 2
done

echo 'N' | hdfs namenode -format
sed -i -e "s|hdfs://localhost|hdfs://$(hostname)|g" /opt/hadoop/etc/hadoop/core-site.xml
hdfs namenode &
sleep 10

hdfs dfs -mkdir -p /user/hive/warehouse
killall java
