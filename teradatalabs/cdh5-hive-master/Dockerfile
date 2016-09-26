FROM teradatalabs/cdh5-base
MAINTAINER Lukasz Osipiuk <lukasz.osipiuk@teradata.com>

# INSTALL PACKAGES
RUN \
   yum install -y \
     hive \
     hive-server \
     hadoop-hdfs-namenode \
     hadoop-yarn-resourcemanager \
     hadoop-yarn-nodemanager \
     zookeeper-server \
     mysql-server \
     mysql-connector-java \
     python-setuptools \
&& yum -y clean all

# INSTALL MYSQL (Hive Metastore)
RUN ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

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
RUN /root/setup.sh

# COPY TARGET CONFIGURATION
COPY files/conf/ /etc/hadoop/conf

# HDFS PORTS
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN PORTS
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE PORT
EXPOSE 9083 10000

CMD /root/startup.sh
