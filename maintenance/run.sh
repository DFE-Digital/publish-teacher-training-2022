#!/bin/sh

set -e

FILEBEAT_CONFIG=/etc/filebeat/filebeat.yml

filebeat test config -c $FILEBEAT_CONFIG
filebeat test output -c $FILEBEAT_CONFIG
nohup filebeat -e -c $FILEBEAT_CONFIG &

nginx -g 'daemon off;'
