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

FROM apache/iceberg-rest-fixture:1.10.1

ARG HADOOP_CLIENT_VERSION=3.4.1

USER root

RUN mkdir -p /etc/hadoop/conf /usr/lib/iceberg-rest/lib
RUN curl -fLsS -o /usr/lib/iceberg-rest/lib/hadoop-client-api-${HADOOP_CLIENT_VERSION}.jar \
        https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-api/${HADOOP_CLIENT_VERSION}/hadoop-client-api-${HADOOP_CLIENT_VERSION}.jar && \
    curl -fLsS -o /usr/lib/iceberg-rest/lib/hadoop-client-runtime-${HADOOP_CLIENT_VERSION}.jar \
        https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-runtime/${HADOOP_CLIENT_VERSION}/hadoop-client-runtime-${HADOOP_CLIENT_VERSION}.jar

USER iceberg:iceberg

CMD ["java", "-cp", "/etc/hadoop/conf:/usr/lib/iceberg-rest/lib/*:/usr/lib/iceberg-rest/iceberg-rest-adapter.jar", "org.apache.iceberg.rest.RESTCatalogServer"]
