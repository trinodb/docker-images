FROM teradatalabs/centos6-java8-oracle
MAINTAINER Stanislaw Ogorkis <stanislaw.ogorkis@teradata.com>

# Setup CDH repo, pin the CDH distribution to a concrete version
RUN wget http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm \
  && yum --nogpgcheck localinstall -y cloudera-cdh-5-0.x86_64.rpm \
  && rm cloudera-cdh-5-0.x86_64.rpm \
  && rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera \
  && sed -i '/^baseurl=/c\baseurl=https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.8.2/' /etc/yum.repos.d/cloudera-cdh5.repo \

# Install supervisord
  && yum install -y python-setuptools \
  && easy_install pip \
  && pip install supervisor \
  && mkdir /etc/supervisord.d/ \
# ... and its missing dependency
  && wget http://dl.fedoraproject.org/pub/epel/6/x86_64/python-meld3-0.6.7-1.el6.x86_64.rpm \
  && rpm -ihv python-meld3-0.6.7-1.el6.x86_64.rpm \
  && rm python-meld3-0.6.7-1.el6.x86_64.rpm \

# Cleanup
  && yum -y clean all && rm -rf /tmp/* /var/tmp/*
