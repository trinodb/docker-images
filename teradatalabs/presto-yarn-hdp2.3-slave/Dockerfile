FROM teradatalabs/hdp2.3-slave:1
MAINTAINER Grzegorz Kokosiński <grzegorz.kokosinksi@teradata.com>

RUN rpm -e cracklib-dicts --nodeps && \
    yum install -y cracklib-dicts passwd libcgroup && \
    yum -y clean all

RUN mkdir /root/.ssh

COPY files/keys/key.pub /root/.ssh/authorized_keys

RUN chmod 400 /root/.ssh/authorized_keys

RUN passwd --unlock root

RUN echo export JAVA_HOME=/usr/java/jdk1.8.0_40/ > /etc/profile.d/java.sh

COPY files/supervisord.conf /etc/
