docker pull mariadb:10.1
docker run --name db -e MYSQL_ROOT_PASSWORD=mediawiki -e MYSQL_DATABASE=mediawiki -e MYSQL_USER=mediawiki -e MYSQL_PASSWORD=mediawiki -v $(pwd)/data/db:/var/lib/mysql -v $(pwd)/mariadb-custom.cnf:/etc/mysql/conf.d/custom.cnf -p 4306:3306 -d mariadb:10.1


