#!/bin/bash

# Script executed by supervisord as bootstrap
####

# It manager the hadoop processes startup sequence via
# the systemctl command. This is the only script launched
# at startup by supervisord.

supervisorctl start zookeeper

supervisorctl start hdfs-namenode hdfs-datanode

supervisorctl start yarn-resourcemanager yarn-nodemanager mapreduce-historyserver

supervisorctl start hive-metastore hive-server2

/sbin/service sshd start

supervisorctl start socks-proxy
