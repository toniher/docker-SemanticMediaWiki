#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

echo "Running Redis"

docker run --net=$NETWORK --name $REDIS_CONTAINER -d redis:$REDIS_TAG

echo "Running MariaDB"

docker run --name $MARIADB_CONTAINER -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -v ${DB_LOCAL}:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p $PORT_DB:3306 -d mariadb:$MARIADB_TAG
