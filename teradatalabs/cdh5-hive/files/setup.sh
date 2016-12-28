#!/bin/bash -ex

# 1 format namenode
chown hdfs:hdfs /var/lib/hadoop-hdfs/cache/

# workaround for 'could not open session' bug as suggested here:
# https://github.com/docker/docker/issues/7056#issuecomment-49371610
rm -f /etc/security/limits.d/hdfs.conf
su -c "echo 'N' | hdfs namenode -format" hdfs

# 2 start hdfs
su -c "hdfs datanode  2>&1 > /var/log/hadoop/hdfs/hadoop-hdfs-datanode.log" hdfs&
su -c "hdfs namenode  2>&1 > /var/log/hadoop/hdfs/hadoop-hdfs-namenode.log" hdfs&

# 3 wait for process starting
sleep 10

# remove a broken symlink created by cdh installer so that init-hdfs.sh does no blow up on it
# (hbase-annotations.jar seems not needed in our case)
rm /usr/lib/hive/lib/hbase-annotations.jar

# 4 exec cloudera hdfs init script
/usr/lib/hadoop/libexec/init-hdfs.sh

# 5 init hive directories
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown hive /user/hive/warehouse'

# 6 stop hdfs
killall java

# 7 setup metastore
mysql_install_db

/usr/bin/mysqld_safe &
sleep 10s

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore; USE metastore; SOURCE /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql;" | mysql
/usr/bin/mysqladmin -u root password 'root'

killall mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/

# 8 copy configuration
cp /tmp/hadoop_conf/hive-site.xml /etc/hive/conf/
cp /tmp/hadoop_conf/core-site.xml /etc/hadoop/conf
cp /tmp/hadoop_conf/mapred-site.xml /etc/hadoop/conf
cp /tmp/hadoop_conf/yarn-site.xml /etc/hadoop/conf
cp /tmp/hadoop_conf/hadoop-env.sh /etc/hadoop/conf
cp /tmp/hadoop_conf/hive-env.sh /etc/hive/conf
rm -r /tmp/hadoop_conf

# 9 Init zookeeper
/etc/init.d/zookeeper-server init
