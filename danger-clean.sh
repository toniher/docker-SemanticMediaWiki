#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

docker rm -f $DB_CONTAINER
docker rm -f $REDIS_CONTAINER
docker rm -f $PARSOID_CONTAINER
docker rm -f $WIKI_CONTAINER

docker network rm $NETWORK


