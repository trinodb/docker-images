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

FROM prestosql/hdp2.5-base:unlabelled
MAINTAINER Teradata Docker Team <docker@teradata.com>

# INSTALL MYSQL (Hive Metastore)
RUN yum install -y mysql-server mysql-connector-java \
    && yum -y clean all && rm -rf /tmp/* /var/tmp/* \
    && ln -s /usr/share/java/mysql-connector-java.jar /usr/hdp/current/hive-metastore/lib/mysql-connector-java.jar

# ADD SETUP AND BOOTSTRAP SCRIPTS
COPY files/bootstrap.sh files/setup.sh /root/

# Create needed dirs
RUN mkdir /var/lib/zookeeper
RUN chown zookeeper:hadoop /var/lib/zookeeper

# DELETE ORIGINAL CONFIGURATION
RUN rm -rf /etc/hadoop/conf/*
RUN rm -r /etc/zookeeper/conf/*
RUN rm -r /etc/hive/conf/hive-site.xml

# COPY SETUP CONFIGURATION
COPY files/conf-setup/* /etc/hadoop/conf/

# RUN SETUP script
RUN /root/setup.sh && rm -rf /tmp/* /var/tmp/*

# COPY TARGET CONFIGURATION
COPY files/conf/* /etc/hadoop/conf/
COPY files/conf-zookeeper/* /etc/zookeeper/conf/
COPY files/conf/hive-site.xml /etc/hive/conf/

# HDFS PORTS
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN PORTS
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

CMD /root/startup.sh
