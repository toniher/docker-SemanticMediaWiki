#!/usr/bin/env bash

VARS=${1:-.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

docker network create $NETWORK --subnet $NETWORK_SUBNET

if [ "$MW_FULL" = "true" ]; then
  bash smw-start-db.sh $VARS
fi

bash smw-build-wiki.sh $VARS

if [ "$MW_FULL" = "true" ]; then
  docker network connect $NETWORK $DB_CONTAINER
  docker network connect $NETWORK $REDIS_CONTAINER
fi

bash smw-start-wiki.sh $VARS
