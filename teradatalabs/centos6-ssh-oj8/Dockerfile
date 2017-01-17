# Copyright 2016 Teradata
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM jdeathe/centos-ssh:centos-6-1.2.0
MAINTAINER Teradata Docker Team <docker@teradata.com>

ENV DOCKERIZE_VERSION v0.3.0

ARG JDK_URL
ARG JDK_RPM
ARG JDK_PATH

# Install Oracle Java and presto-admin dependences (already has python 2.6)
RUN \
    # disable the notoriuosly unstable EPEL repo...
    rm -rf /etc/yum.repos.d/epel* && \

    yum install -y \
      wget \
      bzip2 \
      gcc \
      python-devel \
      tar \
      expect \
      python-devel \
      openssl-devel \
      libffi-devel && \
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
RUN printf "cp -f /etc/services-config/ssh/id_rsa \${OPTS_SSH_USER_HOME_DIR}/.ssh/id_rsa\n \
            chown -R \${OPTS_SSH_USER}:${OPTS_SSH_USER} \${OPTS_SSH_USER_HOME_DIR}/.ssh/id_rsa\n \
            chmod 600 \${OPTS_SSH_USER_HOME_DIR}/.ssh/id_rsa\n \
            cp -r \${OPTS_SSH_USER_HOME_DIR}/.ssh /root/.ssh\n\n \
            useradd -ms /bin/bash testuser\n \
            echo "testuser:testpass" | chpasswd" \
            > /etc/bootstrap-extra

RUN awk -v file="/etc/bootstrap-extra" -v lineno=$(($(wc -l < /etc/ssh-bootstrap) - 3)) ' \
    NR==lineno {system("echo ""; cat " file); print; next} \
    1' /etc/ssh-bootstrap > /etc/ssh-bootstrap2 && \
    mv /etc/ssh-bootstrap2 /etc/ssh-bootstrap && \
    chmod +x /etc/ssh-bootstrap

RUN sed -i \
    -e 's/^PermitRootLogin no/PermitRootLogin without-password/g' \
    -e 's/^PasswordAuthentication no/PasswordAuthentication yes/g' \
    /etc/ssh/sshd_config

# Set default password for testing
RUN printf "\nSSH_USER_PASSWORD=password" >> /etc/services-config/ssh/ssh-bootstrap.conf

EXPOSE 22 8080

ENV JAVA_HOME $JDK_PATH/jre/

# Clean up
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*
