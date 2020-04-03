#!/bin/bash
# ./mail.sh mail.vigilancia-municipal.com username passw adm@vigilancia-municipal.com otristany@alphanet.cat subject contentfile
HOST=$1
ACCOUNT_USERNAME=$2
ACCOUNT_PASSWORD=$3
FROM=$4
TO=$5
SUBJECT=$6
CONTENT=$7
cat $CONTENT | sendemail \
    -f "$FROM" \
    -u "$SUBJECT" \
    -t "$TO" \
    -s "$HOST" \
    -xu "$ACCOUNT_USERNAME" \
    -xp "$ACCOUNT_PASSWORD"