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

FROM teradatalabs/hdp2.5-slave
MAINTAINER Grzegorz Kokosiński <grzegorz.kokosinksi@teradata.com>

ARG JDK_PATH

RUN rpm -e cracklib-dicts --nodeps && \
    yum install -y cracklib-dicts passwd libcgroup && \
    yum -y clean all

RUN mkdir /root/.ssh

COPY files/keys/key.pub /root/.ssh/authorized_keys

RUN chmod 400 /root/.ssh/authorized_keys

RUN passwd --unlock root

RUN echo export JAVA_HOME=$JDK_PATH/ > /etc/profile.d/java.sh

COPY files/supervisord.conf /etc/
