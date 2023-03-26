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
FROM testing/centos7-oj17:unlabelled$ARCH

ARG ADDPRINC_ARGS="-maxrenewlife \"10 days\" +allow_renewable"

# INSTALL KERBEROS
RUN yum install -y krb5-libs krb5-server krb5-workstation \
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*

# COPY CONFIGURATION
COPY ./files /

# CREATE KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -s -P password

# CREATE ANOTHER KERBEROS DATABASE
RUN /usr/sbin/kdb5_util create -d /var/kerberos/krb5kdc/principal-other -r OTHER.STARBURSTDATA.COM -s -P password

# MAKE '.STARBURSTDATA.COM' TRUST 'OTHER.STARBURSTDATA.COM'
RUN /usr/sbin/kadmin.local -q "addprinc ${ADDPRINC_ARGS} -pw 123456 krbtgt/.STARBURSTDATA.COM@OTHER.STARBURSTDATA.COM"
RUN /usr/sbin/kadmin.local -r OTHER.STARBURSTDATA.COM -d /var/kerberos/krb5kdc/principal-other -q "addprinc ${ADDPRINC_ARGS} -pw 123456 krbtgt/STARBURSTDATA.COM"

# EXPOSE KERBEROS PORTS
EXPOSE	88
EXPOSE	89
EXPOSE	749

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
ENTRYPOINT  ["/opt/entrypoint.sh"]
