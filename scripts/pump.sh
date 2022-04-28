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

API_FILE=/tmp/api.pt2.json
KEY_FILE=/tmp/key.pt2.json
GWBASE=$1

cleanup() {
    rm -f /tmp/pump-data/*.csv
    rm -f $KEY_FILE $API_FILE
}

# Add the test API - keyless APIs is not getting exported when pump is run.
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    -XPOST --data @data/api.authenabled.json ${GWBASE}/tyk/apis

# Add a corresponding key
KEY=$(curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" -XPOST --data @data/key.json ${GWBASE}/tyk/keys | jq -r '.key')

# Hot reload gateway
curlf --header "x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7" \
    ${GWBASE}/tyk/reload/group

# Wait a while for reload
sleep 2

# Get the key from the previous step and access the API endpoint with the key and a custom user agent.
curl -v --header "Authorization: $KEY" --header "User-Agent: HAL9000" \
    "${GWBASE}/test/"

# Sleep a while till the record gets exported
sleep 10

# Search for our custom  user agent in the csv file.
if grep "HAL9000" /tmp/pump-data/*.csv
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

cat data/api.authenabled.json |jq '.org_id="stmongo"|.name="pt2"|.slug="pt2"|.api_id="pt2"|.proxy.listen_path="/pt2/"' > $API_FILE

cat data/key.json |jq '.org_id="stmongo"' > $KEY_FILE

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
