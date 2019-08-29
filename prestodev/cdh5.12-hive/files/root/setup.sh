#!/bin/bash -ex

# make file system hostname resolvable
echo "127.0.0.1 hadoop-master" >> /etc/hosts

# format namenode
chown hdfs:hdfs /var/lib/hadoop-hdfs/cache/

# workaround for 'could not open session' bug as suggested here:
# https://github.com/docker/docker/issues/7056#issuecomment-49371610
rm -f /etc/security/limits.d/hdfs.conf
su -c "echo 'N' | hdfs namenode -format" hdfs

# start hdfs
su -c "hdfs datanode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-datanode.log" hdfs&
su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&

# wait for process starting
sleep 10

# remove a broken symlink created by cdh installer so that init-hdfs.sh does no blow up on it
# (hbase-annotations.jar seems not needed in our case)
rm /usr/lib/hive/lib/hbase-annotations.jar

# 4 exec cloudera hdfs init script
/usr/lib/hadoop/libexec/init-hdfs.sh

# init hive directories
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown hive /user/hive/warehouse'

# stop hdfs
killall java

# setup metastore
mysql_install_db

/usr/bin/mysqld_safe &
sleep 10s

cd /usr/lib/hive/scripts/metastore/upgrade/mysql/
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore; USE metastore; SOURCE hive-schema-1.1.0.mysql.sql;" | mysql
/usr/bin/mysqladmin -u root password 'root'

killall mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/
