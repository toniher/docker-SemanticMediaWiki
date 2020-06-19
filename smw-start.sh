#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

bash smw-start-db.sh

docker network connect $NETWORK $DB_CONTAINER

bash smw-start-wiki.sh

