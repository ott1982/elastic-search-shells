#!/bin/bash
# ./bulk.sh http://frankfurt.alphanet.cat:9200 /tmp/bulk.json
URL=$1
FILE=$2
curl $URL/_bulk --silent --header "content-type: application/x-ndjson" --data-binary @${FILE}