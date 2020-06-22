#!/usr/bin/env bash

VARS=${1:-vars.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

docker network create $NETWORK --subnet $NETWORK_SUBNET

bash smw-start-db.sh $VARS

bash smw-build-wiki.sh $VARS

docker network connect $NETWORK $DB_CONTAINER

bash smw-start-wiki.sh $VARS

