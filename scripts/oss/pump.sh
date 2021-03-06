#!/bin/bash

set -eao pipefail

usage() {

    cat <<EOF
Usage:
	$0 <gateway base url>

This script should be run from the repo root as it expects files (data/{org,api}.json) relative to it.
The base URL for the compose env in this repo is usually http://localhost:8080. A trailing slash is not required.
All authentication and parameters are hardcoded except for those which cannot
EOF
}

if [ -z $1 ]; then
    usage
    exit 1
fi

curlf() {
    curl --header 'content-type:application/json' -s --show-error "$@"
}

API_FILE=$(mktemp)
KEY_FILE=$(mktemp)
DATA_DIR=data/oss
PUMP_DATA_DIR=$DATA_DIR/pump-data
GWBASE=$1

cleanup() {
    rm -f $PUMP_DATA_DIR/*.csv
    rm -f $KEY_FILE $API_FILE
}

check_gw_status() {
    echo "Checking Tyk GW status..."
    status=$(curlf "${GWBASE}/hello" | jq -r '.status')
    if [ "$status" != "pass" ]
    then
        return 1
    fi
    redis_status=$(curlf "${GWBASE}/hello" | jq -r '.details.redis.status')
    if [ "$redis_status" != "pass" ]
    then
        return 1
    fi
    return 0
}

# Check if gw is up, if not wait a bit.
if ! check_gw_status
then
    echo "Gateway & gateway redis is not yet up, waiting a bit..."
    sleep 10
fi


# Add the test API - keyless APIs is not getting exported when pump is run.
echo "Adding a test API to the Tyk GW..."
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    -XPOST --data @data/oss/api.authenabled.json ${GWBASE}/tyk/apis

# Add a corresponding key
echo "Adding a key for the added API..."
KEY=$(curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" -XPOST --data @data/oss/key.json ${GWBASE}/tyk/keys | jq -r '.key')

# Hot reload gateway
echo "Executing gateway hot reload..."
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    ${GWBASE}/tyk/reload/group

# Wait a while for reload
sleep 2

# Get the key from the previous step and access the API endpoint with the key and a custom user agent.
echo "Accessing the added API with a custom user agent string..."
curl -v --header "Authorization: $KEY" --header "User-Agent: HAL9000" \
    "${GWBASE}/auth-enabled/"

# Sleep a while till the record gets exported
sleep 10

# Search for our custom  user agent in the csv file.
if grep "HAL9000" $PUMP_DATA_DIR/*.csv
then
    echo "CSV Pump test completed successfully.."
else
    echo "CSV pump test failed.."
    cleanup
    exit 1
fi

# Continue with the mongo test if csv pup has worked successfully.
# We export the analytics for a separate org (stmongo) to mongo.

# Generate mongo config

cat $DATA_DIR/api.authenabled.json |jq '.org_id="stmongo"|.name="pt2"|.slug="pt2"|.api_id="pt2"|.proxy.listen_path="/pt2/"' > $API_FILE

cat $DATA_DIR/key.json |jq '.org_id="stmongo"' > $KEY_FILE

# Add the API
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    -XPOST \
    --data @"$API_FILE" ${GWBASE}/tyk/apis

# Add a corresponding key
KEY=$(curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" -XPOST --data @"$KEY_FILE" ${GWBASE}/tyk/keys | jq -r '.key')


# Hot reload gateway
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    ${GWBASE}/tyk/reload/group

# Wait a while for reload
sleep 2


# Get the key from the previous step and access the API endpoint with the key and a custom user agent.
curl -v --header "Authorization: $KEY" \
    --header "User-Agent: HAL9000" "${GWBASE}/pt2/"

# Sleep a while till the record gets exported
sleep 10

# Test mongo
if mongoexport -h localhost:27017 -d tyk_analytics -c tyk_analytics --forceTableScan | grep "HAL9000"
then
    echo "Mongo pump test completed successfully.."
else
    echo "Mongo pump test failed.."
    cleanup
    exit 1
fi
cleanup
exit 0
