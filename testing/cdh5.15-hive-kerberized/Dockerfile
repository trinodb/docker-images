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

FROM testing/cdh5.15-hive:unlabelled

# INSTALL KERBEROS
RUN yum install -y krb5-libs krb5-server krb5-workstation

# COPY CONFIGURATION
COPY ./files /

# Apply configuration overrides and remove them so they don't get reapplied
RUN /usr/local/bin/apply-all-site-xml-overrides /overrides && rm -Rf /overrides

# CREATE KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -s -P password

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

# YARN SECURITY SETTINGS
RUN chmod 6050 /etc/hadoop/conf/container-executor.cfg

# Create legacy Presto and updated Trino principals and add them to keytabs
RUN set -xeu && \
  for hostname in presto-master trino-coordinator presto-worker trino-worker presto-worker-1 trino-worker-1 presto-worker-2 trino-worker-2; do \
      /usr/sbin/kadmin.local -q "addprinc -randkey presto-server/${hostname}.docker.cluster@LABS.TERADATA.COM" \
      /usr/sbin/kadmin.local -q "addprinc -randkey trino-server/${hostname}.docker.cluster@LABS.TERADATA.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey HTTP/${hostname}.docker.cluster@LABS.TERADATA.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey presto-client/${hostname}.docker.cluster@LABS.TERADATA.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey trino-client/${hostname}.docker.cluster@LABS.TERADATA.COM" \
      && /usr/sbin/kadmin.local -q "addprinc -randkey hive/${hostname}.docker.cluster@LABS.TERADATA.COM" \
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

# EXPOSE KERBEROS PORTS
EXPOSE	88
EXPOSE	749

CMD supervisord -c /etc/supervisord.conf
