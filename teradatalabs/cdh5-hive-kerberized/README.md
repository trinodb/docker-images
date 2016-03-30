# cdh5-base

Docker image with HDFS, YARN and HIVE installed. Please note that running services have lower memory heap size set.
For more details please check [blob/master/images/cdh5-hive/files/conf/hadoop-env.sh](configuration) file.
If you want to work on larger datasets please tune those settings accordingly, the current settings should be optimal
for general correctness testing.

## Build

```
$ sudo docker build -t teradata-labs/cdh5-hive .
$ sudo docker run --rm -it teradata-labs/cdh5-hive /bin/bash
```

## Run

```
$ sudo docker run -d --name hadoop-master -h hadoop-master teradata-labs/cdh5-hive
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
