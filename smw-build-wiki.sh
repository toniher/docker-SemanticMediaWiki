#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

# Moving this outside in case needed
MARIADB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $MARIADB_CONTAINER`
CACHE_INSTALL=`date +%Y-%m-%d-%H-%M`

echo $MARIADB_HOST
echo $CACHE_INSTALL

echo "Building wiki"

docker build --no-cache --build-arg DB_CONTAINER=$DB_CONTAINER --build-arg PARSOID_CONTAINER=$PARSOID_CONTAINER --build-arg DOMAIN_NAME=$DOMAIN_NAME --build-arg MW_EMAIL=$MW_EMAIL --build-arg MEDIAWIKI_VERSION=$MEDIAWIKI_VERSION --build-arg MEDIAWIKI_FULL_VERSION=$MEDIAWIKI_FULL_VERSION --build-arg MYSQL_DATABASE=$MYSQL_DATABASE --build-arg MYSQL_USER=$MYSQL_USER --build-arg MYSQL_PASSWORD=$MYSQL_PASSWORD --build-arg MYSQL_HOST=$MARIADB_HOST --build-arg MYSQL_PREFIX=$MYSQL_PREFIX --build-arg MW_PASSWORD=$MW_PASSWORD --build-arg MW_SCRIPTPATH=$MW_SCRIPTPATH --build-arg MW_WIKINAME=$MW_WIKINAME --build-arg MW_WIKIUSER=$MW_WIKIUSER --build-arg CACHE_INSTALL=$CACHE_INSTALL -t $WIKI_IMAGE  .

