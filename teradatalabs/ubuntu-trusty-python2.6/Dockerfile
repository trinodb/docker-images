FROM ubuntu:14.04

RUN echo "deb http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu trusty main" \
    > /etc/apt/sources.list.d/fkrull-deadsnakes-trusty.list \
    && sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys DB82666C \
    && sudo apt-get update \
    && sudo apt-get -y install python2.6 \
    && ln -s /usr/bin/python2.6 /usr/bin/python
