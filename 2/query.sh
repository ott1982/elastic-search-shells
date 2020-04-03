#!/bin/bash
# ./query.sh http://frankfurt.alphanet.cat:9200 plate 0 10 takeOn desc  | jq --compact-output "{\"index\":{\"_index\":\"plate\",\"_type\":\"_doc\",\"_id\":._id}}, ._source" >> /tmp/bulk.json
URL=$1
INDEX=$2
FROM=$3
SIZE=$4
SORT_FIELD=$5
SORT_DIRECTION=$6
curl $URL/$INDEX/_search \
    --silent \
    --request POST \
    --header "content-type: application/json" \
    --data "{\
    \"query\": {\
        \"range\" : {\
            \"$SORT_FIELD\" : {\
                \"lt\" : \"$FROM\" \
            }\
        }\
    },\
    \"size\": $SIZE,\
    \"sort\": [\
        {\
            \"$SORT_FIELD\": \"$SORT_DIRECTION\"\
        }\
    ]\
}"