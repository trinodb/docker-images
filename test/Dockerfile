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

FROM teradatalabs/centos6-java8-oracle

ENV DOCKERIZE_VERSION v0.3.0

RUN \
  yum install -y \
    wget \
    unzip \

  # setup CDH repo, pin the CDH distribution to a concrete version
  && wget -nv http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm \
  && yum --nogpgcheck localinstall -y cloudera-cdh-5-0.x86_64.rpm \
  && rm cloudera-cdh-5-0.x86_64.rpm \
  && rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera \
  && sed -i '/^baseurl=/c\baseurl=https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.8.2/' /etc/yum.repos.d/cloudera-cdh5.repo \

  # install BATS bash test lib
  && wget -nv https://github.com/ArturGajowy/bats/archive/6959d91.zip -O /tmp/bats.zip \
  && unzip -q /tmp/bats.zip -d /tmp \
  && /tmp/bats-*/install.sh /usr/local \

  # install dockerize
  && wget -nv https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \

  # install hive so that we can use beeline
  && yum install -y hive \

  # cleanup
  && yum -y clean all && rm -rf /tmp/* /var/tmp/* \

  # create 'image_tests' volume mount path
  && mkdir /image_tests

VOLUME /image_tests

ENTRYPOINT bats -t /image_tests
