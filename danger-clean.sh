#!/usr/bin/env bash

VARS=${1:-.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

read -p "Are you sure you want to remove the DB container ($DB_CONTAINER)? [y/N] " confirm && [ "$confirm" = "y" ] && docker rm -f $DB_CONTAINER
read -p "Are you sure you want to remove the Redis container ($REDIS_CONTAINER)? [y/N] " confirm && [ "$confirm" = "y" ] && docker rm -f $REDIS_CONTAINER
# read -p "Are you sure you want to remove the Parsoid container ($PARSOID_CONTAINER)? [y/N] " confirm && [ "$confirm" = "y" ] && docker rm -f $PARSOID_CONTAINER
read -p "Are you sure you want to remove the Wiki container ($WIKI_CONTAINER)? [y/N] " confirm && [ "$confirm" = "y" ] && docker rm -f $WIKI_CONTAINER

read -p "Are you sure you want to remove the Docker network ($NETWORK)? [y/N] " confirm && [ "$confirm" = "y" ] && docker network rm $NETWORK
