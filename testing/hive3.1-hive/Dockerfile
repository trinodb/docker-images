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

FROM testing/centos7-oj8:unlabelled

RUN yum install -y \
    mariadb-server \
    openssh \
    openssh-clients \
    openssh-server \
    psmisc \
    which \
    && yum -q clean all && rm -rf /var/cache/yum

ARG HADOOP_VERSION=3.1.2
ARG HIVE_VERSION=3.1.2

# TODO Apache Archive is rate limited -- these should probably go in S3
ARG HADOOP_BINARY_PATH=https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ARG HIVE_BINARY_PATH=https://apache.mivzakim.net/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

RUN curl -o /tmp/hadoop.tar.gz --url $HADOOP_BINARY_PATH && \
    tar xzf /tmp/hadoop.tar.gz --directory /opt && mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

RUN curl -o /tmp/hive.tar.gz --url $HIVE_BINARY_PATH && \
    tar xzf /tmp/hive.tar.gz --directory /opt && mv /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive

ARG MYSQL_CONNECTOR_VERSION=8.0.13
ARG AWS_SDK_VERSION=1.11.906
RUN mkdir /opt/hive/auxlib && \
    curl -o /opt/hive/auxlib/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar && \
    curl -o /opt/hive/auxlib/aws-java-sdk-core-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/$AWS_SDK_VERSION/aws-java-sdk-core-$AWS_SDK_VERSION.jar && \
    curl -o /opt/hive/auxlib/aws-java-sdk-s3-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/$AWS_SDK_VERSION/aws-java-sdk-s3-$AWS_SDK_VERSION.jar

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/*
ENV PATH=${HIVE_HOME}/bin:${HADOOP_HOME}/bin:${PATH}

RUN ssh-keygen -t rsa -b 4096 -C "automation@trino.io" -N "" -f /root/.ssh/id_rsa && \
    ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 755 /root && chmod 700 /root/.ssh
RUN passwd --unlock root

# Copy configuration files
COPY ./files /

# Run setup script
RUN /root/setup.sh

# HDFS port
EXPOSE 9000 9870

# HIVE Metastore port
EXPOSE 9083 10000

CMD /root/entrypoint.sh
