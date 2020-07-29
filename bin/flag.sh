#!/bin/sh

usage() {
	echo "$0 {target image}" >&2
}

find_args() {
	local target_image=$(dirname "$target_dockerfile")
	awk -v image="$target_image" '
		BEGIN {
			ARG_PATTERN = "^\\s*ARG";
			print "DBFLAGS_" image " :=";
		}

		$1 == "ARG" {
			n = split($2, arr, "=")
			if (n >= 2) {
				# the argument has a default value in the Dockerfile; parse out the argument name
				key = arr[1];
			} else {
				key = $2;
			}
			print "DBFLAGS_" image " += --build-arg " key;
		}' "$1"
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

target_dockerfile=$1

find_args "$target_dockerfile"
