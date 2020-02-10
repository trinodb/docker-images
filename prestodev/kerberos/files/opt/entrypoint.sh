#!/bin/bash

set -exuo pipefail

"$@" &

if [[ -v PRESTODEV_POST_BOOTSTRAP_COMMAND ]]; then
    $PRESTODEV_POST_BOOTSTRAP_COMMAND
fi

wait
