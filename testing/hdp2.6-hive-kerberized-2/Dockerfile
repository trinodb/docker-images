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

FROM testing/hdp2.6-hive:unlabelled

# INSTALL KERBEROS
RUN yum install -y krb5-libs krb5-server krb5-workstation \
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

# COPY CONFIGURATION
COPY ./files /

# Apply configuration overrides
RUN /usr/local/bin/apply-all-site-xml-overrides /overrides

# CREATE KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -s -P password

# ADD HADOOP PRINCIPALS
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hdfs/hadoop-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey mapred/hadoop-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey yarn/hadoop-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/hadoop-2@OTHERREALM.COM"

# CREATE HADOOP KEYTAB FILES
RUN /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-2 HTTP/hadoop-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/mapred.keytab mapred/hadoop-2 HTTP/hadoop-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/yarn.keytab yarn/hadoop-2 HTTP/hadoop-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/HTTP.keytab HTTP/hadoop-2"
RUN chown hdfs:hadoop /etc/hadoop/conf/hdfs.keytab \
  && chown mapred:hadoop /etc/hadoop/conf/mapred.keytab \
  && chown yarn:hadoop /etc/hadoop/conf/yarn.keytab \
  && chown hdfs:hadoop /etc/hadoop/conf/HTTP.keytab \
  && chmod 644 /etc/hadoop/conf/*.keytab

# CREATE HIVE PRINCIPAL AND KEYTAB
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hive/hadoop-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hive/conf/hive.keytab hive/hadoop-2"
RUN chown hive:hadoop /etc/hive/conf/hive.keytab \
  && chmod 644 /etc/hive/conf/hive.keytab

# CREATE TRINO PRINCIPAL AND KEYTAB
RUN /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-coordinator.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker-1.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker-2.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/trino-coordinator.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-client/trino-coordinator.docker.cluster@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey hive/trino-coordinator.docker.cluster@OTHERREALM.COM" \
  && mkdir -p /etc/trino/conf \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-server.keytab trino-server/trino-coordinator.docker.cluster trino-server/trino-worker.docker.cluster trino-server/trino-worker-1.docker.cluster trino-server/trino-worker-2.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-server-HTTP.keytab HTTP/trino-coordinator.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-client.keytab trino-client/trino-coordinator.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/hive-trino-coordinator.keytab hive/trino-coordinator.docker.cluster"
RUN chmod 644 /etc/trino/conf/*.keytab

# CREATE SSL KEYSTORE
RUN keytool -genkeypair \
    -alias presto \
    -keyalg RSA \
    -keystore /etc/trino/conf/keystore.jks \
    -keypass password \
    -storepass password \
    -dname "OU=, O=, L=, S=, C=" \
    -validity 100000
RUN chmod 644 /etc/trino/conf/keystore.jks

# Provide convenience bash history
RUN set -xeu; \
    for user in root hive hdfs; do \
        sudo -u "${user}" bash -c ' echo "klist -kt /etc/hive/conf/hive.keytab" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "kinit -kt /etc/hive/conf/hive.keytab hive/hadoop-2@OTHERREALM.COM" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "beeline -u \"jdbc:hive2://hadoop-2:10000/default;principal=hive/hadoop-2@OTHERREALM.COM\"" >> ~/.bash_history '; \
    done

# EXPOSE KERBEROS PORTS
EXPOSE	88
EXPOSE	89
EXPOSE	749

CMD supervisord -c /etc/supervisord.conf
