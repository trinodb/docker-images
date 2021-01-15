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

FROM prestodev/centos7-oj11:unlabelled

ARG SPARK_VERSION=3.0.0
ARG HADOOP_VERSION=2.7
ARG ICEBERG_VERSION=0.9.0

ARG SPARK_ARTIFACT="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"

ENV SPARK_HOME=/spark

RUN set -xeu; \
    wget "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARTIFACT}.tgz"; \
    tar -xf ${SPARK_ARTIFACT}.tgz; \
    rm ${SPARK_ARTIFACT}.tgz; \
    ln -sn /${SPARK_ARTIFACT} ${SPARK_HOME}

WORKDIR ${SPARK_HOME}/jars

# install Iceberg and temporarily add an inadvertent dependency required for Iceberg
# (see https://github.com/apache/iceberg/pull/1278)
RUN set -xeu; \
    wget "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark3-runtime/${ICEBERG_VERSION}/iceberg-spark3-runtime-${ICEBERG_VERSION}.jar"; \
    wget "https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.19/commons-compress-1.19.jar"

ENV PATH="${SPARK_HOME}/bin:${PATH}"
