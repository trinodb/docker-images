FROM prestodb/centos6-presto-admin-tests-runtime:unlabelled
MAINTAINER Teradata Docker Team <docker@teradata.com>

RUN yum install -y \
      wget \
      gcc \
      python-devel \
      python-devel \
      openssl-devel \
      libffi-devel && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

# install pip
RUN wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python /tmp/get-pip.py
