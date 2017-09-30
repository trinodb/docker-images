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

FROM centos:6.8
MAINTAINER Teradata Docker Team <docker@teradata.com>

ENV DOCKERIZE_VERSION v0.3.0

ARG JDK_URL
ARG JDK_RPM
ARG JDK_PATH

RUN \
    # disable the notoriuosly unstable EPEL repo...
    rm -rf /etc/yum.repos.d/epel* && \

    yum install -y wget && \

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

ENV JAVA_HOME $JDK_PATH/jre/
