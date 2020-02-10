#!/bin/bash

set -exuo pipefail

function cleanup() {
    docker rm -f kerberos
}

trap cleanup INT TERM EXIT

docker run \
    -h kerberos \
    --name kerberos \
    --rm \
    --env PRESTODEV_POST_BOOTSTRAP_COMMAND='create_principal -p ala -k ala.keytab' \
    prestodev/kerberos &

# this is way too much, but we don't want automation to fail
sleep 60
docker exec kerberos create_principal -o -p tola -k tola.keytab
docker exec kerberos kinit -kt ala.keytab ala@STARBURSTDATA.COM

