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

ARG ARCH
FROM testing/hive3.1:unlabelled$ARCH

# Install Kerberos client tooling only. KDC is provided by a separate container.
RUN yum install -y krb5-libs krb5-workstation libxslt \
  && yum -y clean all \
  && rm -rf /tmp/* /var/tmp/*

# Copy Kerberos-aware configuration and init templates
COPY ./files /

# Adapt copied templates for apache-hive/apache-hadoop layout used by hive3.1.
# Keep base XML values and merge Kerberos overrides to avoid dropping required defaults.
RUN set -euxo pipefail; \
  chmod +x /etc/hadoop-init.d/init-hdfs.sh; \
  getent group hadoop >/dev/null || groupadd -r hadoop; \
  for user in hdfs hive mapred yarn; do \
    id -u "$user" >/dev/null 2>&1 || useradd -r -g hadoop "$user"; \
  done; \
  install -D -m 0644 /etc/hive/conf/hiveserver2-site.xml /tmp/hiveserver2-site.xml; \
  rm -rf /etc/hadoop /etc/hive; \
  mkdir -p /etc/hadoop /etc/hive; \
  ln -s /opt/hadoop/etc/hadoop /etc/hadoop/conf; \
  ln -s /opt/hive/conf /etc/hive/conf; \
  /usr/local/bin/apply-all-site-xml-overrides /overrides; \
  rm -rf /overrides; \
  cp /tmp/hiveserver2-site.xml /opt/hive/conf/hiveserver2-site.xml; \
  rm -f /tmp/hiveserver2-site.xml
