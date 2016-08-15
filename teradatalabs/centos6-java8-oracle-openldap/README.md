# centos6-java8-oracle-ldap

Docker image of CentOS 6 with Oracle JDK 8 installed. This will act
as the base image for presto when running product-tests with front-end
LDAP authentication.

## Build

```
$ sudo docker build -t teradatalabs/centos6-java8-oracle-openldap .
$ sudo docker run --rm -it teradatalabs/centos6-java8-oracle-openldap /bin/bash
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
