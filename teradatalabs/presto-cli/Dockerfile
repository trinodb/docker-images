FROM java:8-jre
ARG PRESTO_VERSION

ADD http://teradata-presto.s3.amazonaws.com/presto/$PRESTO_VERSION/presto-cli-$PRESTO_VERSION-executable.jar /usr/local/bin/presto

RUN chmod +x /usr/local/bin/presto

RUN apt-get update && \
    apt-get install -yf less && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/usr/local/bin/presto"]
