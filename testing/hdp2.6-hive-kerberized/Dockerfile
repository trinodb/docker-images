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

# CREATE ANOTHER KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -d /var/kerberos/krb5kdc/principal-other -r OTHERLABS.TERADATA.COM -s -P password

# ADD HADOOP PRINCIPALS
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hdfs/hadoop-master@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey mapred/hadoop-master@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey yarn/hadoop-master@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/hadoop-master@LABS.TERADATA.COM"

# CREATE HADOOP KEYTAB FILES
RUN /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master HTTP/hadoop-master" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/mapred.keytab mapred/hadoop-master HTTP/hadoop-master" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/yarn.keytab yarn/hadoop-master HTTP/hadoop-master" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/HTTP.keytab HTTP/hadoop-master"
RUN chown hdfs:hadoop /etc/hadoop/conf/hdfs.keytab \
  && chown mapred:hadoop /etc/hadoop/conf/mapred.keytab \
  && chown yarn:hadoop /etc/hadoop/conf/yarn.keytab \
  && chown hdfs:hadoop /etc/hadoop/conf/HTTP.keytab \
  && chmod 644 /etc/hadoop/conf/*.keytab

# CREATE HIVE PRINCIPAL AND KEYTAB
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hive/hadoop-master@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hive/conf/hive.keytab hive/hadoop-master"
RUN chown hive:hadoop /etc/hive/conf/hive.keytab \
  && chmod 644 /etc/hive/conf/hive.keytab

# CREATE HIVE PRINCIPAL IN THE OTHER REALM
RUN /usr/sbin/kadmin.local -r OTHERLABS.TERADATA.COM -d /var/kerberos/krb5kdc/principal-other -q "addprinc -randkey hive/hadoop-master@OTHERLABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -r OTHERLABS.TERADATA.COM -d /var/kerberos/krb5kdc/principal-other -q "xst -norandkey -k /etc/hive/conf/hive-other.keytab hive/hadoop-master"
RUN chown hive:hadoop /etc/hive/conf/hive-other.keytab \
  && chmod 644 /etc/hive/conf/hive-other.keytab

# CREATE HDFS PRINCIPAL IN OTHER REALM
RUN /usr/sbin/kadmin.local -r OTHERLABS.TERADATA.COM -d /var/kerberos/krb5kdc/principal-other -q "addprinc -randkey hdfs/hadoop-master@OTHERLABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -r OTHERLABS.TERADATA.COM -d /var/kerberos/krb5kdc/principal-other -q "xst -norandkey -k /etc/hadoop/conf/hdfs-other.keytab hdfs/hadoop-master"
RUN chown hdfs:hadoop /etc/hadoop/conf/hdfs-other.keytab \
  && chmod 644 /etc/hadoop/conf/hdfs-other.keytab

# MAKE 'LABS.TERADATA.COM' TRUST 'OTHERLABS.TERADATA.COM'
RUN /usr/sbin/kadmin.local -q "addprinc -pw 123456 krbtgt/LABS.TERADATA.COM@OTHERLABS.TERADATA.COM"
RUN /usr/sbin/kadmin.local -r OTHERLABS.TERADATA.COM -d /var/kerberos/krb5kdc/principal-other -q "addprinc -pw 123456 krbtgt/LABS.TERADATA.COM"

# CREATE TRINO PRINCIPAL AND KEYTAB
RUN /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-coordinator.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker-1.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/trino-worker-2.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/trino-coordinator.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey trino-client/trino-coordinator.docker.cluster@LABS.TERADATA.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey hive/trino-coordinator.docker.cluster@LABS.TERADATA.COM" \
  && mkdir -p /etc/trino/conf \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-server.keytab trino-server/trino-coordinator.docker.cluster trino-server/trino-worker.docker.cluster trino-server/trino-worker-1.docker.cluster trino-server/trino-worker-2.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-server-HTTP.keytab HTTP/trino-coordinator.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-client.keytab trino-client/trino-coordinator.docker.cluster" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/hive-trino-coordinator.keytab hive/trino-coordinator.docker.cluster"
RUN chmod 644 /etc/trino/conf/*.keytab

# CREATE SSL KEYSTORE
RUN keytool -genkeypair \
    -alias trino \
    -keyalg RSA \
    -keystore /etc/trino/conf/keystore.jks \
    -keypass password \
    -storepass password \
    -dname "CN=trino-coordinator, OU=, O=, L=, S=, C=" \
    -validity 100000
RUN chmod 644 /etc/trino/conf/keystore.jks

# Provide convenience bash history
RUN set -xeu; \
    for user in root hive hdfs; do \
        sudo -u "${user}" bash -c ' echo "klist -kt /etc/hive/conf/hive.keytab" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "kinit -kt /etc/hive/conf/hive.keytab hive/hadoop-master@LABS.TERADATA.COM" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "beeline -u \"jdbc:hive2://hadoop-master:10000/default;principal=hive/hadoop-master@LABS.TERADATA.COM\"" >> ~/.bash_history '; \
    done

# EXPOSE KERBEROS PORTS
EXPOSE	88
EXPOSE	89
EXPOSE	749

CMD supervisord -c /etc/supervisord.conf
