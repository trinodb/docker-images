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

FROM testing/centos7-oj11:unlabelled

ARG HBASE_VERSION=1.4.13
ARG ZOOKEEPER_VERSION=3.4.10
ARG PHOENIX_VERSION=4.16.1
ARG PHOENIX_HBASE_VERSION=1.4-$PHOENIX_VERSION
ARG JAVA8_ZULU_VERSION=8.56.0.21-ca-jdk8.0.302
ARG IMAGE_ROOT_INSTALL=/usr/local/lib

ENV HBASE_HOME=$IMAGE_ROOT_INSTALL/hbase
ENV ZOOKEEPER_HOME=$IMAGE_ROOT_INSTALL/zookeeper
ENV PHOENIX_HOME=$IMAGE_ROOT_INSTALL/phoenix

# TODO Apache Archive is rate limited -- these should probably go in S3
ARG BASE_URL=https://archive.apache.org/dist
ARG ZOOKEEPER_BINARY_PATH=$BASE_URL/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz
ARG HBASE_BINARY_PATH=$BASE_URL/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
ARG PHOENIX_BINARY_PATH=$BASE_URL/phoenix/phoenix-$PHOENIX_VERSION/phoenix-hbase-$PHOENIX_HBASE_VERSION-bin.tar.gz

RUN yum update -y && \
    yum install -y gettext && \
    # Install Zulu JDK
    echo "Downloading zulu${JAVA8_ZULU_VERSION}-linux.x86_64.rpm..." && \
    curl -o /tmp/jdk8.rpm --url https://cdn.azul.com/zulu/bin/zulu${JAVA8_ZULU_VERSION}-linux.x86_64.rpm && \
    yum -y localinstall /tmp/jdk8.rpm && \
    rm /tmp/jdk8.rpm && \
    # Set JDK 8 as a default one
    alternatives --set java /usr/lib/jvm/zulu-8/jre/bin/java && \
    alternatives --set javac /usr/lib/jvm/zulu-8/bin/javac && \
    yum clean all -y

# Override JAVA_HOME inherited from testing/centos7-oj11
ENV JAVA_HOME=/usr/lib/jvm/zulu-8

RUN mkdir -p $IMAGE_ROOT_INSTALL

# Download ZooKeeper
RUN wget --quiet $ZOOKEEPER_BINARY_PATH && \
    tar -xf zookeeper-$ZOOKEEPER_VERSION.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/zookeeper-$ZOOKEEPER_VERSION $ZOOKEEPER_HOME && \
    cp $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg

# Download HBase
RUN wget --quiet $HBASE_BINARY_PATH && \
    tar -xf hbase-$HBASE_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm hbase-$HBASE_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/hbase-$HBASE_VERSION $HBASE_HOME

# Download Phoenix
RUN wget --quiet $PHOENIX_BINARY_PATH && \
    tar -xf phoenix-hbase-$PHOENIX_HBASE_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm phoenix-hbase-$PHOENIX_HBASE_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/phoenix-hbase-$PHOENIX_HBASE_VERSION-bin $PHOENIX_HOME

RUN ln -s $PHOENIX_HOME/phoenix-server-hbase-$PHOENIX_HBASE_VERSION.jar $HBASE_HOME/lib/phoenix.jar

RUN mkdir -p /var/log/zookeeper /var/log/hbase

COPY ./files /

RUN cp /etc/hbase/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# ZooKeeper
EXPOSE 2181
# HBase Master
EXPOSE 16000
# HBase Master WebUI
EXPOSE 16010
# HBase RegionServer
EXPOSE 16201
# HBase RegionServer UI
EXPOSE 16301

ENTRYPOINT supervisord -c /etc/supervisord.conf
