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

FROM alpine:3.20 AS hadoop

ARG HADOOP_VERSION=3.4.2

RUN set -eux; \
    arch_suffix=; \
    if [ "$(uname -m)" = aarch64 ]; then arch_suffix=-aarch64; fi; \
    wget -q -O /tmp/hadoop.tar.gz "https://github.com/trinodb/docker-images/releases/download/dependency-mirror/hadoop-${HADOOP_VERSION}${arch_suffix}-lean.tar.gz"; \
    mkdir /hadoop; \
    tar -xzf /tmp/hadoop.tar.gz -C /hadoop --strip-components=1; \
    rm /tmp/hadoop.tar.gz

FROM apache/hive:4.0.0

ARG HADOOP_VERSION=3.4.2
ARG AWSSDK_VERSION=2.29.52

USER root

# Keep Hive and Tez on the same Hadoop runtime as the S3 filesystem.
RUN rm -rf /opt/hadoop /opt/tez/lib/hadoop-*.jar
COPY --from=hadoop --chown=hive:hive /hadoop /opt/hadoop
ENV HADOOP_VERSION=${HADOOP_VERSION}

# Install AWS SDK and Hadoop S3 support.
RUN mkdir -p /opt/hive/auxlib
ADD --chmod=644 https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/$AWSSDK_VERSION/bundle-$AWSSDK_VERSION.jar /opt/hive/auxlib/software-amazon-awssdk-bundle-$AWSSDK_VERSION.jar
RUN cp /opt/hadoop/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar /opt/hive/auxlib/
