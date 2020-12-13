#!/bin/bash -x

echo 'N' | hdfs namenode -format
sed -i -e "s|hdfs://localhost|hdfs://$(hostname)|g" /opt/hadoop/etc/hadoop/core-site.xml
hdfs namenode &
sleep 10 && hdfs dfs -mkdir -p /user/hive/warehouse && killall java
