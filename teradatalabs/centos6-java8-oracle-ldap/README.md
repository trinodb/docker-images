# centos6-java8-oracle-ldap [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/centos6-java8-oracle-ldap.svg
[layers-link]: https://microbadger.com/images/teradatalabs/centos6-java8-oracle-ldap
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/centos6-java8-oracle-ldap.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/centos6-java8-oracle-ldap

Docker image of CentOS 6 with Oracle JDK 8 installed. This will act
as the base image for presto when running product-tests with front-end
LDAP authentication.

## Build

```
$ sudo docker build -t teradatalabs/centos6-java8-oracle-ldap .
$ sudo docker run --rm -it teradatalabs/centos6-java8-oracle-ldap /bin/bash
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
