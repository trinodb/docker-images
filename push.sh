#!/bin/sh

while [ -n "$1" ]; do 
	docker push "$1"
	shift
done
