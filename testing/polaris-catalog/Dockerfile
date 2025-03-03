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

FROM gradle:8.11-jdk21 AS builder

RUN git clone --depth=1 https://github.com/apache/polaris.git /polaris

WORKDIR /polaris

RUN gradle :polaris-quarkus-server:build

FROM eclipse-temurin:21-jre-alpine

ARG POLARIS_VERSION=1.0.0-incubating-SNAPSHOT

COPY --from=builder /polaris/quarkus/server/build/distributions/polaris-quarkus-server-1.0.0-incubating-SNAPSHOT.zip /polaris-quarkus-server-${POLARIS_VERSION}.zip
RUN unzip polaris-quarkus-server-${POLARIS_VERSION}.zip

EXPOSE 8181

CMD ["java", "-jar", "polaris-quarkus-server-${POLARIS_VERSION}/quarkus-run.jar"]
