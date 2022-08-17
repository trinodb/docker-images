#!/usr/bin/env bash

set -xeuo pipefail

function expand_multiarch_tags() {
    local platforms
    local name
    local tag=$1
    shift

    if [ -z "${PLATFORMS:-}" ]; then
        echo "$tag"
        return
    fi

    IFS=, read -ra platforms <<<"$PLATFORMS"
    IFS=: read -r name tag <<<"$tag"

    for platform in "${platforms[@]}"; do
        echo "${name}:${tag}-${platform//\//-}"
    done
}
