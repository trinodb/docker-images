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

FROM teradatalabs/cdh5-base
MAINTAINER Stanislaw Ogorkis <stanislaw.ogorkis@teradata.com>

# INSTALL HADOOP AND HIVE
RUN yum install -y hadoop-conf-pseudo hive hive-server2 zookeeper-server

# INSTALL MYSQL (Hive Metastore)
RUN yum install -y mysql-server yum install mysql-connector-java
RUN ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

# CLEANUP
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*

# ADD SUPERVISORD CONFS
ADD files/supervisord.conf /etc/supervisord.conf
ADD files/supervisord.d/* /etc/supervisord.d/

# Add SUPERVISORD BOOTSTRAP SCRIPT
ADD files/bootstrap.sh /root/bootstrap.sh

# ADD STARTUP SCRIPT
ADD files/setup.sh /root/setup.sh
ADD files/startup.sh /root/startup.sh

# CREATE CONF DIRECTORIES
RUN mkdir /tmp/hadoop_conf
COPY files/conf/ /tmp/hadoop_conf

# RUN SETUP script
RUN /root/setup.sh

# SETUP SOCKS PROXY
RUN yum install -y openssh openssh-clients openssh-server
RUN ssh-keygen -t rsa -b 4096 -C "automation@teradata.com" -N "" -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
ADD files/socks-proxy.sh /root/socks-proxy.sh

# HDFS PORTS
EXPOSE 50010 1004 50075 1006 50020 8020 50070 50470

# YARN PORTS
EXPOSE 8032 8030 8031 8033 8088 8040 8042 8041 10020 19888

# HIVE PORT
EXPOSE 10000 9083

# SOCKS PORT
EXPOSE 1080

CMD /root/startup.sh
