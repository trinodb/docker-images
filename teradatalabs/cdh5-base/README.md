# cdh5-base [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
            
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/cdh5-base.svg
[layers-link]: https://microbadger.com/images/teradatalabs/cdh5-base
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/cdh5-base.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/cdh5-base

Docker image with cloudera repositories installed. It is based on _teradatalabs/centos6-java8-oracle_ image.

## Build

```
$ sudo docker build -t teradatalabs/cdh5-base .
$ sudo docker run --rm -it teradatalabs/cdh5-base /bin/bash
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
