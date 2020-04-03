#!/bin/bash
# ./dates_generator.sh 2017-08-01 `date +%Y-%m-%d`
FROM=$1
TO=$2
counter=0
while true; do
	date=`date -d "$FROM+$counter day" +"%Y-%m-%d"`
	echo $date
	if [[ "`date -d \"$date 00:00:00.000\" +%s`" -ge "`date -d \"$TO 00:00:00.000\" +%s`" ]]; then
		break
	fi
	counter=$((counter+1))
done