#!/usr/bin/env bash

usage() {
    echo "$0 {-d|-g|-p {tag}|-x} {target image Dockerfile} [known image tags]" >&2
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

		$1 == "FROM" && $3 != "AS" {
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

untag() {
    echo "${1%:*}"
}

noop() {
    :
}

depfiles_own_image() {
    local target_image=$1
    local make_friendly_parent=$(make_friendly_name "$2")
    local untagged_parent=$(untag "$2")

    echo "$target_image@latest: $make_friendly_parent"
    echo ".PHONY: $target_image.dependants $untagged_parent.dependants"
    echo "$untagged_parent.dependants: $target_image"
    echo "$untagged_parent.dependants: $target_image.dependants"
}

depfiles_ext_image() {
    local target_image="$1"
    local make_friendly_parent=$(make_friendly_name "$2")

    echo "$target_image@latest: $make_friendly_parent"
}

list_ext_image() {
    local make_friendly_parent=$(make_friendly_name "$2")
    echo "$make_friendly_parent"
}

graph_own_image() {
    local untagged_parent=$(untag "$2")
    cat <<-EOF
	"$1" [shape=box]
	"$untagged_parent" [shape=box]
	"$1" -> "$untagged_parent"

EOF
}

graph_ext_image() {
    cat <<-EOF
	"$1" [shape=box]
	"$2" [shape=house; style=filled; fillcolor="#a0a0a0"]
	"$1" -> "$2"
EOF
}

require_parent_tag() {
    local target_image=$1
    local parent_image=$2

    if ! echo "$parent_image" | grep ":${required_parent_tag}\$"; then
        echo "FROM in Dockerfile for $target_image must specify a parent with the tag '$required_parent_tag'" >&2
        exit 1
    fi
}

while getopts ":dgp:x" c; do
    case $c in
        d)
            own_image_function=depfiles_own_image
            ext_image_function=depfiles_ext_image
            ;;
        x)
            own_image_function=noop
            ext_image_function=list_ext_image
            ;;
        g)
            own_image_function=graph_own_image
            ext_image_function=graph_ext_image
            ;;
        p)
            own_image_function=require_parent_tag
            required_parent_tag=$OPTARG
            ext_image_function=noop
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

shift $((OPTIND - 1))

if [ -z "$own_image_function" ] || [ $# -lt 2 ]; then
    usage
    exit 1
fi

target_dockerfile=$1
target_image=$(dirname "$target_dockerfile")
shift
known_images="$*"

parent_image_tag=$(find_parent "$target_dockerfile")
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

if contains "$parent_image_tag" "$known_images"; then
    $own_image_function "$target_image" "$parent_image_tag"
else
    $ext_image_function "$target_image" "$parent_image_tag"
fi
