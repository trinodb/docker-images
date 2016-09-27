FROM teradatalabs/centos6-ssh-oj8
MAINTAINER Eric Diven <eric.diven@teradata.com>

RUN wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.3.0.0/hdp.repo -P /etc/yum.repos.d

RUN yum install -y hadoop-hdfs-namenode \
	&& yum install -y hadoop-hdfs-secondarynamenode \
	&& yum install -y hadoop-hdfs-datanode

RUN yum install -y hadoop-mapreduce-historyserver

RUN yum install -y hadoop-yarn-resourcemanager \
	&& yum install -y hadoop-yarn-nodemanager

RUN yum install -y zookeeper \
	&& yum install -y zookeeper-server

RUN yum install -y hive \
	&& yum install -y hive-metastore \
	&& yum install -y hive-server2

# CLEANUP
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*
