#!/usr/bin/env bash

set -xeuo pipefail

function push_retry() {
    local image=$1

    while ! docker push "$image"; do
        echo "Failed to push $image, retrying in 30s..."
        sleep 30
    done
}

if [ -z "${PLATFORMS:-}" ]; then
    for image in "$@"; do
        push_retry "$image"
    done
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/lib.sh
source "$SCRIPT_DIR/lib.sh"

for image in "$@"; do
    mapfile -t expanded_names < <(expand_multiarch_tags "$image")
    for name in "${expanded_names[@]}"; do
        push_retry "$name"
    done
    docker manifest create "$image" "${expanded_names[@]}"
    docker manifest push "$image"
done
