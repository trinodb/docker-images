#!/bin/bash
set -euo pipefail

create_principal -p hdfs/hadoop-master -k /shared/keytabs/hdfs.keytab
create_principal -p hive/hadoop-master -k /shared/keytabs/hive.keytab
create_principal -p HTTP/hadoop-master -k /shared/keytabs/HTTP.keytab
create_principal -p mapred/hadoop-master -k /shared/keytabs/mapred.keytab
create_principal -p yarn/hadoop-master -k /shared/keytabs/yarn.keytab
