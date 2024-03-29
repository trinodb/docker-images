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
FROM testing/centos7-oj11:unlabelled$ARCH

ARG SPARK_VERSION=3.4.2
ARG HADOOP_VERSION=3
ARG ICEBERG_VERSION=1.5.0
# ICEBERG_JAR_VERSION is derived from: <spark-version>_<scala-version>
ARG ICEBERG_JAR_VERSION=3.4_2.12
ARG POSTGRESQL_JAR_VERSION=42.3.5

ARG SPARK_ARTIFACT="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"

ENV SPARK_HOME=/spark

RUN set -xeu; \
    wget -nv "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARTIFACT}.tgz"; \
    tar -xf ${SPARK_ARTIFACT}.tgz; \
    rm ${SPARK_ARTIFACT}.tgz; \
    ln -sn /${SPARK_ARTIFACT} ${SPARK_HOME}

WORKDIR ${SPARK_HOME}/jars

# install AWS SDK so we can access S3; the version must match the hadoop-* jars which are part of SPARK distribution
RUN wget -nv "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar"
RUN wget -nv "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.319/aws-java-sdk-bundle-1.12.319.jar"

# install Iceberg
RUN wget -nv "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-${ICEBERG_JAR_VERSION}/${ICEBERG_VERSION}/iceberg-spark-runtime-${ICEBERG_JAR_VERSION}-${ICEBERG_VERSION}.jar"

# install PostgreSQL driver for JDBC catalog
RUN wget -nv "https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRESQL_JAR_VERSION}/postgresql-${POSTGRESQL_JAR_VERSION}.jar"

ENV PATH="${SPARK_HOME}/bin:${PATH}"

# add hive user needed in interactions with the Apache Hive environment
RUN useradd -ms /bin/bash hive

CMD spark-submit \
   --master "local[*]" \
   --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
   --name "Thrift JDBC/ODBC Server" \
   --conf spark.hive.server2.thrift.port=10213 \
   spark-internal
