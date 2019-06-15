#!/usr/bin/env bash

set -xeuo pipefail

while [ "$#" -gt 0 ]; do
	docker push "$1"
	shift
done
