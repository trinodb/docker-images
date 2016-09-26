# cdh5-hive-odbc [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/cdh5-hive-odbc.svg
[layers-link]: https://microbadger.com/images/teradatalabs/cdh5-hive-odbc
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/cdh5-hive-odbc.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/cdh5-hive-odbc

This image is based of cdh5-hive and has HDFS, YARN and HIVE installed. The
image has unixODBC driver manager installed.

## Build

```
$ sudo docker build -t teradatalabs/cdh5-hive-odbc .
$ sudo docker run --rm -it teradatalabs/cdh5-hive-odbc /bin/bash
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
