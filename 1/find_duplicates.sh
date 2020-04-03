#!/bin/bash
#./find_duplicates.sh http://losangeles.alphanet.cat:9200 `date -d "2019-07-24 00:00:00" +"%s000"` `date -d "2019-07-24 23:59:59" +"%s999"` SMP_CT1
URL=$1
FROM_EPOCH=$2
TO_EPOCH=$3
CAMERA=$4
curl ${URL}/plate/_search --silent --data "{\
    \"aggs\": {\
        \"duplicateCount\": {\
            \"aggs\": {\
                \"duplicateDocuments\": {\
                    \"top_hits\": {\
                        \"size\": 1\
                    }\
                }\
            },\
            \"terms\": {\
                \"field\": \"takeOn\", \
                \"min_doc_count\": 2,\
                \"size\": 10000\
            }\
        }\
    },\
    \"query\": {\
        \"bool\": {\
            \"must\": [\
                {\
                    \"range\": {\
                        \"takeOn\": {\
                            \"gt\": ${FROM_EPOCH},\
                            \"lt\": ${TO_EPOCH}\
                        }\
                    }\
                },\
                {\
                    \"term\": {\
                        \"idCamera\": \"${CAMERA}\"\
                    }\
                }\
            ]\
        }\
    },\
    \"size\": 0\
}" --header "content-type: application/json" --REQUEST POST \
| jq " .aggregations.duplicateCount.buckets[]" | jq --compact-output '{ doc_count: .doc_count, idCamera: .duplicateDocuments.hits.hits[0]._source.idCamera, takeOn: .duplicateDocuments.hits.hits[0]._source.takeOn, plateNumber: .duplicateDocuments.hits.hits[0]._source.plateNumber, cameraTown: .duplicateDocuments.hits.hits[0]._source.cameraTown, _id: .duplicateDocuments.hits.hits[0]._id }'