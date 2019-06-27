#!/bin/bash -ex

# 0 make file system hostname resolvable
echo "127.0.0.1 hadoop-master" >> /etc/hosts

# 1 format namenode
chown hdfs:hdfs /var/lib/hadoop-hdfs/cache/

mkdir -p /usr/hdp/3.1.0.0-78/hadoop/logs
mkdir -p /var/log/hadoop-hdfs
mkdir -p  /var/log/hadoop-yarn
sudo chgrp -R hadoop /usr/hdp/3.1.0.0-78/hadoop/logs /var/log/hadoop-hdfs /var/log/hadoop-yarn
chmod -R 770 /usr/hdp/3.1.0.0-78/hadoop/logs /var/log/hadoop-hdfs /var/log/hadoop-yarn

# workaround for 'could not open session' bug as suggested here:
# https://github.com/docker/docker/issues/7056#issuecomment-49371610
rm -f /etc/security/limits.d/hdfs.conf
su -c "echo 'N' | hdfs namenode -format" hdfs

# 2 start hdfs
su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&

# 3 wait for process starting
sleep 15

# 4 init basic hdfs directories
/usr/hdp/current/hadoop-client/libexec/init-hdfs.sh

# 4.1 Create an hdfs home directory for the yarn user. For some reason, init-hdfs doesn't do so.
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/yarn && /usr/bin/hadoop fs -chown yarn:yarn /user/yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging/history'



# 5 init hive directories
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown hive /user/hive/warehouse'

# 6 stop hdfs
killall java

# 7 setup metastore
mysql_install_db

# Without this getting perm error https://dba.stackexchange.com/questions/56441/cant-find-file-mysql-plugin-frm-when-starting-up-mysql
chown -R mysql:mysql /var/lib/mysql
chgrp -R mysql /var/lib/mysql
rm -f  /var/lib/mysql/ib_logfile0
rm -f  /var/lib/mysql/ib_logfile1

/usr/bin/mysqld_safe &
sleep 10s

cd /usr/hdp/current/hive-metastore/scripts/metastore/upgrade/mysql/
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore; USE metastore; SOURCE hive-schema-3.1.0.mysql.sql;" | mysql
/usr/bin/mysqladmin -u root password 'root'

killall mysqld
sleep 10s
mkdir /var/log/mysql/
chown -R mysql:mysql /var/log/mysql/
