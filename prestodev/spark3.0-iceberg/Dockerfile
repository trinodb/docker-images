FROM prestodev/centos7-oj11:unlabelled

ARG SPARK_VERSION=3.0.0
ARG HADOOP_VERSION=2.7
ARG ICEBERG_VERSION=0.9.1

ARG SPARK_ARTIFACT="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"

ENV SPARK_HOME=/spark

RUN set -xeu; \
    wget -nv "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARTIFACT}.tgz"; \
    tar -xf ${SPARK_ARTIFACT}.tgz; \
    rm ${SPARK_ARTIFACT}.tgz; \
    ln -sn /${SPARK_ARTIFACT} ${SPARK_HOME}

WORKDIR ${SPARK_HOME}/jars

RUN wget -nv "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark3-runtime/${ICEBERG_VERSION}/iceberg-spark3-runtime-${ICEBERG_VERSION}.jar"

ENV PATH="${SPARK_HOME}/bin:${PATH}"
