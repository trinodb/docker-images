## OpenLdap Server

### Generate private key and certificate

```shell
openssl req -new -x509 -newkey rsa:4096 -sha256 -nodes -days 36500 \
    -subj '/CN=ldapserver/OU=TEST/O=TRINO/L=Chennai/S=TN/C=IN' \
    -addext "subjectAltName = DNS:ldapserver" \
    -keyout files/etc/openldap/certs/private.pem \
    -out files/etc/openldap/certs/openldap-certificate.pem 
```

## Trino coordinator

### Generate CSR for Trino coordinator

```shell
openssl req -newkey rsa:4096 -nodes -days 36500 \
    -subj '/CN=presto-master/OU=TEST/O=TRINO/L=Chennai,S=TN,C=IN' \
    -keyout files/etc/openldap/certs/trino-coordinator-for-ldap.key \
    -addext "subjectAltName = DNS:presto-master" \
    -out files/etc/openldap/certs/trino-coordinator-for-ldap.csr
```

### Sign CSR using openldap-certificate.pem

```shell
openssl x509 -req -days 36500 -in files/etc/openldap/certs/trino-coordinator-for-ldap.csr \
    -out files/etc/openldap/certs/trino-coordinator-for-ldap.crt \
    -CA files/etc/openldap/certs/openldap-certificate.pem \
    -CAkey files/etc/openldap/certs/private.pem \
    -CAserial files/etc/openldap/certs/serial.txt
```

### Bundle them to a PEM file

```shell
cat files/etc/openldap/certs/trino-coordinator-for-ldap.crt \
    files/etc/openldap/certs/trino-coordinator-for-ldap.key \
    > files/etc/openldap/certs/trino-coordinator-for-ldap.pem
```

### Remove unnecessary files
```shell
rm files/etc/openldap/certs/trino-coordinator-for-ldap.csr \
    files/etc/openldap/certs/trino-coordinator-for-ldap.key \
    files/etc/openldap/certs/trino-coordinator-for-ldap.crt
```