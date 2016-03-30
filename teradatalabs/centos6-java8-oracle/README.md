# centos6-java8-oracle

Docker image of CentOS 6 with Oracle JDK 8 installed.

## Build 
Execute the following from the images/centos6-java8-oracle directory

```
$ sudo docker build -t teradatalabs/centos6-java8-oracle .
$ sudo docker run --rm -it teradatalabs/centos6-java8-oracle /bin/bash
[root@17e6caf87452 /]# java -version
java version "1.8.0_40"
Java(TM) SE Runtime Environment (build 1.8.0_40-b26)
Java HotSpot(TM) 64-Bit Server VM (build 25.40-b25, mixed mode)
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
