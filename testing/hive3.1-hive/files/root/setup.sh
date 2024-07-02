#!/bin/bash -ex

ln -s /usr/bin/re solveip /usr/libexec # mariadb-server installs resolveip in /usr/bin but mysql_install_db expects it in /usr/libexec
mkdir /var/log/mysql /var/log/hive /var/log/hadoop-hdfs

mysql_install_db

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/log/mariadb

/usr/bin/mysqld_safe &
sleep 10s

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore;" | mysql
/usr/bin/mysqladmin -u root password 'root'
/opt/hive/bin/schematool -dbType mysql -initSchema

sleep 10s
chown -R mysql:mysql /var/log/mysql/
rm -rf /tmp/* /var/tmp/*
