# Copyright 2016 Teradata
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM teradatalabs/centos6-ssh-oj8
MAINTAINER Eric Diven <eric.diven@teradata.com>

RUN wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.5.0.0/hdp.repo -P /etc/yum.repos.d

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
