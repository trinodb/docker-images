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

RUN git clone --depth=1 https://github.com/polaris-catalog/polaris.git /polaris

WORKDIR /polaris

RUN gradle --no-daemon --info shadowJar

FROM eclipse-temurin:21-jre-alpine

COPY --from=builder /polaris/polaris-service/build/libs/polaris-service-1.0.0-incubating-SNAPSHOT.jar /polaris-service.jar
COPY --from=builder /polaris/polaris-server.yml /polaris-server.yml

EXPOSE 8181

CMD ["java", "-jar", "polaris-service.jar", "server", "polaris-server.yml"]
