FROM prestodb/centos6-presto-admin-tests-runtime:unlabelled
MAINTAINER Presto community <https://prestosql.io/community.html>

RUN yum install -y \
      wget \
      gcc \
      python-devel \
      python-devel \
      python-pip \
      openssl-devel \
      libffi-devel && \
    pip install --upgrade pip==9.0.3 `# latest version for Python 2.6` && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*
