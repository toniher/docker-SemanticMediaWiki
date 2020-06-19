#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

echo "Running wiki"

LOCALSETTINGS_MOUNT=""

if [ ! $MW_NEW ]; then 
	LOCALSETTINGS_MOUNT="-v ${CONF_PATH}/LocalSettings.php:/var/www/w/LocalSettings.php"
fi

docker run --net=$NETWORK -p $PORT:80 -v ${MW_IMAGES}:/var/www/w/images \
${LOCALSETTINGS_MOUNT} -v ${CONF_PATH}/LocalSettings.local.php:/var/www/w/LocalSettings.local.php -v ${CONF_PATH}/LocalSettings.redis.php:/var/www/w/LocalSettings.redis.php \
--name $WIKI_CONTAINER --network-alias=$DOMAIN_NAME -d $WIKI_IMAGE


echo "Running parsoid"

docker run --net=$NETWORK --name $PARSOID_CONTAINER -d -p 8142:8000 \
        -e PARSOID_DOMAIN_localhost=http://localhost/w/api.php \
        -e PARSOID_DOMAIN_localhost=http://$WIKI_CONTAINER/w/api.php \
        -e PARSOID_DOMAIN_localhost=http://$DOMAIN_NAME/w/api.php \
        thenets/parsoid:$PARSOID_TAG

# Maintenance tasks wiki
docker exec $WIKI_CONTAINER php /var/www/w/maintenance/update.php
docker exec $WIKI_CONTAINER php /var/www/w/maintenance/runJobs.php

