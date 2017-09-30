# Copyright 2016 Teradata
#
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

FROM prestosql/hdp2.5-base:unlabelled
MAINTAINER Teradata Docker Team <docker@teradata.com>

# Good grief. Get rid of the default hdp config.
RUN rm -r /etc/hadoop/conf/*

# ADD BOOTSTRAP SCRIPT
COPY files/bootstrap.sh /root/

# Copy the real config in now that setup has run
COPY files/conf/* /etc/hadoop/conf/

# HDFS PORTS
EXPOSE 50010 1004 50075 1006 50020 8020 50070 50470

# YARN PORTS
EXPOSE 8032 8030 8031 8033 8088 8040 8042 8041 10020 19888

CMD /root/startup.sh
