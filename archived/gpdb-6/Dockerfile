# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

# Version arguments and install dir, GPHOME is symlink
ARG GPDB_VERSION=6.11.1
ARG GPHOME=/usr/gpdb
ARG GPDB_DIR=/usr/local/greenplum-db-$GPDB_VERSION

ENV GPHOME=/usr/gpdb
ENV DATABASE gpadmin

COPY ./files /

# Install dependencies and GPDB
RUN apt-get update -y && \
    apt-get install -y \
        iputils-ping \
        locales \
        locales-all \
        openssh-client \
        openssh-server && \
    apt-get clean

# Install GPDB
RUN wget https://github.com/greenplum-db/gpdb/releases/download/$GPDB_VERSION/greenplum-db-$GPDB_VERSION-ubuntu18.04-amd64.deb && \
    apt install -y ./greenplum-db-$GPDB_VERSION-ubuntu18.04-amd64.deb && \
    rm greenplum-db-$GPDB_VERSION-ubuntu18.04-amd64.deb && \
    ln -s $GPDB_DIR $GPHOME && \
    apt-get clean

# Create gpadmin user
RUN adduser --home /home/gpadmin gpadmin --disabled-password --gecos GECOS && \
    usermod --password gpadmin gpadmin && \
    chown -R gpadmin: /home/gpadmin && \
    # Create data directories and set ownership
    mkdir -p /gpmaster /gpdata1 /gpdata2 && chown gpadmin: /gpmaster /gpdata1 /gpdata2 && \
    # Start SSH service and initialize GPDB
    service ssh start && \
    su gpadmin -l -c configure_gpdb.sh && \
    hostname > ~/original_hostname && \
    # Allow client access from any host
    echo "host all all 0.0.0.0/0 md5" >> /gpmaster/gpsne-1/pg_hba.conf

# Expose client port
EXPOSE 5432

# Start SSH service, start GPDB, then tail nothing to keep the container running
CMD entrypoint.sh

HEALTHCHECK --start-period=5m \
  CMD su gpadmin -l -c "pg_isready"
