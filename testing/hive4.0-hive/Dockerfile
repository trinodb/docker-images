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

# Install AWS SDK and Hadoop S3 support.
RUN mkdir -p /opt/hive/auxlib
ADD --chmod=644 https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/$AWSSDK_VERSION/bundle-$AWSSDK_VERSION.jar /opt/hive/auxlib/software-amazon-awssdk-bundle-$AWSSDK_VERSION.jar
ADD --chmod=644 https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar /opt/hive/auxlib/hadoop-aws-$HADOOP_AWS_VERSION.jar
