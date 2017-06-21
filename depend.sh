#!/bin/sh

usage() {
	echo "$0 {-d|-x} {target image} [known images]" >&2
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

#
# You cannot use a colon (:) in a target or prerequisite name in a
# Makefile. Change colons to @-signs, which docker does not allow as part
# of an name or tag. The Makefile will have to translate them back before
# invoking `docker pull' to fetch the base images.
#
make_friendly_name() {
	echo "$1" | sed 's/:/@/g'
}

noop() {
	:
}

depfiles_own_image() {
	local target_image=$1
	local parent_image=$2

	echo "$target_image: $parent_image"
	echo "PHONY: $target_image.dependants $parent_image.dependants"
	echo "$target_image.dependants: $target_image"
	echo "$parent_image.dependants: $target_image.dependants"
}

depfiles_ext_image() {
	local target_image="$1"
	local make_friendly_parent=$(make_friendly_name "$2")

	echo "$target_image: $make_friendly_parent"
}

list_ext_image() {
	local make_friendly_parent=$(make_friendly_name "$2")
	echo "$make_friendly_parent"
}

while getopts ":dx" c; do
	case $c in
		d)
			own_image_function=depfiles_own_image
			ext_image_function=depfiles_ext_image
			;;
		x)
			own_image_function=noop
			ext_image_function=list_ext_image
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

if [ -z "$own_image_function" -o $# -lt 2 ]; then
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
	$own_image_function "$target_image" "$parent_image"
else
	$ext_image_function "$target_image" "$parent_image"
fi
