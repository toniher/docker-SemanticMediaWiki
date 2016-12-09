#!/bin/sh

MEDIAWIKI_VERSION=1.23
MEDIAWIKI_FULL_VERSION=1.23.15
DOMAIN_NAME=mywiki
MYSQL_ROOT_PASSWORD=mediawiki
MYSQL_DATABASE=mediawiki
MYSQL_USER=mediawiki
MYSQL_PASSWORD=mediawiki
MYSQL_PREFIX=mw_
MW_PASSWORD=prova
MW_SCRIPTPATH=/w
MW_WIKINAME=MyWiki
MW_WIKIUSER=WikiSysop
MW_EMAIL=i@mywiki.com
PORT=10080

docker run --name db -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -v $(pwd)/data/db:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p 4306:3306 -d mariadb:10.1

MARIADB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' db`

echo $MARIADB_HOST


docker run -p $PORT:80 --name smw -d smw
