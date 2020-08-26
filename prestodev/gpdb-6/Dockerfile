FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

# Version arguments and install dir, GPHOME is symlink
ARG GPDB_MAJOR_VERSION=6
ARG GPDB_VERSION=6.10.1-1
ARG GPDB_DIR=/opt/greenplum-db-$GPDB_MAJOR_VERSION-6.10.1
ENV GPHOME=/opt/greenplum-db
ENV DATABASE gpadmin

# Install configurations, psql wrapper script, and GPDB start script
COPY ./files /

# Install dependencies and GPDB
# Create gpadmin user
# Create data directories and set ownership
# Setup passwordless ssh for gpadmin users
# Initialize GPDB
# Allow client access from any host
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:greenplum/db && \
    apt-get update -y && \
    apt-get install -y python python-dev \
        openssh-server openssh-client locales locales-all iputils-ping \
        greenplum-db-$GPDB_MAJOR_VERSION=$GPDB_VERSION && \
    ln -s $GPDB_DIR ${GPHOME} && \
    adduser --home /home/gpadmin gpadmin --disabled-password --gecos GECOS && \
    usermod --password gpadmin gpadmin && \
    chown gpadmin:gpadmin /home/gpadmin/gpinitsystem_singlenode /home/gpadmin/gpdb-hosts && \
    mkdir -p /gpmaster /gpdata1 /gpdata2 && chown gpadmin: /gpmaster /gpdata1 /gpdata2 && \
    service ssh start && \
    chown -R gpadmin: /home/gpadmin && \
    su gpadmin -l -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa" && \
    su gpadmin -l -c "cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys" && \
    su gpadmin -l -c "ssh-keyscan -H localhost >> ~/.ssh/known_hosts" && \
    su gpadmin -l -c "source ${GPHOME}/greenplum_path.sh; gpssh-exkeys -f /home/gpadmin/gpdb-hosts" && \
    su gpadmin -l -c "source ${GPHOME}/greenplum_path.sh; gpinitsystem -a -c /home/gpadmin/gpinitsystem_singlenode -h /home/gpadmin/gpdb-hosts; exit 0 " && \
    su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1; source ${GPHOME}/greenplum_path.sh; psql -d template1 -c \"alter user gpadmin password 'gpadmin'\"; exit 0" && \
    echo "host all all 0.0.0.0/0 md5" >> /gpmaster/gpsne-1/pg_hba.conf

# Expose client port
EXPOSE 5432

# Start SSH service, start GPDB, then tail nothing to keep the container running
CMD service ssh start && \
        su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1 ; source ${GPHOME}/greenplum_path.sh ; gpstart -a ; createdb ${DATABASE}" && \
        tail -f /gpmaster/gpsne-1/pg_log/gpdb-*.csv

HEALTHCHECK --start-period=5m \
  CMD su gpadmin -l -c "pg_isready"
