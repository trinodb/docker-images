# cdh5-hive-master [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/cdh5-hive-master.svg
[layers-link]: https://microbadger.com/images/teradatalabs/cdh5-hive-master
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/cdh5-hive-master.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/cdh5-hive-master

Docker image for master node with CDH5 hadoop distribution. Please note that running services have lower memory heap size set.
For more details please check [blob/master/images/cdh5-hive/files/conf/hadoop-env.sh](configuration) file.
If you want to work on larger datasets please tune those settings accordingly, the current settings should be optimal
for general correctness testing.

Image is to be used together with one ore more containers running `cdh5-hive-slave` image.

## Build

```
docker build -t teradatalabs/cdh5-hive-master .
docker run --rm -it teradatalabs/cdh5-hive-master /bin/bash
```

## Run

### Directly

```
docker run -d --name hadoop-master -h hadoop-master teradatalabs/cdh5-hive-master
```

### Using docker-compose

Following example shows how to build 4 node hadoop cluster using docker-compose

```yaml
version: '2'
services:
  hadoop-master:
    hostname: hadoop-master
    image: 'teradatalabs/cdh5-hive-master'
    ports:
      - '8020:8020'
      - '8088:8088'
      - '9083:9083'
      - '10000:10000'
      - '50070:50070'
      - '50075:50075'

  hadoop-slave1:
    hostname: 'hadoop-slave1'
    image: 'teradatalabs/cdh5-hive-slave'

  hadoop-slave2:
    hostname: 'hadoop-slave2'
    image: 'teradatalabs/cdh5-hive-slave'

  hadoop-slave3:
    hostname: 'hadoop-slave3'
    image: 'teradatalabs/cdh5-hive-slave'
```

## Oracle license

By using this container, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
