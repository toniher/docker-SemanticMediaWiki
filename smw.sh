#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

docker network create $NETWORK

docker pull mariadb:$MARIADB_TAG
docker run --name $MARIADB_CONTAINER -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -v $(pwd)/data/db:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p $PORT_DB:3306 -d mariadb:$MARIADB_TAG

MARIADB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $MARIADB_CONTAINER`
CACHE_INSTALL=`date +%Y-%m-%d-%H-%M`

echo $MARIADB_HOST
echo $CACHE_INSTALL

docker build --no-cache --build-arg DB_CONTAINER=$DB_CONTAINER --build-arg PARSOID_CONTAINER=$PARSOID_CONTAINER --build-arg DOMAIN_NAME=$DOMAIN_NAME --build-arg MW_EMAIL=$MW_EMAIL --build-arg MEDIAWIKI_VERSION=$MEDIAWIKI_VERSION --build-arg MEDIAWIKI_FULL_VERSION=$MEDIAWIKI_FULL_VERSION --build-arg MYSQL_DATABASE=$MYSQL_DATABASE --build-arg MYSQL_USER=$MYSQL_USER --build-arg MYSQL_PASSWORD=$MYSQL_PASSWORD --build-arg MYSQL_HOST=$MARIADB_HOST --build-arg MYSQL_PREFIX=$MYSQL_PREFIX --build-arg MW_PASSWORD=$MW_PASSWORD --build-arg MW_SCRIPTPATH=$MW_SCRIPTPATH --build-arg MW_WIKINAME=$MW_WIKINAME --build-arg MW_WIKIUSER=$MW_WIKIUSER --build-arg CACHE_INSTALL=$CACHE_INSTALL -t smw  .

docker network connect $NETWORK $MARIADB_CONTAINER

docker run --net=$NETWORK -p $PORT:80 --name $WIKI_CONTAINER --network-alias=$DOMAIN_NAME -d smw

docker run --net=$NETWORK --name $PARSOID_CONTAINER -d -p 8142:8000 \
	-e PARSOID_DOMAIN_localhost=http://localhost/w/api.php \
	-e PARSOID_DOMAIN_localhost=http://$WIKI_CONTAINER/w/api.php \
	-e PARSOID_DOMAIN_localhost=http://$DOMAIN_NAME/w/api.php \
	thenets/parsoid:0.10

