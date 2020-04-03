#!/bin/bash
# ./count.sh /tmp/duplications.json
FILE=$1
counter=0
cat $FILE | while read result || [[ -n $result ]];
do
	docCount=`echo "$result" | jq ".doc_count"`
	counter=$((counter+$docCount-1))
done
echo $counter