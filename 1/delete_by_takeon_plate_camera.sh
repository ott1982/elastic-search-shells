#!/bin/bash
# ./delete_by_takeon_plate_camera.sh http://losangeles.alphanet.cat:9200 1563980643982 5815JWW SMP_CT1
URL=$1
TAKEON=$2
PLATE=$3
CAMERA=$4
curl $URL/plate/_delete_by_query \
--silent \
--header "content-type: application/json" \
--data "{ \
    \"query\": {\
        \"bool\": {\
            \"must\": [\
                {\
                    \"term\": {\
                        \"idCamera\": \"${CAMERA}\"\
                    }\
                },\
                {\
                    \"term\": {\
                        \"takeOn\": ${TAKEON}\
                    }\
                }\
            ]\
        }\
    }\
}"