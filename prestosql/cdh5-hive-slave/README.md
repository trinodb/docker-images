# cdh5-hive-slave [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/cdh5-hive-slave.svg
[layers-link]: https://microbadger.com/images/teradatalabs/cdh5-hive-slave
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/cdh5-hive-slave.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/cdh5-hive-slave

Docker image for slave node with CDH5 hadoop distribution. Please note that running services have lower memory heap size set.
For more details please check [blob/master/images/cdh5-hive/files/conf/hadoop-env.sh](configuration) file.
If you want to work on larger datasets please tune those settings accordingly, the current settings should be optimal
for general correctness testing.

Image is to be used together with one ore more containers running `cdh5-hive-master` image.

## Run

### Directly

```
docker run -d --name hadoop-slave -h hadoop-slave teradatalabs/cdh5-hive-slave
```

### Using docker-compose

See [example for cdh5-hive-master](../cdh5-hive-master/README.md#using-docker-compose).

## Oracle license

By using this image, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
