FROM centos:6
MAINTAINER Stanislaw Ogorkis <stanislaw.ogorkis@teradata.com>

ARG JDK_URL
ARG JDK_RPM

# Install Oracle Java
RUN yum update -y && \
    yum install -y wget && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL && \
    rpm -ivh $JDK_RPM && rm $JDK_RPM

# Clean up
RUN yum -y clean all && rm -rf /tmp/* /var/tmp/*
