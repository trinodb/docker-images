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

FROM gradle:8.14-jdk21 AS builder

RUN git clone --depth=1 https://github.com/apache/polaris.git /polaris

WORKDIR /polaris

RUN gradle :polaris-server:build

FROM eclipse-temurin:21-jre-alpine

COPY --from=builder /polaris/runtime/server/build/quarkus-app/lib/ /lib/
COPY --from=builder /polaris/runtime/server/build/quarkus-app/*.jar/ /
COPY --from=builder /polaris/runtime/server/build/quarkus-app/app/ /app/
COPY --from=builder /polaris/runtime/server/build/quarkus-app/quarkus/ /quarkus/

EXPOSE 8181

CMD ["java", "-jar", "quarkus-run.jar"]
