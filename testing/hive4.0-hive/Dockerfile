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

FROM apache/hive:4.0.0

ARG HADOOP_AWS_VERSION=3.4.2
ARG AWSSDK_VERSION=2.41.6

USER root
RUN apt-get -y update
RUN apt install curl -y

# Install AWS SDK so we can access S3; the version must match the hadoop-aws* jars which are part of SPARK distribution
RUN mkdir -p /opt/hive/auxlib && \
    curl -fLsS -o /opt/hive/auxlib/software-amazon-awssdk-bundle-$AWSSDK_VERSION.jar https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/$AWSSDK_VERSION/bundle-$AWSSDK_VERSION.jar && \
    curl -fLsS -o /opt/hive/auxlib/hadoop-aws-$HADOOP_AWS_VERSION.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar
