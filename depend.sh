#!/bin/sh

usage() {
	echo "$0 [-x] {target image} [known images]" >&2
}

find_parent() {
	awk '
		BEGIN {
			ec = 1;
		}

		$1 == "FROM" && parent {
			ec = 2;
			exit;
		}

		$1 == "FROM" {
			split($0, a);
			parent = $2;
			ec = 0
			print parent;
		}

		END {
			exit ec
		}' "$1"
}

contains() {
	needle=$1
	shift
	echo "$@" | grep -q -E "\<$needle\>"
}

list_external=false

while getopts ":x" c; do
	case $c in
		x)
			list_external=true
			;;
		\?)
			echo "Unrecognized option -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			exit 1
			;;
	esac
done

shift "`dc -e"$OPTIND 1 - p"`"

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

target_dockerfile=$1
target_image=$(dirname "$target_dockerfile")
shift
known_images="$*"

parent_image=$(find_parent "$target_dockerfile")
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

if contains "$parent_image" "$known_images"; then
	# The parent image is built from the repository
	if ! "$list_external"; then
		echo "$target_image: $parent_image"
		echo "PHONY: $target_image.dependants $parent_image.dependants"
		echo "$target_image.dependants: $target_image"
		echo "$parent_image.dependants: $target_image.dependants"
	fi
else
	#
	# You cannot use a colon (:) in a target or prerequisite name in a
	# Makefile. Change colons to @-signs, which docker does not allow as part
	# of an name or tag. The Makefile will have to translate them back before
	# invoking `docker pull' to fetch the base images.
	#
	make_friendly_parent=`echo "$parent_image" | sed 's/:/@/g'`

	# The parent image is pulled from a repository
	if ! "$list_external"; then
		echo "$target_image: $make_friendly_parent"
	else
		echo "$make_friendly_parent"
	fi
fi
