FROM centos:6
MAINTAINER Stanislaw Ogorkis <stanislaw.ogorkis@teradata.com>

# Install Oracle Java
RUN yum update -y
RUN yum install -y wget && \
        wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
RUN rpm -ivh jdk-8u92-linux-x64.rpm && rm jdk-8u92-linux-x64.rpm

# Clean up
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*
