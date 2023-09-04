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

FROM testing/hdp3.1-hive:unlabelled

# INSTALL KERBEROS
RUN yum install -y krb5-libs krb5-server krb5-workstation \
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

# COPY CONFIGURATION
COPY ./files /

# Apply configuration overrides and remove them so they don't get reapplied
RUN /usr/local/bin/apply-all-site-xml-overrides /overrides && rm -Rf /overrides

# CREATE KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -s -P password

# ADD HADOOP PRINCIPALS
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hdfs/hadoop-master-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey mapred/hadoop-master-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey yarn/hadoop-master-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/hadoop-master-2@OTHERREALM.COM"

# CREATE HADOOP KEYTAB FILES
RUN /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/hdfs.keytab hdfs/hadoop-master-2 HTTP/hadoop-master-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/mapred.keytab mapred/hadoop-master-2 HTTP/hadoop-master-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/yarn.keytab yarn/hadoop-master-2 HTTP/hadoop-master-2" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hadoop/conf/HTTP.keytab HTTP/hadoop-master-2"
RUN chown hdfs:hadoop /etc/hadoop/conf/hdfs.keytab \
  && chown mapred:hadoop /etc/hadoop/conf/mapred.keytab \
  && chown yarn:hadoop /etc/hadoop/conf/yarn.keytab \
  && chown hdfs:hadoop /etc/hadoop/conf/HTTP.keytab \
  && chmod 644 /etc/hadoop/conf/*.keytab

# CREATE HIVE PRINCIPAL AND KEYTAB
RUN /usr/sbin/kadmin.local -q "addprinc -randkey hive/hadoop-master-2@OTHERREALM.COM" \
  && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hive/conf/hive.keytab hive/hadoop-master-2"
RUN chown hive:hadoop /etc/hive/conf/hive.keytab \
  && chmod 644 /etc/hive/conf/hive.keytab

# Create legacy Presto and updated Trino principals and add them to keytabs
RUN set -xeu && \
  for hostname in presto-master trino-coordinator presto-worker trino-worker presto-worker-1 trino-worker-1 presto-worker-2 trino-worker-2; do \
      /usr/sbin/kadmin.local -q "addprinc -randkey presto-server/${hostname}.docker.cluster@OTHERREALM.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/${hostname}.docker.cluster@OTHERREALM.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/${hostname}.docker.cluster@OTHERREALM.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey presto-client/${hostname}.docker.cluster@OTHERREALM.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey trino-client/${hostname}.docker.cluster@OTHERREALM.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey hive/${hostname}.docker.cluster@OTHERREALM.COM" \
      && mkdir -p /etc/trino/conf \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/presto-server.keytab presto-server/${hostname}.docker.cluster" \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-server.keytab trino-server/${hostname}.docker.cluster" \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/presto-server-HTTP.keytab HTTP/${hostname}.docker.cluster" \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/trino-client.keytab trino-client/${hostname}.docker.cluster" \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/presto-client.keytab presto-client/${hostname}.docker.cluster" \
      && /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/trino/conf/hive-presto-master.keytab hive/${hostname}.docker.cluster"; \
  done && echo "OK" && \
  chmod 644 /etc/trino/conf/*.keytab

# CREATE SSL KEYSTORE
RUN keytool -genkeypair \
    -alias presto \
    -keyalg RSA \
    -keystore /etc/trino/conf/keystore.jks \
    -keypass password \
    -storepass password \
    -dname "CN=presto-master, OU=, O=, L=, S=, C=" \
    -validity 100000 && \
    keytool -genkeypair \
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
        sudo -u "${user}" bash -c ' echo "kinit -kt /etc/hive/conf/hive.keytab hive/hadoop-master-2@OTHERREALM.COM" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "beeline -u \"jdbc:hive2://hadoop-master-2:10000/default;principal=hive/hadoop-master-2@OTHERREALM.COM\"" >> ~/.bash_history '; \
    done

# EXPOSE KERBEROS PORTS
EXPOSE	88
EXPOSE	89
EXPOSE	749

CMD supervisord -c /etc/supervisord.conf
