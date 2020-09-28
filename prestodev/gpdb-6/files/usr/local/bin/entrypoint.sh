#!/bin/bash

echo "127.0.0.1 $(cat ~/original_hostname)" >> /etc/hosts

service ssh start
su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1 ; source ${GPHOME}/greenplum_path.sh ; gpstart -a ; createdb ${DATABASE}"
tail -f /gpmaster/gpsne-1/pg_log/gpdb-*.csv
