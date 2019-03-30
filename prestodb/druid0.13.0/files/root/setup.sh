#!/bin/bash
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

set -e
set -u

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y openjdk-8-jdk perl supervisor wget

# Kafka
# Match the version to the Kafka client used by KafkaSupervisor
wget -q -O - http://www.us.apache.org/dist/kafka/2.1.0/kafka_2.12-2.1.0.tgz | tar -xzf - -C /usr/local \
 && ln -s /usr/local/kafka_2.12-2.1.0 /usr/local/kafka

# Druid system user
adduser --system --group --no-create-home druid \
  && mkdir -p /var/lib/druid \
  && chown druid:druid /var/lib/druid

# Druid
wget -q -O - https://www-us.apache.org/dist/incubator/druid/0.13.0-incubating/apache-druid-0.13.0-incubating-bin.tar.gz | tar -xzf - -C /usr/local \
  && ln -s /usr/local/apache-druid-0.13.0-incubating /usr/local/druid

# Zookeeper
wget -q -O - http://www.us.apache.org/dist/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz | tar -xzf - -C /usr/local \
  && cp /usr/local/zookeeper-3.4.13/conf/zoo_sample.cfg /usr/local/zookeeper-3.4.13/conf/zoo.cfg \
  && ln -s /usr/local/zookeeper-3.4.13 /usr/local/zookeeper && ln -s /usr/local/zookeeper-3.4.13 /usr/local/druid/zk

# clean up time
apt-get clean \
  && rm -rf /tmp/* \
            /var/tmp/* \
            /var/lib/apt/lists \
            /root/.m2
