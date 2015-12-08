#!/bin/bash -eux

IMAGES=("teradatalabs/centos6-ssh-oj8" \
	"teradatalabs/hdp2.3-repo" \
	"teradatalabs/hdp2.3-base" \
	"teradatalabs/hdp2.3-master" \
	"teradatalabs/hdp2.3-slave")

for image in "${IMAGES[@]}"; do
	echo $image
	cd $image
	docker build -t "$image" .
	cd -
done
