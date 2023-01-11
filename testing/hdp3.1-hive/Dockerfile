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

# Cloudera removed an access to HDP repositories in April 2021.
# In order to build new image version we use last released version as base.
# Previous Dockerfile version is archived in archived/hdp3.1-hive.
FROM ghcr.io/trinodb/testing/hdp3.1-hive:38

COPY ./files /

RUN \
    set -xeu && \
    # Remove unaccessible HDP3 repos so yum is still usable
    rm /etc/yum.repos.d/hdp*.repo && \
    # Install Zulu JDK 17.0.4
    rpm -i https://cdn.azul.com/zulu/bin/zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm && \
    # Set JDK 17 as a default one
    alternatives --set java /usr/lib/jvm/zulu-17/bin/java && \
    alternatives --set javac /usr/lib/jvm/zulu-17/bin/javac && \
    echo "Done"

# Provide convenience bash history
RUN set -xeu; \
    for user in root hive hdfs; do \
        # ~hive might be owned by root
        chown -R "${user}:" "$(eval echo ~"${user}")"; \
        sudo -u "${user}" bash -c ' echo "mysql -u root -proot -D metastore" >> ~/.bash_history '; \
    done
# HDFS ports
EXPOSE 1004 1006 8020 9866 9867 9870 9864 50470

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE ports
EXPOSE 9083 10000

# SOCKS port
EXPOSE 1180

CMD supervisord -c /etc/supervisord.conf
