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

ARG JDK_URL
ARG JDK_PATH

# Install Oracle Java and presto-admin dependences (already has python 2.6)
RUN \
    set -xeu && \
    yum install -y wget && \
    # install and trim Oracle JDK
    wget -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O jdk.rpm && \
    rpm -ivh jdk.rpm && rm jdk.rpm && \
    rm -r $JDK_PATH/*src.zip \
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
    \
    # make java fixed (so further layers don't accidentally override it)
    update-alternatives --set java $JDK_PATH/jre/bin/java && \
    \
    # install supervisor
    yum install -y setuptools epel-release && \
    yum install -y python-pip && \
    pip install --upgrade pip==9.0.3 `# latest version for Python 2.6` && \
    pip install --upgrade setuptools==36.8.0 `# latest version for Python 2.6` && \
    pip install supervisor && \
    \
    # install commonly needed packages
    yum install -y \
        sudo \
        vim `# helpful when troubleshooting product tests` \
        && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME $JDK_PATH
