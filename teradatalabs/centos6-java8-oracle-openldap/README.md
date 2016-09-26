# centos6-java8-oracle-ldap [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/centos6-java8-oracle-openldap.svg
[layers-link]: https://microbadger.com/images/teradatalabs/centos6-java8-oracle-openldap
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/centos6-java8-oracle-openldap.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/centos6-java8-oracle-openldap

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
