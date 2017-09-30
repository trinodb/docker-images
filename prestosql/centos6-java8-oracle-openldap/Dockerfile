# Copyright 2016 Teradata
#
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

FROM teradatalabs/centos6-java8-oracle:unlabelled
MAINTAINER Teradata Docker Team <docker@teradata.com>

RUN yum -y install openldap openldap-clients openldap-servers
COPY files /tmp/files
RUN cp -r /tmp/files/openldap-certificate.pem /etc/openldap/
RUN cp -r /tmp/files/certs/* /etc/openldap/certs/
RUN chmod a+x /tmp/files/start_slapd.sh
RUN service slapd restart && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/files/setup/modify_server.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/files/overlay/memberof.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/files/overlay/refint.ldif && \
    ldapadd -f /tmp/files/setup/createOU.ldif -D cn=admin,dc=presto,dc=testldap,dc=com -w admin && \
    sed -i 's/SLAPD_LDAPS=no/SLAPD_LDAPS=yes/g' /etc/sysconfig/ldap && \
    service slapd restart
CMD /tmp/files/start_slapd.sh
