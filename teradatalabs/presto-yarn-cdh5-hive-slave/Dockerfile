FROM teradatalabs/cdh5-hive-slave
MAINTAINER Grzegorz Kokosiński <grzegorz.kokosinksi@teradata.com>

RUN yum install -y openssh-server openssh-clients passwd libcgroup

RUN mkdir /var/run/sshd && mkdir /root/.ssh

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

COPY files/keys/key.pub /root/.ssh/authorized_keys

COPY files/supervisord.d/* /etc/supervisord.d/

RUN chmod 400 /root/.ssh/authorized_keys

EXPOSE 22

CMD /root/startup.sh
