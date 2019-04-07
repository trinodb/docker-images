# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM prestodb/centos6-oj8:latest
MAINTAINER Presto community <https://prestosql.io/community.html>

RUN yum install -y openjdk-8-jdk perl supervisor wget sudo vim \
    && yum -y clean all && rm -rf /tmp/* /var/tmp/*

RUN wget -q -O - https://www-us.apache.org/dist/incubator/druid/0.13.0-incubating/apache-druid-0.13.0-incubating-bin.tar.gz | tar -xzf - -C /usr/local \
  && ln -s /usr/local/apache-druid-0.13.0-incubating /usr/local/druid

RUN wget -q -O - https://archive.apache.org/dist/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz | tar -xzf - -C /usr/local \
  && cp /usr/local/zookeeper-3.4.12/conf/zoo_sample.cfg /usr/local/zookeeper-3.4.12/conf/zoo.cfg \
  && ln -s /usr/local/zookeeper-3.4.12 /usr/local/zookeeper && ln -s /usr/local/zookeeper-3.4.12 /usr/local/druid/zk

COPY ./files /

RUN chmod +x /root/*.sh

# ports & processes:
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 8091: HTTP (middlemanager)
# - 2181 2888 3888: ZooKeeper

# Exposing broker & overlord
EXPOSE 8082
EXPOSE 8090

WORKDIR /usr/local/druid
ENTRYPOINT ["/root/entrypoint.sh"]
