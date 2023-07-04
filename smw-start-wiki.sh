#!/usr/bin/env bash

VARS=${1:-vars.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

echo "Running wiki"

# SPECIFIC MOUNTS
LOCALSETTINGS_MOUNT=""
LOCALSETTINGS_LOCAL_MOUNT=""
LOCALSETTINGS_REDIS_MOUNT=""
LOGO_MOUNT=""
SCRATCH_MOUNT=""
CUSTOMIZATIONS_MOUNT=""
MSMTP_MOUNT=""

if [ ! $MW_NEW ]; then
	LOCALSETTINGS_MOUNT="-v ${CONF_PATH}/LocalSettings.php:/var/www/w/LocalSettings.php"
fi

if [ -f ${CONF_PATH}/LocalSettings.local.php ]; then
	LOCALSETTINGS_LOCAL_MOUNT="-v ${CONF_PATH}/LocalSettings.local.php:/var/www/w/LocalSettings.local.php"
fi

if [ -f ${CONF_PATH}/LocalSettings.redis.php ]; then
	LOCALSETTINGS_REDIS_MOUNT="-v ${CONF_PATH}/LocalSettings.redis.php:/var/www/w/LocalSettings.redis.php"
fi

if [ -f ${CONF_PATH}/LocalSettings.cirrus.php ]; then
	LOCALSETTINGS_CIRRUS_MOUNT="-v ${CONF_PATH}/LocalSettings.cirrus.php:/var/www/w/LocalSettings.cirrus.php"
fi

if [ -f ${CONF_PATH}/logo.png ]; then
	LOGO_MOUNT="-v ${CONF_PATH}/logo.png:/var/www/w/logo.png"
fi

if [ -d ${SCRATCH} ]; then
	SCRATCH_MOUNT="-v ${SCRATCH}:/scratch"
fi

if [ -d "${CONF_PATH}/customizations" ]; then
	CUSTOMIZATIONS_MOUNT="-v ${CONF_PATH}/customizations:/var/www/w/customizations"
fi

if [ -f "${CONF_PATH}/msmtprc" ]; then
	MSMTP_MOUNT="-v ${CONF_PATH}/msmtprc:/etc/msmtprc"
fi

docker run --net=$NETWORK -p $PORT:80 -v ${MW_IMAGES}:/var/www/w/images \
${LOCALSETTINGS_MOUNT} ${LOCALSETTINGS_LOCAL_MOUNT} ${LOCALSETTINGS_REDIS_MOUNT} ${LOCALSETTINGS_CIRRUS_MOUNT} \
${LOGO_MOUNT} \
${SCRATCH_MOUNT} \
${CUSTOMIZATIONS_MOUNT} \
${MSMTP_MOUNT} \
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

#bash updateEmail.sh $VARS
