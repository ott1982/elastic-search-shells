#!/bin/bash
# ./migrate.sh http://losangeles.alphanet.cat:9200 http://frankfurt.alphanet.cat:9200 plate 100000 takeOn desc
SOURCE=$ES_SOURCE
TARGET=$ES_TARGET
INDEX=$ES_INDEX
SIZE=$ES_SIZE
SORT_FIELD=$ES_FIELD
SORT_DIRECTION=$ES_DIRECTION
BUFFER=/tmp/buffer.json
PAGE_SIZE=10000
counter=0
START=`date`
OPT_DIRECTORY=/opt/elastic-search-migrator
TAKEON=`date +%s000`
echo -e "SOURCE: $SOURCE"
echo -e "TARGET: $TARGET"
echo -e "INDEX: $INDEX"
echo -e "SIZE: $SIZE"
echo -e "SORT_FIELD: $SORT_FIELD"
echo -e "SORT_DIRECTION: $SORT_DIRECTION"
while [ $counter -le $SIZE ]
do
	echo -e "$SOURCE $INDEX $TAKEON $PAGE_SIZE takeOn desc --> $TARGET"
	${OPT_DIRECTORY}/query.sh $SOURCE $INDEX $TAKEON $PAGE_SIZE takeOn desc | jq ".hits.hits[]" | jq --compact-output "{\"index\":{\"_index\": ._index,\"_type\":\"_doc\",\"_id\": ._id}}, ._source" > $BUFFER
	echo -e "$SOURCE $INDEX $TAKEON 1 takeOn asc"
	NEW_TAKEON=`${OPT_DIRECTORY}/query.sh $SOURCE $INDEX $TAKEON 1 takeOn asc | jq "._source.takeOn"`
	echo $NEW_TAKEON
	${OPT_DIRECTORY}/bulk.sh $TARGET $BUFFER > /dev/null
	counter=$((counter+$PAGE_SIZE))
	TAKEON=$NEW_TAKEON
done
rm $BUFFER
echo -e "\n\n+ Started at $START and completed at `date`.\n"