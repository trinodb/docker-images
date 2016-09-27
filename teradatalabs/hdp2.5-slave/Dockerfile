FROM teradatalabs/hdp2.5-base
MAINTAINER Eric Diven <eric.diven@teradata.com>

# Good grief. Get rid of the default hdp config.
RUN rm -r /etc/hadoop/conf/*

# Append to the existing supervisor config, which sets up ssh access. This lets
# us add additional programs via the include mechanism
RUN echo -e "\n\n[include]\nfiles = /etc/supervisord.d/*.conf" \
	>> /etc/supervisord.conf

# Add the additional supervisord configuration
ADD files/supervisord.conf /etc/supervisord.conf
COPY files/supervisord.d/* /etc/supervisord.d/

# Copy the real config in now that setup has run
COPY files/conf/* /etc/hadoop/conf/

# HDFS PORTS
EXPOSE 50010 1004 50075 1006 50020 8020 50070 50470

# YARN PORTS
EXPOSE 8032 8030 8031 8033 8088 8040 8042 8041 10020 19888
