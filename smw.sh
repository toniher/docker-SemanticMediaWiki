#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

docker network create $NETWORK --subnet $NETWORK_SUBNET

bash smw-start-db.sh

bash smw-build-wiki.sh

docker network connect $NETWORK $MARIADB_CONTAINER

bash smw-start-wiki.sh

