#!/usr/bin/env bash

set -xeuo pipefail

usage() {
	echo "$0 {image} [args]" >&2
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

image=$1
shift

if [ -z "${PLATFORMS:-}" ]; then
    docker buildx build \
        --compress \
        --progress=plain \
        --add-host hadoop-master:127.0.0.2 \
        -t "$image" \
        --load \
        "$@" \
        .
    exit 0
fi

IFS=, read -ra platforms <<<"$PLATFORMS"
export ARCH
for platform in "${platforms[@]}"; do
    IFS=: read -r name tag <<<"$image"
    ARCH="-${platform//\//-}"
    docker buildx build \
        --platform "$platform" \
        --compress \
        --progress=plain \
        --add-host hadoop-master:127.0.0.2 \
        -t "${name}:${tag}${ARCH}" \
        --load \
        "$@" \
        .
done
