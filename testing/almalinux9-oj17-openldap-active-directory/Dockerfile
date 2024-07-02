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
FROM testing/almalinux9-oj17-openldap-base:unlabelled$ARCH

# COPY CONFIGURATION
COPY ./files /

# CONFIGURE OPENLDAP SERVER
RUN supervisord -c /etc/supervisord.conf && \
    /usr/bin/wait-for-slapd.sh && \
    # active dictory schema from https://git.openldap.org/openldap/openldap/-/raw/master/servers/slapd/schema/msuser.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/msuser.ldif && \
    ldapadd -f /etc/openldap/setup/createOU.ldif -D cn=admin,dc=trino,dc=testldap,dc=com -w admin

CMD supervisord -n -c /etc/supervisord.conf
