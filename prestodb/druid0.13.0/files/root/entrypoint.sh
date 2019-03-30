#!/bin/bash -x
# Please make sure to allocate at least 4 GB of memory to this container or JVMs will crash loop
# Since we have set workdir as /usr/local/druid
exec bin/supervise -c quickstart/tutorial/conf/tutorial-cluster.conf &
sleep 60
bin/post-index-task --submit-timeout 300 --file /root/data/ingestion_test_index.json

tail -f /usr/local/apache-druid-0.13.0-incubating/var/sv/*.log
