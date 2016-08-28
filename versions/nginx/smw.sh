MARIADB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' db`
echo $MARIADB_HOST

docker build --build-arg MYSQL_DATABASE=mediawiki --build-arg MYSQL_USER=mediawiki --build-arg MYSQL_PASSWORD=mediawiki --build-arg MYSQL_HOST=$MARIADB_HOST --build-arg MYSQL_PREFIX=mw_ --build-arg MW_PASSWORD=prova --build-arg MW_SCRIPTPATH=/w --build-arg MW_WIKINAME=MyWiki --build-arg MW_WIKIUSER=WikiSysop -t smw  .


