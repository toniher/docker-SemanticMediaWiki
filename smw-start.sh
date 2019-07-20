#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

docker run --net=$NETWORK --name $MARIADB_CONTAINER -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -v $(pwd)/data/db:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p $PORT_DB:3306 -d mariadb:10.1

docker run --net=$NETWORK -p $PORT:80 --name $WIKI_CONTAINER --network-alias=$DOMAIN_NAME -d smw

docker run --net=$NETWORK --name $PARSOID_CONTAINER -d -p 8142:8000 \
        -e PARSOID_DOMAIN_localhost=http://localhost/w/api.php \
        -e PARSOID_DOMAIN_localhost=http://$WIKI_CONTAINER/w/api.php \
        -e PARSOID_DOMAIN_localhost=http://$DOMAIN_NAME/w/api.php \
        thenets/parsoid:0.10

