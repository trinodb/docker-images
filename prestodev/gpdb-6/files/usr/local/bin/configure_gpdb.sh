#!/bin/bash

source ${GPHOME}/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1

# SSH is still required by the initialization and start scripts for GPDB even though it is installing it on a single host

# Create and exchange keys
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys
ssh-keyscan -H localhost >> ~/.ssh/known_hosts
gpssh-exkeys -f /home/gpadmin/gpdb-hosts

# Initialize GPDB
gpinitsystem -a -c /home/gpadmin/gpinitsystem_singlenode -h /home/gpadmin/gpdb-hosts

# Set the password
psql -d template1 -c "alter user gpadmin password 'gpadmin'"
