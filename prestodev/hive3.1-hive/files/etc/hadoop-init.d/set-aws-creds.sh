#!/bin/bash -x

if [[ -n "${AWS_ACCESS_KEY_ID}" ]]
then
    sed -i  -e "s|\"Use AWS_ACCESS_KEY_ID .*\"|${AWS_ACCESS_KEY_ID}|g" \
            -e "s|\"Use AWS_SECRET_ACCESS_KEY .*\"|${AWS_SECRET_ACCESS_KEY}|g" \
            /opt/hive/conf/hive-site.xml
fi
