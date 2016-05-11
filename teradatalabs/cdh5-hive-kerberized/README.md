# cdh5-hive-kerberized

Docker image with HDFS, YARN and HIVE installed in a kerberized environment. Please note that running services have lower memory heap size set.
For more details please check [blob/master/images/cdh5-hive/files/conf/hadoop-env.sh](configuration) file.
If you want to work on larger datasets please tune those settings accordingly, the current settings should be optimal
for general correctness testing.

## Build

```
$ sudo docker build -t teradatalabs/cdh5-hive-kerberized .
$ sudo docker run --rm -it teradatalabs/cdh5-hive-kerberized /bin/bash
```

## Run

```
$ sudo docker run -d --name hadoop-master -h hadoop-master teradatalabs/cdh5-hive-kerberized
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
