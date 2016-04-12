#!/bin/bash

# Script executed by supervisord as bootstrap
####

# It manager the hadoop processes startup sequence via
# the systemctl command. This is the only script launched
# at startup by supervisord.

# 1 Zookeeper
supervisorctl start zookeeper

# 2 HDFS
supervisorctl start hdfs-namenode

# 3 YARN
supervisorctl start yarn-resourcemanager mapreduce-historyserver
supervisorctl start yarn-nodemanager

# 4 Hive
supervisorctl start hive-metastore hive-server2
