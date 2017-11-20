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

# Setup CDH repo, pin the CDH distribution to a concrete version
RUN wget -nv http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm \
  && yum --nogpgcheck localinstall -y cloudera-cdh-5-0.x86_64.rpm \
  && rm cloudera-cdh-5-0.x86_64.rpm \
  && rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera \
  && sed -i '/^baseurl=/c\baseurl=https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.9.1/' /etc/yum.repos.d/cloudera-cdh5.repo \

# Install hive, as it's needed by all child images
  && yum install -y hive \

# Cleanup
  && yum -y clean all && rm -rf /tmp/* /var/tmp/* \

# Alias log directories so that files in `/common` can use `/var/log/hadoop/*` format
  && mkdir -p /var/log/hadoop \
  && ln -s /var/log/hadoop-hdfs /var/log/hadoop/hdfs \
  && ln -s /var/log/hadoop-mapreduce /var/log/hadoop/mapreduce \
  && ln -s /var/log/hadoop-yarn /var/log/hadoop/yarn

COPY ./files /
