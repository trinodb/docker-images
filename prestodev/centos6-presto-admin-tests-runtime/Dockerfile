FROM jdeathe/centos-ssh:centos-6-1.8.1
MAINTAINER Presto community <https://prestosql.io/community.html>

ENV DOCKERIZE_VERSION v0.3.0

# Install Oracle Java and presto-admin dependences (already has python 2.6)
RUN \
    set -xeu && \
    # disable the unstable mirrors.iuscommunity.org repo...
    rm -rf /etc/yum.repos.d/ius* && \
    \
    yum install -y \
      java-1.8.0-openjdk-devel \
      wget \
      python \
      tar \
      openssl \
      libffi && \
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

# Clean up
RUN yum -y remove wget && \
    yum -y clean all && \
    rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk.x86_64
