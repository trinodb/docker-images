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

FROM testing/centos6-oj8:unlabelled

# Change default timezone
RUN ln -snf "/usr/share/zoneinfo/Asia/Kathmandu" /etc/localtime && echo "Asia/Kathmandu" > /etc/timezone

# Setup CDH repo, pin the CDH distribution to a concrete version
RUN wget -nv https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo -P /etc/yum.repos.d \
  && rpm --import https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera \
  && sed -i '/^baseurl=/c\baseurl=https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.15.1/' /etc/yum.repos.d/cloudera-cdh5.repo

# Install Hadoop, Hive (w/ MySQL)
RUN \
    set -xeu && \
    yum install -y \
    hadoop-hdfs-namenode \
    hadoop-hdfs-secondarynamenode \
    hadoop-hdfs-datanode \
    \
    hadoop-mapreduce \
    \
    hadoop-yarn-resourcemanager \
    hadoop-yarn-nodemanager \
    \
    hadoop-client \
    hadoop-conf-pseudo \
    \
    hive \
    hive-metastore \
    hive-server2 \
    \
    mysql-server mysql-connector-java \
    \
  # Cleanup
  && yum -y clean all && rm -rf /tmp/* /var/tmp/* \
  && ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

# Copy configuration files
COPY ./files /

# Run setup script
RUN /root/setup.sh \
  && rm -rf /tmp/* /var/tmp/*

# Setup sock proxy
RUN yum install -y openssh openssh-clients openssh-server && yum -y clean all
RUN ssh-keygen -t rsa -b 4096 -C "automation@teradata.com" -N "" -f /root/.ssh/id_rsa \
  && ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -t dsa -b 1024 -N "" -f /etc/ssh/ssh_host_dsa_key \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 755 /root && chmod 700 /root/.ssh
RUN passwd --unlock root

# HDFS ports
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE port
EXPOSE 9083 10000

# SOCKS port
EXPOSE 1180

CMD supervisord -c /etc/supervisord.conf
