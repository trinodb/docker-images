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
# Add IBM IOP repo
  wget -nv https://ibm-open-platform.ibm.com/repos/IOP/rhel/6/x86_64/4.2.x/GA/IOP.repo -P /etc/yum.repos.d \

# Install hive
  && yum install -y hive_4_2_0_0 \

# Alias log directories so that files in `/common` can use `/var/log/hadoop/*` format
  && mkdir -p /var/log/hadoop \
  && ln -s /var/log/hadoop-hdfs /var/log/hadoop/hdfs \
  && ln -s /var/log/hadoop-mapreduce /var/log/hadoop/mapreduce \
  && ln -s /var/log/hadoop-yarn /var/log/hadoop/yarn \

# Cleanup
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

COPY ./files /
