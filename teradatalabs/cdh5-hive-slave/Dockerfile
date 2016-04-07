FROM teradatalabs/cdh5-base
MAINTAINER Lukasz Osipiuk <lukasz.osipiuk@teradata.com>

# INSTALL HDFS DATANODE and YARN NODEMANAGER
RUN \
    yum install -y \
      hadoop-hdfs-datanode \
      hadoop-yarn-nodemanager \
      python-setuptools \
 && yum -y clean all 

# INSTALL SUPERVISORD
RUN \
    easy_install pip \
 && pip install supervisor \
 && mkdir /etc/supervisord.d/

# INSTALL MISSING supervisor dependency
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/python-meld3-0.6.7-1.el6.x86_64.rpm
RUN rpm -ihv python-meld3-0.6.7-1.el6.x86_64.rpm
RUN rm python-meld3-0.6.7-1.el6.x86_64.rpm

# CLEANUP
RUN rm -rf /tmp/* /var/tmp/*

# ADD SUPERVISORD CONFS
ADD files/supervisord.conf /etc/supervisord.conf
ADD files/supervisord.d/* /etc/supervisord.d/

# Add SUPERVISORD BOOTSTRAP SCRIPT
ADD files/bootstrap.sh /root/bootstrap.sh

# ADD STARTUP SCRIPT
ADD files/startup.sh /root/startup.sh

# CREATE CONF DIRECTORIES
COPY files/conf/ /etc/hadoop/conf

CMD /root/startup.sh
