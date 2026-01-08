#!/usr/bin/env bash

set -xeuo pipefail

function expand_multiarch_tags() {
    local platforms
    local name
    local tag=$1
    shift

    # Single platform (native runners in CI)
    if [ -n "${PLATFORM:-}" ]; then
        IFS=: read -r name tag <<<"$tag"
        echo "${name}:${tag}-${PLATFORM//\//-}"
        return
    fi

    # No platform specified
    if [ -z "${PLATFORMS:-}" ]; then
        echo "$tag"
        return
    fi

    # Multiple platforms (release workflow)
    IFS=, read -ra platforms <<<"$PLATFORMS"
    IFS=: read -r name tag <<<"$tag"

    for platform in "${platforms[@]}"; do
        echo "${name}:${tag}-${platform//\//-}"
    done
}
