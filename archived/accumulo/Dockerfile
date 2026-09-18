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

ARG ARCH
FROM testing/almalinux9-oj11:unlabelled$ARCH

ARG ACCUMULO_VERSION=3.0.0
ARG HADOOP_VERSION=3.3.5
ARG ZOOKEEPER_VERSION=3.8.2
ARG IMAGE_ROOT_INSTALL=/usr/local/lib

ENV HADOOP_HOME=$IMAGE_ROOT_INSTALL/hadoop
ENV ACCUMULO_HOME=$IMAGE_ROOT_INSTALL/accumulo
ENV ZOOKEEPER_HOME=$IMAGE_ROOT_INSTALL/zookeeper

ARG HADOOP_CONF=$HADOOP_HOME/conf
ENV HADOOP_PREFIX=$HADOOP_HOME

ARG BASE_URL=https://github.com/trinodb/docker-images/releases/download/dependency-mirror

ARG ACCUMULO_BINARY_SHA512=c992e7ce8073862057173bd1005af2c6b617e6ba2a1fb7f7f3e3aed0876dca6c87794257fe511863ffb9b7a641597bedad730673d4c504abc0ee88c78ecfed01
ARG ACCUMULO_BINARY_PATH=$BASE_URL/sha512-${ACCUMULO_BINARY_SHA512}-accumulo-$ACCUMULO_VERSION-bin.tar.gz

ARG HADOOP_BINARY_SHA512=cc170df24976543a3e961a1353a194225e3ffc5d53d594dd63d71422765e1d816d1ffa877c02bf93f0183fcfbe4c10f4b7739deca69420ed83372a0b1f9d5dc7
ARG HADOOP_BINARY_PATH=$BASE_URL/sha512-${HADOOP_BINARY_SHA512}-hadoop-$HADOOP_VERSION.tar.gz

ARG ZOOKEEPER_BINARY_SHA512=30d42364d158850700623e2b0f226335ce52a9707660c16c64ea9c163fe657c429b5f846d664bf7f381bc86abafb01cdc28d23d9f8e49b99a751e6598342a7af
ARG ZOOKEEPER_BINARY_PATH=$BASE_URL/sha512-${ZOOKEEPER_BINARY_SHA512}-apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz

RUN yum update -y && \
    yum install -y make gcc-c++ && \
    yum clean all -y

RUN mkdir -p $IMAGE_ROOT_INSTALL

# Download Hadoop
RUN wget --quiet -O hadoop-$HADOOP_VERSION.tar.gz $HADOOP_BINARY_PATH && \
    echo "$HADOOP_BINARY_SHA512  hadoop-$HADOOP_VERSION.tar.gz" | sha512sum -c - && \
    tar -xf hadoop-$HADOOP_VERSION.tar.gz -C $IMAGE_ROOT_INSTALL  && \
    rm hadoop-$HADOOP_VERSION.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/hadoop-$HADOOP_VERSION $HADOOP_HOME

# Download Accumulo
RUN wget --quiet -O accumulo-$ACCUMULO_VERSION-bin.tar.gz $ACCUMULO_BINARY_PATH && \
    echo "$ACCUMULO_BINARY_SHA512  accumulo-$ACCUMULO_VERSION-bin.tar.gz" | sha512sum -c - && \
    tar -xf accumulo-$ACCUMULO_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm accumulo-$ACCUMULO_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/accumulo-$ACCUMULO_VERSION $ACCUMULO_HOME

# Compile Accumulo native
RUN cd $ACCUMULO_HOME/lib/ && \
    tar -zxvf $ACCUMULO_HOME/lib/accumulo-native-$ACCUMULO_VERSION.tar.gz && \
    cd $ACCUMULO_HOME/lib/accumulo-native-$ACCUMULO_VERSION && \
    make && \
    mv libaccumulo.so ../native && \
    cd .. && \
    rm -Rf accumulo-native-$ACCUMULO_VERSION*

# Download ZooKeeper
RUN wget --quiet -O apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz $ZOOKEEPER_BINARY_PATH && \
    echo "$ZOOKEEPER_BINARY_SHA512  apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz" | sha512sum -c - && \
    tar -xf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/apache-zookeeper-$ZOOKEEPER_VERSION-bin $ZOOKEEPER_HOME && \
    cp $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg

RUN mkdir -p /var/log/zookeeper /var/log/accumulo

COPY ./files /

RUN mv /etc/accumulo.properties /usr/local/lib/accumulo/conf/

# Initialize Accumulo which requires ZooKeeper to be started
RUN ${ZOOKEEPER_HOME}/bin/zkServer-initialize.sh --myid=0 && \
    ${ZOOKEEPER_HOME}/bin/zkServer.sh start && \
    ${ACCUMULO_HOME}/bin/accumulo init --user root --password secret --instance-name default

# ZooKeeper
EXPOSE 2181
# Accumulo Monitor
EXPOSE 50095
EXPOSE 9995
# Accumulo Monitor Logs
EXPOSE 4560
# Accumulo TabletServer
EXPOSE 9997
# Accumulo TabletServer Replication Service
EXPOSE 10002
# Accumulo GC
EXPOSE 50091
# Accumulo Master
EXPOSE 9999
# Accumulo Replication Service
EXPOSE 10001
# Accumulo Tracer
EXPOSE 12234

ENTRYPOINT ADDRESS=`hostname -I` supervisord -c /etc/supervisord.conf

HEALTHCHECK --start-period=5m \
  CMD $ACCUMULO_HOME/bin/accumulo org.apache.accumulo.server.util.ListInstances | grep default
