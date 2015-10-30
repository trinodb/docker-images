FROM teradatalabs/hdp2.3-base
MAINTAINER Eric Diven <eric.diven@teradata.com>

# INSTALL MYSQL (Hive Metastore)
RUN yum install -y mysql-server yum install mysql-connector-java
RUN mkdir -p /usr/lib/hive/lib \
	&& ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

# CLEANUP
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*

# Good grief. Get rid of the default hdp config.
RUN rm -r /etc/hadoop/conf/*

# Append to the existing supervisor config, which sets up ssh access. This lets
# us add additional programs via the include mechanism
RUN echo -e "\n\n[include]\nfiles = /etc/supervisord.d/*.conf" \
	>> /etc/supervisord.conf

# Add the additional supervisord configuration
COPY files/supervisord.d/* /etc/supervisord.d/

COPY files/conf/* /etc/hadoop/conf/

COPY files/setup.sh /root/setup.sh

# Put the hadoop conf under /tmp. setup.sh will move it to its final location.
COPY files/conf /tmp/hadoop_conf/

RUN cat /etc/hosts && hostname
RUN echo "127.0.0.1	hadoop-master" >>/etc/hosts
RUN cat /etc/hosts && hostname

# Run the setup script
RUN /root/setup.sh

# HDFS PORTS
EXPOSE 50010 1004 50075 1006 50020 8020 50070 50470

# YARN PORTS
EXPOSE 8032 8030 8031 8033 8088 8040 8042 8041 10020 19888

