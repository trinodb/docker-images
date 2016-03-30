#!/bin/bash

# Script executed by supervisord as bootstrap
####

# It manager the hadoop processes startup sequence via
# the systemctl command. This is the only script launched
# at startup by supervisord.

# 1 Zookeeper
supervisorctl start zookeeper

# 2 HDFS
supervisorctl start hdfs-namenode hdfs-datanode

# 3 YARN
supervisorctl start yarn-resourcemanager yarn-nodemanager mapreduce-historyserver

# 4 Hive
supervisorctl start hive-metastore hive-server2

# 5 sshd
supervisorctl start sshd

# 6 socks-proxy
supervisorctl start socks-proxy
