#!/bin/sh

MEDIAWIKI_VERSION=1.27
MEDIAWIKI_FULL_VERSION=1.27.1
DOMAIN_NAME=mywiki
MYSQL_DATABASE=mediawiki
MYSQL_USER=mediawiki
MYSQL_PASSWORD=mediawiki
MYSQL_PREFIX=mw_
MW_PASSWORD=prova
MW_SCRIPTPATH=/w
MW_WIKINAME=MyWiki
MW_WIKIUSER=WikiSysop

docker pull mariadb:10.1
docker run --name db -e MYSQL_ROOT_PASSWORD=mediawiki -e MYSQL_DATABASE=mediawiki -e MYSQL_USER=mediawiki -e MYSQL_PASSWORD=mediawiki -v $(pwd)/data/db:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p 4306:3306 -d mariadb:10.1

MARIADB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' db`

docker build --build-arg DOMAIN_NAME=$DOMAIN_NAME --build-arg MEDIAWIKI_VERSION=$MEDIAWIKI_VERSION --build-arg MEDIAWIKI_FULL_VERSION=$MEDIAWIKI_FULL_VERSION --build-arg MYSQL_DATABASE=$MYSQL_DATABASE --build-arg MYSQL_USER=$MYSQL_USER --build-arg MYSQL_PASSWORD=$MYSQL_PASSWORD --build-arg MYSQL_HOST=$MARIADB_HOST --build-arg MYSQL_PREFIX=$MYSQL_PREFIX --build-arg MW_PASSWORD=$MW_PASSWORD --build-arg MW_SCRIPTPATH=$MW_SCRIPTPATH --build-arg MW_WIKINAME=$MW_WIKINAME --build-arg MW_WIKIUSER=$MW_WIKIUSER -t smw  .


