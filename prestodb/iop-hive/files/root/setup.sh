#!/bin/bash -ex

# 0 make file system hostname resolvable
echo "127.0.0.1 hadoop-master" >> /etc/hosts

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

# 4 exec hdfs init script
/usr/iop/4.2.0.0/hadoop/libexec/init-hdfs.sh

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
echo "CREATE DATABASE metastore; USE metastore; SOURCE /usr/iop/4.2.0.0/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql;" | mysql
/usr/bin/mysqladmin -u root password 'root'

killall mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/

# 8 Init zookeeper
/usr/iop/4.2.0.0/zookeeper/bin/zookeeper-server-initialize
