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

ARG ARCH
FROM alpine:3.20 AS hadoop

ARG HADOOP_VERSION=3.4.2

RUN set -eux; \
    arch_suffix=; \
    if [ "$(uname -m)" = aarch64 ]; then arch_suffix=-aarch64; fi; \
    wget -q -O /tmp/hadoop.tar.gz "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}${arch_suffix}-lean.tar.gz"; \
    mkdir /hadoop; \
    tar -xzf /tmp/hadoop.tar.gz -C /hadoop --strip-components=1; \
    rm /tmp/hadoop.tar.gz

FROM testing/almalinux9-oj11:unlabelled$ARCH

ARG SPARK_VERSION=3.3.1
ARG HUDI_VERSION=0.12.3
ARG SCALA_VERSION=2.12
ARG AWSSDK_VERSION=2.29.52

ARG SPARK_ARTIFACT="spark-${SPARK_VERSION}-bin-hadoop3"

ENV SPARK_HOME=/spark
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_OPTIONAL_TOOLS=hadoop-aws
COPY --from=hadoop /hadoop /opt/hadoop

RUN set -xeu; \
    curl --retry 5 --retry-delay 10 --retry-all-errors -fLsS -o "${SPARK_ARTIFACT}.tgz" \
        "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARTIFACT}.tgz"; \
    tar -xf ${SPARK_ARTIFACT}.tgz; \
    rm ${SPARK_ARTIFACT}.tgz; \
    ln -sn /${SPARK_ARTIFACT} ${SPARK_HOME}; \
    # Keep Spark's Hive support, but replace every bundled Hadoop library.
    rm ${SPARK_HOME}/jars/hadoop-*.jar

WORKDIR ${SPARK_HOME}/jars

# Use the complete Hadoop runtime, including its matching S3 filesystem.
RUN echo 'export SPARK_DIST_CLASSPATH="$(/opt/hadoop/bin/hadoop classpath --glob)"' > /spark/conf/spark-env.sh
RUN wget -nv -P /opt/hadoop/share/hadoop/tools/lib "https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/$AWSSDK_VERSION/bundle-$AWSSDK_VERSION.jar"

# install Hudi
RUN wget -nv "https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark3-bundle_${SCALA_VERSION}/${HUDI_VERSION}/hudi-spark3-bundle_${SCALA_VERSION}-${HUDI_VERSION}.jar"

# Create Hive user to match Hive container
RUN adduser hive

ENV PATH="${SPARK_HOME}/bin:${PATH}"

EXPOSE 10213

CMD spark-submit \
   --master "local[*]" \
   --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
   --name "Thrift JDBC/ODBC Server" \
   --conf spark.hive.server2.thrift.port=10213 \
   spark-internal
