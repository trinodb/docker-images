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

FROM library/centos:6.9
MAINTAINER Presto community <https://prestosql.io/community.html>

# Install Java and presto-admin dependences (already has python 2.6)
RUN \
    set -xeu && \
    yum install -y \
        java-1.8.0-openjdk-devel \
        wget \
        && \
    \
    # install supervisor
    yum install -y setuptools epel-release && \
    yum install -y python-pip && \
    pip install --upgrade pip==9.0.3 `# latest version for Python 2.6` && \
    pip install --upgrade setuptools==36.8.0 `# latest version for Python 2.6` && \
    pip install supervisor==3.4.0 && \
    \
    # install commonly needed packages
    yum install -y \
        net-tools `# netstat` \
        sudo \
        telnet `# helpful when troubleshooting product tests` \
        vim `# helpful when troubleshooting product tests` \
        && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk.x86_64
