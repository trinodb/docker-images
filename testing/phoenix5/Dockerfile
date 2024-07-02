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

ARG HBASE_VERSION=2.5.8
ARG ZOOKEEPER_VERSION=3.9.2
ARG PHOENIX_VERSION=5.2.0
ARG PHOENIX_HBASE_VERSION=2.5-$PHOENIX_VERSION
ARG IMAGE_ROOT_INSTALL=/usr/local/lib

ENV HBASE_HOME=$IMAGE_ROOT_INSTALL/hbase
ENV ZOOKEEPER_HOME=$IMAGE_ROOT_INSTALL/zookeeper
ENV PHOENIX_HOME=$IMAGE_ROOT_INSTALL/phoenix

# TODO Apache Archive is rate limited -- these should probably go in S3
ARG BASE_URL=https://dlcdn.apache.org
ARG ZOOKEEPER_BINARY_PATH=$BASE_URL/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz
ARG HBASE_BINARY_PATH=$BASE_URL/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
ARG PHOENIX_BINARY_PATH=$BASE_URL/phoenix/phoenix-$PHOENIX_VERSION/phoenix-hbase-$PHOENIX_HBASE_VERSION-bin.tar.gz

RUN mkdir -p $IMAGE_ROOT_INSTALL

# Download ZooKeeper
RUN wget --quiet $ZOOKEEPER_BINARY_PATH && \
    tar -xf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/apache-zookeeper-$ZOOKEEPER_VERSION-bin $ZOOKEEPER_HOME && \
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
EXPOSE 16020
# HBase RegionServer UI
EXPOSE 16030

ENTRYPOINT supervisord -c /etc/supervisord.conf
