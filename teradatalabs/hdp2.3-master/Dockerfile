FROM teradatalabs/hdp2.3-base
MAINTAINER Eric Diven <eric.diven@teradata.com>

# INSTALL MYSQL (Hive Metastore)
RUN yum install -y mysql-server mysql-connector-java
RUN cp /usr/share/java/mysql-connector-java.jar /usr/hdp/current/hive-metastore/lib

# CLEANUP
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*

# Good grief. Get rid of the default hdp config.
RUN rm -r /etc/hadoop/conf/*
RUN rm -r /etc/zookeeper/conf/*
RUN rm -r /etc/hive/conf/hive-site.xml

# Append to the existing supervisor config, which sets up ssh access. This lets
# us add additional programs via the include mechanism
RUN echo -e "\n\n[include]\nfiles = /etc/supervisord.d/*.conf" \
	>> /etc/supervisord.conf

# Add the additional supervisord configuration
COPY files/supervisord.d/* /etc/supervisord.d/

COPY files/conf-setup/* /etc/hadoop/conf/

COPY files/setup.sh /root/setup.sh

# Create needed dirs
RUN mkdir /var/lib/zookeeper
RUN chown zookeeper:hadoop /var/lib/zookeeper

# Run the setup script
RUN /root/setup.sh

# Copy the real config in now that setup has run
COPY files/conf/* /etc/hadoop/conf/
COPY files/conf-zookeeper/* /etc/zookeeper/conf/
COPY files/conf-hive/* /etc/hive/conf/

# HDFS PORTS
EXPOSE 50010 1004 50075 1006 50020 8020 50070 50470

# YARN PORTS
EXPOSE 8032 8030 8031 8033 8088 8040 8042 8041 10020 19888
