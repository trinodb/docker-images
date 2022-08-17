#!/usr/bin/env bash

set -xeuo pipefail

usage() {
	echo "$0 {src} {dst}" >&2
}

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/lib.sh
source "$SCRIPT_DIR/lib.sh"

mapfile -t src_tags < <(expand_multiarch_tags "$1")
mapfile -t dst_tags < <(expand_multiarch_tags "$2")

for i in "${!src_tags[@]}"; do
    src=${src_tags[$i]}
    dst=${dst_tags[$i]}
    docker tag "$src" "$dst"
done
