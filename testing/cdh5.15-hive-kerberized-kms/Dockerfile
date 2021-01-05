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

FROM testing/cdh5.15-hive-kerberized:unlabelled

RUN set -xeu \
    && yum install -y \
        hadoop-kms \
    # Cleanup
    && yum -y clean all && rm -rf /tmp/* /var/tmp/*

# COPY CONFIGURATION
COPY ./files /

# add users and group for testing purposes
RUN set -xeu && \
    for username in alice bob charlie; do \
        groupadd "${username}_group" && \
        useradd -g "${username}_group" "${username}" && \
        /usr/sbin/kadmin.local -q "addprinc -randkey ${username}/hadoop-master@LABS.TERADATA.COM" && \
        /usr/sbin/kadmin.local -q "xst -norandkey -k /etc/hive/conf/${username}.keytab ${username}/hadoop-master"; \
    done && \
    echo OK

RUN set -x && \
    install --directory --owner=kms --group=kms /var/run/hadoop-kms && \
    # $JAVA_HOME/jre/lib/security/java.security is used by default and in our Java it prevents KMS code from accessing its own keystore
    sed -e 's@-Dcatalina.base="$CATALINA_BASE"@\0 -Djceks.key.serialFilter="**"@' -i /usr/lib/bigtop-tomcat/bin/catalina.sh && \
    /root/setup_kms.sh && \
    # Purge Kerberos credential cache of root user
    kdestroy && \
    echo OK

RUN set -x && \
    find /var/log -type f -name \*.log -printf "truncate %p\n" -exec truncate --size 0 {} \; && \
    # Purge /tmp, this includes credential caches of other users
    find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + && \
    echo OK

CMD supervisord -c /etc/supervisord.conf
