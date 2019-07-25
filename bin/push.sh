#!/usr/bin/env bash

set -xeuo pipefail

while [ "$#" -gt 0 ]; do
    while ! docker push "$1"; do
	    echo "Failed to push $1, retrying in 30s..."
	    sleep 30
    done
    shift
done
