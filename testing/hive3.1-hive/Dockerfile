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
FROM testing/almalinux9-oj17:unlabelled$ARCH

ARG JAVA8_ZULU_VERSION=8.64.0.19-ca-jdk8.0.345

RUN yum install -y \
    mariadb-server \
    openssh \
    openssh-clients \
    openssh-server \
    psmisc \
    passwd \
    which && \
    # Install Zulu JDK
    echo "Downloading zulu${JAVA8_ZULU_VERSION}-linux.$(uname -m).rpm..." && \
    curl -fLsS -o /tmp/jdk8.rpm --url https://cdn.azul.com/zulu$(test "$(uname -m)" != "aarch64" || echo "-embedded")/bin/zulu${JAVA8_ZULU_VERSION}-linux.$(uname -m).rpm && \
    yum -y localinstall /tmp/jdk8.rpm && \
    rm /tmp/jdk8.rpm && \
    # Set JDK 8 as a default one
    alternatives --set java /usr/lib/jvm/zulu-8/jre/bin/java && \
    alternatives --set javac /usr/lib/jvm/zulu-8/bin/javac \
    && yum -q clean all && rm -rf /var/cache/yum

# Override JAVA_HOME inherited from testing/almalinux9-oj17
ENV JAVA_HOME=/usr/lib/jvm/zulu-8

ARG HADOOP_VERSION=3.1.2
ARG HIVE_VERSION=3.1.3

# TODO Apache Archive is rate limited -- these should probably go in S3
ARG HADOOP_BINARY_PATH=https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ARG HIVE_BINARY_PATH=https://dlcdn.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

RUN curl -fLsS -o /tmp/hadoop.tar.gz --url $HADOOP_BINARY_PATH && \
    tar xzf /tmp/hadoop.tar.gz --directory /opt && mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

RUN curl -fLsS -o /tmp/hive.tar.gz --url $HIVE_BINARY_PATH && \
    tar xzf /tmp/hive.tar.gz --directory /opt && mv /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive

ARG MYSQL_CONNECTOR_VERSION=8.0.13
ARG AWS_SDK_VERSION=1.11.906
RUN mkdir /opt/hive/auxlib && \
    curl -fLsS -o /opt/hive/auxlib/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar && \
    curl -fLsS -o /opt/hive/auxlib/aws-java-sdk-core-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/$AWS_SDK_VERSION/aws-java-sdk-core-$AWS_SDK_VERSION.jar && \
    curl -fLsS -o /opt/hive/auxlib/aws-java-sdk-s3-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/$AWS_SDK_VERSION/aws-java-sdk-s3-$AWS_SDK_VERSION.jar

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
