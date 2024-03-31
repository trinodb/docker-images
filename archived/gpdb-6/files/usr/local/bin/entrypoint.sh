#!/bin/bash

echo "127.0.0.1 $(cat ~/original_hostname)" >> /etc/hosts

service ssh start
su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1 ; source ${GPHOME}/greenplum_path.sh ; gpstart -a ; createdb ${DATABASE}"

if test -d /docker/gpdb-init.d; then
    for init_script in /docker/gpdb-init.d/*; do
        "${init_script}"
    done
fi

tail -f /gpmaster/gpsne-1/pg_log/gpdb-*.csv
