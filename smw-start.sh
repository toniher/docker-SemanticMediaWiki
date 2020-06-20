#!/usr/bin/env bash

VARS=${1:-vars.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

bash smw-start-db.sh

docker network connect $NETWORK $DB_CONTAINER

bash smw-start-wiki.sh

