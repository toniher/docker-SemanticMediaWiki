#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

docker network create $NETWORK --subnet $NETWORK_SUBNET

bash smw-start-db.sh

bash smw-build-wiki.sh

docker network connect $NETWORK $DB_CONTAINER

bash smw-start-wiki.sh

