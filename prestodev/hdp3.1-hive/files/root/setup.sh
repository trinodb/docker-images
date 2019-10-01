#!/bin/bash -ex

# make file system hostname resolvable
echo "127.0.0.1 hadoop-master" >> /etc/hosts

# format namenode
chown hdfs:hdfs /var/lib/hadoop-hdfs/cache/

mkdir /usr/hdp/current/hadoop-client/logs /var/log/hadoop-hdfs /var/log/hadoop-yarn
chgrp -R hadoop /usr/hdp/current/hadoop-client/logs /var/log/hadoop-hdfs /var/log/hadoop-yarn
chmod -R 770 /usr/hdp/current/hadoop-client/logs /var/log/hadoop-hdfs /var/log/hadoop-yarn

# workaround for 'could not open session' bug as suggested here:
# https://github.com/docker/docker/issues/7056#issuecomment-49371610
rm -f /etc/security/limits.d/hdfs.conf
su -c "echo 'N' | hdfs namenode -format" hdfs

# start hdfs
su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&

# wait for process starting
sleep 15

# init basic hdfs directories
/usr/hdp/current/hadoop-client/libexec/init-hdfs.sh

# 4.1 Create an hdfs home directory for the yarn user. For some reason, init-hdfs doesn't do so.
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/yarn && /usr/bin/hadoop fs -chown yarn:yarn /user/yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging/history'

# init hive directories
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -mkdir /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
su -s /bin/bash hdfs -c '/usr/bin/hadoop fs -chown hive /user/hive/warehouse'

# stop hdfs
killall java

# setup metastore
ln -s /usr/bin/resolveip /usr/libexec # mariadb-server installs resolveip in /usr/bin but mysql_install_db expects it in /usr/libexec
mysql_install_db

chown -R mysql:mysql /var/lib/mysql

/usr/bin/mysqld_safe &
sleep 10s

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore;" | mysql
/usr/bin/mysqladmin -u root password 'root'
/usr/hdp/current/hive-client/bin/schematool -dbType mysql -initSchema

killall mysqld
sleep 10s
mkdir /var/log/mysql/
chown -R mysql:mysql /var/log/mysql/

# Create `information_schema` and `sys` schemas in Hive
supervisord -c /etc/supervisord.conf &
while ! beeline -n hive -e "SELECT 1"; do
    echo "Waiting for HiveServer2 ..."
    sleep 10s
done
/usr/hdp/current/hive-client/bin/schematool -userName hive -metaDbType mysql -dbType hive -initSchema \
    -url jdbc:hive2://localhost:10000/default -driver org.apache.hive.jdbc.HiveDriver
supervisorctl stop all

# Additional libs
cp -av /usr/hdp/current/hadoop-client/lib/native/Linux-amd64-64/* /usr/lib64/
mkdir -v /usr/hdp/current/hive-client/auxlib || test -d /usr/hdp/current/hive-client/auxlib
ln -vs /usr/hdp/current/hadoop-client/lib/hadoop-lzo-*.jar /usr/hdp/current/hive-client/auxlib
