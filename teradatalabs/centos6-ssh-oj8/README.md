# centos6-ssh-oj8

Docker image of CentOS 6 with Oracle JDK 8 installed, and with sshd
running.  Passwordless ssh for the user app-admin is also set up.

## Build

```
$ sudo docker build -t teradatalabs/centos6-ssh-oj8 .
$ sudo docker run --rm -it teradatalabs/centos6-ssh-oj8 /bin/bash
[root@17e6caf87452 /]# java -version
java version "1.8.0_92"
Java(TM) SE Runtime Environment (build 1.8.0_92-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.40-b25, mixed mode)
```

## Further documentation
For more documentation on this image, see the documentation for the
base centos6-ssh image it uses:
https://registry.hub.docker.com/u/jdeathe/centos-ssh/

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
