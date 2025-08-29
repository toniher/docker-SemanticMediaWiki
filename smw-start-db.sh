#!/usr/bin/env bash

VARS=${1:-.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

echo "Running Redis"

sed "s/{REDIS_CONTAINER}/$REDIS_CONTAINER/g" LocalSettings.redis.template >LocalSettings.redis.php
docker run --net=$NETWORK --name $REDIS_CONTAINER -d redis:$REDIS_TAG

echo "Running MariaDB"

ENTRYPOINT=""
if [ "$MW_NEW" = "true" ]; then
  ENTRYPOINT="-v $DB_DUMP:/docker-entrypoint-initdb.d/init.sql"
fi

docker run --name $DB_CONTAINER -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -v ${DB_LOCAL}:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf $ENTRYPOINT -p $PORT_DB:3306 -d mariadb:$MARIADB_TAG

for i in {1..3}; do
  if docker exec $REDIS_CONTAINER redis-cli ping | grep -q PONG; then
    break
  elif [ $i -lt 3 ]; then
    echo "Waiting for Redis server... ($i/3)"
    sleep 10
  else
    echo "Error: Redis server is not responding after $i attempts."
    exit 1
  fi
done

for i in {1..5}; do
  if docker exec $DB_CONTAINER mysqladmin ping -u root -p"$MYSQL_ROOT_PASSWORD" --silent | grep -q "alive"; then
    break
  elif [ $i -lt 5 ]; then
    echo "Waiting for MariaDB server... ($i/5)"
    sleep 20
  else
    echo "Error: MariaDB server is not responding after $i attempts."
    exit 1
  fi
done
