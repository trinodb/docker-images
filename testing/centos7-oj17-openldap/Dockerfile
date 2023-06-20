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
FROM testing/centos7-oj17-openldap-base:unlabelled$ARCH

# CONFIGURE OPENLDAP SERVER
# Run supervisord in background
RUN supervisord -c /etc/supervisord.conf && \
    /usr/bin/wait-for-slapd.sh && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/modify_server.ldif && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/ldap_disable_bind_anon.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/memberof.ldif && \
    # Next two ldifs are required in order to have inetOrgPerson object class
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/refint.ldif && \
    ldapadd -f /etc/openldap/setup/createOU.ldif -D cn=admin,dc=trino,dc=testldap,dc=com -w admin

CMD supervisord -n -c /etc/supervisord.conf
