#!/bin/bash
#./find_by_id.sh http://losangeles.alphanet.cat:9200 90c9b6c6-b7a3-4cf5-9d0b-ab1607d2fd9b
URL=$1
ID=$2
curl $URL/plate/_doc/${ID} --silent