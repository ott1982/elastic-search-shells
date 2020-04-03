#!/bin/bash
DB_HOST=$1
DB_PORT=$2
DB_DATABASE=$3
DB_USERNAME=$4
DB_PASSWORD=$5
FILE=$6
PGPASSWORD=$DB_PASSWORD psql --tuples-only --no-align --host=$DB_HOST --port=$DB_PORT --dbname=$DB_DATABASE --username=$DB_USERNAME --no-password < $FILE