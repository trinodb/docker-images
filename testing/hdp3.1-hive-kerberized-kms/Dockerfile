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
ARG HADOOP_BINARY_PATH=https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN curl -fLsS -o /tmp/hadoop.tar.gz --url $HADOOP_BINARY_PATH && \
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
