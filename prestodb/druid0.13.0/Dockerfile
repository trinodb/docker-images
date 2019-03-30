# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04
MAINTAINER Presto community <https://prestosql.io/community.html>

# Copy configuration files
COPY ./files/root/*.sh /root/

COPY ./files/data/*.json /root/data/

RUN chmod +x /root/*.sh && /root/setup.sh

RUN rm -rf ./files

# Expose ports:
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 8091: HTTP (middlemanager)
# - 2181 2888 3888: ZooKeeper

EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 8091
EXPOSE 2181 2888 3888

WORKDIR /usr/local/druid
ENTRYPOINT ["/root/entrypoint.sh"]

