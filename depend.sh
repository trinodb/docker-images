#!/bin/sh

usage() {
	echo "$0 {target image} [known -images]" >&2
}

find_parent() {
	cat $1 | awk '
		BEGIN {
			ec = 1;
			FROM_PATTERN = "^[[:space:]]*FROM";
		}

		$0 ~ FROM_PATTERN && parent {
			ec = 2;
			exit;
		}

		$0 ~ FROM_PATTERN {
			split($0, a);
			parent = $2;
			ec = 0
			print parent;
		}

		END {
			exit ec
		}'
}

contains() {
	needle=$1
	shift
	echo "$@" | grep -q -E "\<$needle\>"
}

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

target_dockerfile=$1
target_image=$(dirname $target_dockerfile)
shift
known_images="$@"

parent_image=$(find_parent $target_dockerfile)
ec=$?
case $ec in
	0) ;;
	1)
		echo "Failed to find a parent docker image in $target_dockerfile" >&2
		exit $ec
		;;
	2)
		echo "Found multiple parent docker images in $target_dockerfile" >&2
		exit $ec
		;;
esac

if contains $parent_image $known_images; then
	echo $target_image: $parent_image
else
	echo $target_image:
fi
