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

FROM library/centos:7

COPY ./files /

# Install Java and presto-admin dependences
RUN \
    set -xeu && \
    yum install -y \
        nc \
        wget \
        && \
    \
    # install Zulu JDK
    rpm -i https://cdn.azul.com/zulu/bin/zulu11.48.21-ca-jdk11.0.11-linux.x86_64.rpm && \
    \
    # install supervisor
    yum --enablerepo=extras install -y setuptools epel-release && \
    yum install -y python-pip && \
    pip install supervisor && \
    \
    # install commonly needed packages
    yum install -y \
        less `# helpful when troubleshooting product tests` \
        net-tools `# netstat is required by run_on_docker.sh` \
        sudo \
        telnet `# helpful when troubleshooting product tests` \
        vim `# helpful when troubleshooting product tests` \
        && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

ENV PATH="/usr/local/bin:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/zulu-11
