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

FROM centos:6
MAINTAINER Teradata Docker Team <docker@teradata.com>

# Install presto-admin dependences (already has python 2.6)
RUN \
    yum install -y epel-release && \
    yum install -y wget bzip2 gcc python-devel python-pip tar expec libffi-devel openssl-devel && \
    yum -y clean all && \
    rm -rf \tmp\* \var\tmp\*

RUN \
    pip install --upgrade setuptools==20.1.1 && \
    pip install --upgrade pip==7.1.2 && \
    pip install --upgrade wheel==0.23.0 && \
    pip install --upgrade argparse==1.4 && \
    pip install --upgrade paramiko==1.15.3 && \
    pip install --upgrade flake8==2.5.4 && \
    pip install --upgrade py==1.4.26 && \
    pip install --upgrade Sphinx==1.3.1 && \
    pip install --upgrade fabric==1.10.1 && \
    pip install --upgrade requests==2.7.0 && \
    pip install --upgrade certifi==2015.4.28 && \
    pip install --upgrade fudge==1.1.0 && \
    pip install --upgrade PyYAML==3.11 && \
    pip install --upgrade overrides==0.5 && \
    pip install --upgrade retrying==1.3.3
