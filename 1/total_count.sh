#!/bin/bash
# ./total_count.sh http://losangeles.alphanet.cat:9200
URL=$1
curl $URL/plate/_search\?size\=0 --silent | jq ".hits.total"