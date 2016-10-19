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
MAINTAINER Teradata Docker Team <docker@teradata.com>

# INSTALL HADOOP AND HIVE
RUN \
  yum install -y \
    hive \
    hive-server \
    hadoop-hdfs-namenode \
    hadoop-yarn-resourcemanager \
    hadoop-yarn-nodemanager \
    zookeeper-server \
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

# INSTALL MYSQL (Hive Metastore)
RUN yum install -y mysql-server mysql-connector-java \
    && yum -y clean all && rm -rf /tmp/* /var/tmp/* \
    && ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

# ADD SUPERVISORD CONFS
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/supervisord.d/* /etc/supervisord.d/

# ADD SETUP AND STARTUP SCRIPTS
COPY files/bootstrap.sh files/setup.sh files/startup.sh /root/

# DELETE ORIGINAL CONFIGURATION
RUN rm -rf /etc/hadoop/conf/*

# COPY SETUP CONFIGURATION
COPY files/conf-setup/ /etc/hadoop/conf

# RUN SETUP script
RUN /root/setup.sh && rm -rf /tmp/* /var/tmp/*

# COPY TARGET CONFIGURATION
COPY files/conf/ /etc/hadoop/conf

# HDFS PORTS
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN PORTS
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE PORT
EXPOSE 9083 10000

CMD /root/startup.sh
