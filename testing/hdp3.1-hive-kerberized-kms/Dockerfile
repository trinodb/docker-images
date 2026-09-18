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

FROM testing/hdp3.1-hive-kerberized:unlabelled
ARG ADDPRINC_ARGS="-maxrenewlife \"10 days\" +allow_renewable"

# Install KMS
ARG HADOOP_VERSION=3.1.4
ARG HADOOP_BINARY_SHA512=f7eff67e948e21e23d7069dc169c98fcce757f59473e1e9a0e27d69a23df88840a9776089eeae5a8e1e496753f811868fe65638b04e3388c197931cd44d86f63
ARG HADOOP_BINARY_PATH=https://github.com/trinodb/docker-images/releases/download/dependency-mirror/sha512-${HADOOP_BINARY_SHA512}-hadoop-$HADOOP_VERSION.tar.gz
RUN curl -fLsS -o /tmp/hadoop.tar.gz --url $HADOOP_BINARY_PATH && \
    echo "$HADOOP_BINARY_SHA512  /tmp/hadoop.tar.gz" | sha512sum -c - && \
    tar xzf /tmp/hadoop.tar.gz --directory /opt && mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

# COPY CONFIGURATION
COPY ./files /
COPY ./files/etc/hadoop-kms/conf /opt/hadoop/etc/hadoop/

# add users and group for testing purposes
RUN set -xeu && \
    for username in alice bob charlie; do \
        groupadd "${username}_group" && \
        useradd -g "${username}_group" "${username}" && \
        /usr/sbin/kadmin.local -q "addprinc ${ADDPRINC_ARGS} -randkey ${username}/hadoop-master@LABS.TERADATA.COM" && \
        /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hive/conf/${username}.keytab ${username}/hadoop-master"; \
    done && \
    echo OK

RUN /root/setup_kms.sh

CMD supervisord -c /etc/supervisord.conf
