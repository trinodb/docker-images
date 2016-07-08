FROM teradatalabs/hdp2.3-master
MAINTAINER Grzegorz Kokosiński <grzegorz.kokosinksi@teradata.com>

RUN rpm -e cracklib-dicts --nodeps && \
    yum install -y cracklib-dicts passwd libcgroup unzip && \
    yum -y clean all

RUN mkdir /root/.ssh

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

COPY files/keys/key.pub /root/.ssh/authorized_keys

RUN chmod 400 /root/.ssh/authorized_keys

RUN passwd --unlock root

RUN echo export JAVA_HOME=/usr/java/jdk1.8.0_92/ > /etc/profile.d/java.sh

COPY files/supervisord.conf /etc/
