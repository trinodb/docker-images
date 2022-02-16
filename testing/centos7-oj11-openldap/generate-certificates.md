## OpenLdap Server

### Generate private key and certificate

```shell
openssl req -new -x509 -newkey rsa:4096 -sha256 -nodes -days 36500 \
    -subj '/CN=ldapserver/OU=TEST/O=TRINO/L=Chennai/S=TN/C=IN' \
    -addext "subjectAltName = DNS:ldapserver" \
    -keyout files/etc/openldap/certs/private.pem \
    -out files/etc/openldap/certs/openldap-certificate.pem 
```
