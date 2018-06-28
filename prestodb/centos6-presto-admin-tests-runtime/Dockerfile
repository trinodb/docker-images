FROM jdeathe/centos-ssh:centos-6-1.8.1
MAINTAINER Teradata Docker Team <docker@teradata.com>

ENV DOCKERIZE_VERSION v0.3.0

ENV JDK_URL=http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm
ENV JDK_RPM=jdk-8u162-linux-x64.rpm
ENV JDK_PATH=/usr/java/jdk1.8.0_162

# Install Oracle Java and presto-admin dependences (already has python 2.6)
RUN \
    set -xeu && \
    # disable the notoriuosly unstable EPEL repo...
    # rm -rf /etc/yum.repos.d/epel* && \
    \
    yum install -y \
      wget \
      python \
      tar \
      openssl \
      libffi && \
    # install and trim Oracle JDK
    wget -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL && \
    rpm -ivh $JDK_RPM && rm $JDK_RPM && \
    rm -rf $JDK_PATH/*src.zip \
           $JDK_PATH/lib/missioncontrol \
           $JDK_PATH/lib/visualvm \
           $JDK_PATH/lib/*javafx* \
           $JDK_PATH/jre/lib/plugin.jar \
           $JDK_PATH/jre/lib/ext/jfxrt.jar \
           $JDK_PATH/jre/bin/javaws \
           $JDK_PATH/jre/lib/javaws.jar \
           $JDK_PATH/jre/lib/desktop \
           $JDK_PATH/jre/plugin \
           $JDK_PATH/jre/lib/deploy* \
           $JDK_PATH/jre/lib/*javafx* \
           $JDK_PATH/jre/lib/*jfx* \
           $JDK_PATH/jre/lib/amd64/libdecora_sse.so \
           $JDK_PATH/jre/lib/amd64/libprism_*.so \
           $JDK_PATH/jre/lib/amd64/libfxplugins.so \
           $JDK_PATH/jre/lib/amd64/libglass.so \
           $JDK_PATH/jre/lib/amd64/libgstreamer-lite.so \
           $JDK_PATH/jre/lib/amd64/libjavafx*.so \
           $JDK_PATH/jre/lib/amd64/libjfx*.so && \
    # install dockerize
    wget -nv https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
        && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
        && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

# Copy Vagrant insecure SSH keys for passwordless SSH between
# containers and to localhost
COPY vagrant_insecure_rsa /etc/services-config/ssh/id_rsa

# Modify the ssh-bootstrap script to copy id_rsa to ~/.ssh (the script already makes ~/.ssh
# and copies authorized_keys)
RUN printf "cp -f /etc/services-config/ssh/id_rsa \${OPTS_SSH_USER_HOME}/.ssh/id_rsa\n \
            chown -R \${OPTS_SSH_USER}:${OPTS_SSH_USER} \${OPTS_SSH_USER_HOME}/.ssh/id_rsa\n \
            chmod 600 \${OPTS_SSH_USER_HOME}/.ssh/id_rsa\n \
            cp -r \${OPTS_SSH_USER_HOME}/.ssh /root/.ssh\n\n \
            useradd -ms /bin/bash testuser\n \
            echo "testuser:testpass" | chpasswd" \
            > /usr/sbin/bootstrap-extra

RUN awk -v file="/usr/sbin/bootstrap-extra" -v lineno=$(($(wc -l < /usr/sbin/sshd-bootstrap) - 4)) ' \
    NR==lineno {system("echo ""; cat " file); print; next} \
    1' /usr/sbin/sshd-bootstrap > /usr/sbin/sshd-bootstrap2 && \
    mv /usr/sbin/sshd-bootstrap2 /usr/sbin/sshd-bootstrap && \
    chmod +x /usr/sbin/sshd-bootstrap

#
# The sshd-bootstrap process engages in some tomfoolery with the
# /etc/ssh/sshd_config file during the bootstrap process. Namely, it forcibly
# symlinks /etc/services-config/ssh/sshd_config over it under conditions that
# prevail in our images. This means the canonical source of the sshd
# configuration is the file in /etc/services-config, and we need to modify it,
# rather than the customary file in /etc/ssh.
#
RUN sed -i \
    -e 's/^PermitRootLogin no/PermitRootLogin without-password/g' \
    -e 's/^PasswordAuthentication no/PasswordAuthentication yes/g' \
    /etc/services-config/ssh/sshd_config

# Set default password for testing
RUN printf "\nSSH_USER_PASSWORD=password" >> /etc/services-config/ssh/sshd-bootstrap.conf

EXPOSE 22 8080

ENV JAVA_HOME $JDK_PATH/jre/

# Clean up
RUN yum -y remove wget && \
    yum -y clean all && \
    rm -rf /tmp/* /var/tmp/*
