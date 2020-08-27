FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

# Version arguments and install dir, GPHOME is symlink
ARG GPDB_MAJOR_VERSION=6
ARG GPDB_VERSION=6.10.1-1
ARG GPDB_DIR=/opt/greenplum-db-$GPDB_MAJOR_VERSION-6.10.1

ENV GPHOME=/opt/greenplum-db
ENV DATABASE gpadmin

COPY ./files /

# Install dependencies and GPDB
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:greenplum/db && \
    apt-get update -y && \
    apt-get install -y \
        greenplum-db-$GPDB_MAJOR_VERSION=$GPDB_VERSION \
        iputils-ping \
        locales \
        locales-all \
        openssh-client \
        openssh-server \
        python \
        python-dev && \
    apt-get clean

RUN ln -s $GPDB_DIR ${GPHOME} && \
    # Create gpadmin user
    adduser --home /home/gpadmin gpadmin --disabled-password --gecos GECOS && \
    usermod --password gpadmin gpadmin && \
    chown -R gpadmin: /home/gpadmin && \
    # Create data directories and set ownership
    mkdir -p /gpmaster /gpdata1 /gpdata2 && chown gpadmin: /gpmaster /gpdata1 /gpdata2 && \
    # Start SSH service and initialize GPDB
    service ssh start && \
    su gpadmin -l -c configure_gpdb.sh && \
    # Allow client access from any host
    echo "host all all 0.0.0.0/0 md5" >> /gpmaster/gpsne-1/pg_hba.conf

# Expose client port
EXPOSE 5432

# Start SSH service, start GPDB, then tail nothing to keep the container running
CMD entrypoint.sh

HEALTHCHECK --start-period=5m \
  CMD su gpadmin -l -c "pg_isready"
