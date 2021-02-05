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

# Use last layer from ghcr.io/trinodb/testing/hdp3.1-hive:38
FROM f6949adf3207

# Copy configuration files
COPY ./files /

# Remove old SSH keys
RUN rm -Rf /root/.ssh/* /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN yum-config-manager --disable HDP-GPL-3.1.0.0

# Setup sock proxy
RUN yum install -y openssh openssh-clients openssh-server && yum -y clean all
RUN ssh-keygen -t rsa -b 4096 -C "automation@trino.io" -N "" -f /root/.ssh/id_rsa \
  && ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -t dsa -b 1024 -N "" -f /etc/ssh/ssh_host_dsa_key \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 755 /root && chmod 700 /root/.ssh
RUN passwd --unlock root

# Provide convenience bash history
RUN set -xeu; \
    echo "supervisorctl restart all" >> ~root/.bash_history; \
    for user in root hive hdfs; do \
        sudo -u "${user}" bash -c ' echo "" > ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "netstat -ltnp" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "beeline -n hive" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "hdfs dfs -ls -R /user/hive/warehouse" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' mkdir -p ~/.beeline '; \
        sudo -u "${user}" bash -c ' echo "SELECT current_user();" >> ~/.beeline/history '; \
    done

# HDFS ports
EXPOSE 1004 1006 8020 9866 9867 9870 9864 50470

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE ports
EXPOSE 9083 10000

# SOCKS port
EXPOSE 1180

CMD supervisord -c /etc/supervisord.conf
