#!/bin/bash -ex

# 1 format namenode
chown hdfs:hdfs /var/lib/hadoop-hdfs/cache/
su -c "echo 'N' | hdfs namenode -format" hdfs

# 2 start hdfs
su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&

# 3 wait for process starting
sleep 10

# 4 init hdfs directories (subset of stuff from /usr/lib/hadoop/libexec/init-hdfs.sh)
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /tmp'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1777 /tmp'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /var'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /var/log'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1775 /var/log'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown yarn:mapred /var/log'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /tmp/hadoop-yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1777 /tmp'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /var/log/hadoop-yarn/apps'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1777 /var/log/hadoop-yarn/apps'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown yarn:mapred /var/log/hadoop-yarn/apps'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /user'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /user/history'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown mapred /user/history'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /user/hive'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 777 /user/hive'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown hive /user/hive'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /user/root'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 777 /user/root'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown root /user/root'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred'
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
chown mysql:mysql /var/log/mysql

# 8 Init zookeeper
/etc/init.d/zookeeper-server init
