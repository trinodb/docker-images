FROM teradatalabs/centos6-java8-oracle
MAINTAINER Sanjay Sharma <sanjay.sharma@teradata.com>

ENV LDAP_PATH=/etc/ldap JAVA_HOME=/usr/java/jdk1.8.0_92

# Import the Active Directory certificate into presto-coordinator
COPY files $LDAP_PATH/files
RUN keytool -import -alias presto -storepass changeit -keystore $JAVA_HOME/jre/lib/security/cacerts \
    -noprompt -trustcacerts -file $LDAP_PATH/files/active-directory-certificate.crt && \
    rm -rf $LDAP_PATH/files/active-directory-certificate.crt

# Generate a keystore.
RUN keytool -genkey -alias coordinator -storepass testldap -keystore $LDAP_PATH/coordinator.jks \
    -keypass testldap -keyalg RSA -sigalg SHA1withRSA -dname "CN=presto-master, OU=, O=, L=, S=, C="
# Generate a certificate and CSR for the keystore. CN should match the hostname of presto-coordinator
RUN keytool -export -alias coordinator -storepass testldap -keystore $LDAP_PATH/coordinator.jks \
    -file $LDAP_PATH/coordinator.cer && \
    keytool -certreq -alias coordinator -storepass testldap -keystore $LDAP_PATH/coordinator.jks \
    -file $LDAP_PATH/coordinator.csr

# create a test CA and generate caroot.cer( root certificate of the CA ).
RUN openssl req -new -keyout $LDAP_PATH/cakey.pem -out $LDAP_PATH/careq.pem -nodes \
    -subj "/C=US/ST=Massachusetts/L=Boston/O=Teradata/OU=Finance/CN=teradata" && \
    openssl x509 -req -in $LDAP_PATH/careq.pem -out $LDAP_PATH/caroot.cer -days 3650 \
    -signkey $LDAP_PATH/cakey.pem

# sign the server certificate using the testCA
RUN openssl x509 -req -in $LDAP_PATH/coordinator.csr -out $LDAP_PATH/TestCA.cer -days 365 \
    -CA $LDAP_PATH/caroot.cer -CAkey $LDAP_PATH/cakey.pem -CAserial $LDAP_PATH/files/serial.txt

# Import the caroot.cer to the keystore and replace the previously generated self-signed cert with the new CA signed one in the keystore
# Note: The -alias name (coordinator) should be the same as the alias used when coordinator.cer was generated
RUN keytool -import -alias TestCA -storepass testldap -keystore $LDAP_PATH/coordinator.jks \
    -noprompt -file $LDAP_PATH/caroot.cer && \
    keytool -import -alias coordinator -storepass testldap -keystore $LDAP_PATH/coordinator.jks \
    -file $LDAP_PATH/TestCA.cer

# Import the root certificate of the issuer of the presto-coordinator certificate.
# This would be used by clients ( cli, jdbc ) to run tests
RUN keytool -import -alias caroot -storepass testldap -keystore $LDAP_PATH/cacerts.jks -noprompt \
    -file $LDAP_PATH/caroot.cer