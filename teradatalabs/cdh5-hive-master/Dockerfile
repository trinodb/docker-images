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
&& yum -y clean all \

# INSTALL SUPERVISORD
&& easy_install pip \
&& pip install supervisor \
&& mkdir /etc/supervisord.d/

# INSTALL MISSING supervisor dependency
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/python-meld3-0.6.7-1.el6.x86_64.rpm && \
       rpm -ihv python-meld3-0.6.7-1.el6.x86_64.rpm && \
       rm python-meld3-0.6.7-1.el6.x86_64.rpm

# INSTALL MYSQL (Hive Metastore)
RUN ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar

# ADD SUPERVISORD CONFS
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/supervisord.d/* /etc/supervisord.d/

# Add SUPERVISORD BOOTSTRAP SCRIPT
COPY files/bootstrap.sh /root/bootstrap.sh

# ADD STARTUP SCRIPT
COPY files/setup.sh /root/setup.sh
COPY files/startup.sh /root/startup.sh

# DELETE ORIGINAL CONFIGURATION
RUN rm -rf /etc/hadoop/conf/*

# COPY SETUP CONFIGURATION
COPY files/conf-setup/ /etc/hadoop/conf

# RUN SETUP script
RUN /root/setup.sh

# COPY TARGET CONFIGURATION
COPY files/conf/ /etc/hadoop/conf

# CLEANUP
RUN rm -rf /tmp/* /var/tmp/*

# HDFS PORTS
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN PORTS
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE PORT
EXPOSE 9083 10000

CMD /root/startup.sh
