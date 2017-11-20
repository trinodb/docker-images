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

FROM prestodb/centos6-oj8:unlabelled
MAINTAINER Presto community <https://prestodb.io/community.html>

RUN \
  wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.5.0.0/hdp.repo -P /etc/yum.repos.d \

  && yum install -y \
    hadoop-hdfs-namenode \
    hadoop-hdfs-secondarynamenode \
    hadoop-hdfs-datanode \

    hadoop-mapreduce-historyserver \

    hadoop-yarn-resourcemanager \
    hadoop-yarn-nodemanager \

    zookeeper \
    zookeeper-server \

    hive \
    hive-metastore \
    hive-server2 \

  && yum install -y epel-release && yum install -y python-pip && pip install supervisor \

  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

COPY ./files /
