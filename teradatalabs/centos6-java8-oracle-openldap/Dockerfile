FROM teradatalabs/centos6-java8-oracle
MAINTAINER Sanjay Sharma <sanjay.sharma@teradata.com>

RUN yum -y install openldap openldap-clients openldap-servers
COPY files /tmp/files
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
