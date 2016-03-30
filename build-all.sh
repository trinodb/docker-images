#!/bin/bash -eux

IMAGES=("teradatalabs/centos6-ssh-oj8" \
	"teradatalabs/hdp2.3-repo" \
	"teradatalabs/hdp2.3-base" \
	"teradatalabs/hdp2.3-master" \
	"teradatalabs/hdp2.3-slave" \
	"teradatalabs/centos6-java8-oracle" \
	"teradatalabs/cdh5-base" \
	"teradatalabs/cdh5-hive" \
	"teradatalabs/cdh5-hive-kerberized")

for image in "${IMAGES[@]}"; do
	echo $image
	cd $image
	docker build -t "$image" .
	cd -
done
