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
FROM testing/centos7-oj17:unlabelled$ARCH

ARG ACCUMULO_VERSION=1.7.4
ARG HADOOP_VERSION=2.6.5
ARG ZOOKEEPER_VERSION=3.4.14
ARG JAVA8_ZULU_VERSION=8.56.0.21-ca-jdk8.0.302
ARG IMAGE_ROOT_INSTALL=/usr/local/lib

ENV HADOOP_HOME=$IMAGE_ROOT_INSTALL/hadoop
ENV ACCUMULO_HOME=$IMAGE_ROOT_INSTALL/accumulo
ENV ZOOKEEPER_HOME=$IMAGE_ROOT_INSTALL/zookeeper

ARG HADOOP_CONF=$HADOOP_HOME/conf
ENV HADOOP_PREFIX=$HADOOP_HOME

# TODO Apache Archive is rate limited -- these should probably go in S3
ARG BASE_URL=https://archive.apache.org/dist
ARG ACCUMULO_BINARY_PATH=$BASE_URL/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz
ARG HADOOP_BINARY_PATH=$BASE_URL/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ARG ZOOKEEPER_BINARY_PATH=$BASE_URL/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz

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

# Override JAVA_HOME inherited from testing/centos7-oj17
ENV JAVA_HOME=/usr/lib/jvm/zulu-8

RUN mkdir -p $IMAGE_ROOT_INSTALL

# Download Hadoop
RUN wget --quiet $HADOOP_BINARY_PATH && \
    tar -xf hadoop-$HADOOP_VERSION.tar.gz -C $IMAGE_ROOT_INSTALL  && \
    rm hadoop-$HADOOP_VERSION.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/hadoop-$HADOOP_VERSION $HADOOP_HOME

# Download Accumulo
RUN wget --quiet $ACCUMULO_BINARY_PATH && \
    tar -xf accumulo-$ACCUMULO_VERSION-bin.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm accumulo-$ACCUMULO_VERSION-bin.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/accumulo-$ACCUMULO_VERSION $ACCUMULO_HOME

# Copy sample Accumulo configuration files and update the instance.volumes property
ENV CONF_SAMPLE_DIR=$ACCUMULO_HOME/conf/examples/3GB/standalone
RUN cp \
    $CONF_SAMPLE_DIR/accumulo-env.sh \
    $CONF_SAMPLE_DIR/accumulo-site.xml \
    $CONF_SAMPLE_DIR/auditLog.xml \
    $CONF_SAMPLE_DIR/generic_logger.properties \
    $CONF_SAMPLE_DIR/generic_logger.xml \
    $CONF_SAMPLE_DIR/log4j.properties \
    $CONF_SAMPLE_DIR/monitor_logger.properties \
    $CONF_SAMPLE_DIR/monitor_logger.xml \
    $ACCUMULO_HOME/conf && \
    sed -i s/"<value><\/value>"/"<value>file:\/\/\/tmp\/accumulo<\/value>"/ $ACCUMULO_HOME/conf/accumulo-site.xml

# Download ZooKeeper
RUN wget --quiet $ZOOKEEPER_BINARY_PATH && \
    tar -xf zookeeper-$ZOOKEEPER_VERSION.tar.gz -C $IMAGE_ROOT_INSTALL && \
    rm zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    ln -s $IMAGE_ROOT_INSTALL/zookeeper-$ZOOKEEPER_VERSION $ZOOKEEPER_HOME && \
    cp $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg

RUN mkdir -p /var/log/zookeeper /var/log/accumulo

COPY ./files /

# Initialize Accumulo which requires ZooKeeper to be started
RUN ${ZOOKEEPER_HOME}/bin/zkServer.sh start && \
    ${ACCUMULO_HOME}/bin/accumulo init --user root --password secret --instance-name default

# ZooKeeper
EXPOSE 2181
# Accumulo Monitor
EXPOSE 50095
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
