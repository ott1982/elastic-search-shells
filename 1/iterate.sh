#!/bin/bash
DB_HOST=${DATABASE_HOST}
DB_PORT=${DATABASE_PORT}
DB_DATABASE=${DATABASE_DATABASE}
DB_USERNAME=${DATABASE_USERNAME}
DB_PASSWORD=${DATABASE_PASSWORD}
URL=${ELASTIC_SEARCH_URL}
OPT_DIRECTORY=/opt/adm-search-engine-cleaner
LIB_DIRECTORY=/var/lib/adm-search-engine-cleaner
LOG_DIRECTORY=/var/log/adm-search-engine-cleaner
ETC_DIRECTORY=/etc/adm-search-engine-cleaner
CAMERA_SQL=${ETC_DIRECTORY}/sql/camera_id.sql
REFERENCED_SQL=${ETC_DIRECTORY}/sql/referenced_elastic_plates.sql
DATES_FILE=${LIB_DIRECTORY}/dates.txt
CAMERAS_FILE=${LIB_DIRECTORY}/cameras.txt
REFERENCED_FILE=${LIB_DIRECTORY}/referenced_plates.txt
DUPLICATIONS=${LIB_DIRECTORY}/duplications.json
REFERENCED=${LIB_DIRECTORY}/referenced.json
BULK_DUPLICATES=${LIB_DIRECTORY}/bulk_duplicates.json
BULK_REFERENCED=${LIB_DIRECTORY}/bulk_referenced.json
SUMMARY=${LIB_DIRECTORY}/summary.log
CURRENT_DATE=`date`
TOTAL_COUNT=`${OPT_DIRECTORY}/total_count.sh $URL`
HOST=$ADM_SMTP_HOST
ACCOUNT_USERNAME=$ADM_SMTP_USERNAME
ACCOUNT_PASSWORD=$ADM_SMTP_PASSWORD
FROM=$ADM_SMTP_FROM
TO=$ADM_SMTP_TO
[ -f "$DUPLICATIONS" ] && rm $DUPLICATIONS
[ -f "$BULK_DUPLICATES" ] && rm $BULK_DUPLICATES
[ -f "$BULK_REFERENCED" ] && rm $BULK_REFERENCED
[ -f "$REFERENCED" ] && rm $REFERENCED
[ -f "$CAMERAS_FILE" ] && rm $CAMERAS_FILE
[ -f "$REFERENCED_FILE" ] && rm $REFERENCED_FILE
[ -f "$DATES_FILE" ] && rm $DATES_FILE
[ -f "$SUMMARY" ] && rm $SUMMARY
echo -e "$DB_HOST $DB_PORT $DB_DATABASE $DB_USERNAME $DB_PASSWORD $URL"
echo -e "GENERATING DATES"
${OPT_DIRECTORY}/dates_generator.sh 2017-08-01 `date +%Y-%m-%d` > $DATES_FILE
echo -e "GETTING CAMERAS"
${OPT_DIRECTORY}/psql.sh $DB_HOST $DB_PORT $DB_DATABASE $DB_USERNAME $DB_PASSWORD $CAMERA_SQL > $CAMERAS_FILE
echo -e "GETTING REFERENCED ELASTIC DOCS"
${OPT_DIRECTORY}/psql.sh $DB_HOST $DB_PORT $DB_DATABASE $DB_USERNAME $DB_PASSWORD $REFERENCED_SQL > $REFERENCED_FILE
cat $REFERENCED_FILE | while read referenced || [[ -n $referenced ]];
do
	echo -e "DUMPING $referenced"
	${OPT_DIRECTORY}/find_by_id.sh $URL $referenced | jq --compact-output "{\"index\":{\"_index\":\"plate\",\"_type\":\"_doc\",\"_id\":._id}}, ._source" >> $BULK_REFERENCED
done
cat $DATES_FILE | while read date || [[ -n $date ]];
do
	cat $CAMERAS_FILE | while read camera || [[ -n $camera ]];
	do
		echo -e "DATE: $date; CAMERA: $camera"
		${OPT_DIRECTORY}/find_duplicates.sh $URL `date -d "${date} 00:00:00" +"%s000"` `date -d "${date} 23:59:59" +"%s999"` $camera >> $DUPLICATIONS
	done
done
echo -e "BACKUPING UNIQUE DOCUMENT OF EACH DUPLICATION IN $BULK_DUPLICATES"
cat $DUPLICATIONS | while read duplicate || [[ -n $duplicate ]];
do
	ID=`echo $duplicate | jq --raw-output ._id`
	${OPT_DIRECTORY}/find_by_id.sh $URL $ID | jq --compact-output "{\"index\":{\"_index\":\"plate\",\"_type\":\"_doc\",\"_id\":._id}}, ._source" >> $BULK_DUPLICATES
done
echo -e "DELETING DUPLICATES SAVED IN $DUPLICATIONS"
cat $DUPLICATIONS | while read duplicate || [[ -n $duplicate ]];
do
	TIME=`echo $duplicate | jq --raw-output .takeOn`
	CAMERA=`echo $duplicate | jq --raw-output .idCamera`
	PLATE=`echo $duplicate | jq --raw-output .plateNumber`
	echo -e "REMOVING BY QUERY[ TIME: $TIME; CAMERA: $CAMERA; PLATE: $PLATE ]"
	${OPT_DIRECTORY}/delete_by_takeon_plate_camera.sh $URL $TIME $PLATE $CAMERA > /dev/null
done
echo -e "BULKING DUPLICATES SAVED DATA TO ELASTIC SEARCH FROM $BULK_DUPLICATES"
${OPT_DIRECTORY}/bulk.sh ${URL} $BULK_DUPLICATES > /dev/null
echo -e "\n\nBULKING REFERENCED DOCS SAVED DATA TO ELASTIC SEARCH FROM $BULK_REFERENCED"
${OPT_DIRECTORY}/bulk.sh ${URL} $BULK_REFERENCED > /dev/null
echo -e "GENERATING SUMMARY\n"
echo -e "Started at: $CURRENT_DATE" >> $SUMMARY
echo -e "Completed at: $CURRENT_DATE" >> $SUMMARY
echo -e "Detections: `cat $DUPLICATIONS | wc -l`" >> $SUMMARY
REMOVED=`${OPT_DIRECTORY}/count.sh $DUPLICATIONS`
echo -e "Deleted documents: $REMOVED" >> $SUMMARY
echo -e "Initial documents total count: $TOTAL_COUNT" >> $SUMMARY
CURRENT_TOTAL_COUNT=`${OPT_DIRECTORY}/total_count.sh $URL`
echo -e "Final documents total count: $CURRENT_TOTAL_COUNT" >> $SUMMARY
echo -e "\n\n"
cat $SUMMARY
echo -e "\n"
${OPT_DIRECTORY}/mail.sh $HOST $ACCOUNT_USERNAME $ACCOUNT_PASSWORD $FROM $TO ADM_Search_engine_cleaner_report_`date +%Y-%m-%d` $SUMMARY