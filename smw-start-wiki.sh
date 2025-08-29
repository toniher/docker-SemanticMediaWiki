#!/usr/bin/env bash

VARS=${1:-.env}
FORCE=${2:-0}

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

if [ ! $MW_NEW = "true" ]; then
  LOCALSETTINGS_MOUNT="-v ${CONF_PATH}/LocalSettings.php:/var/www/w/LocalSettings.php"
fi

if [ -f ${CONF_PATH}/LocalSettings.local.php ]; then
  LOCALSETTINGS_LOCAL_MOUNT="-v ${CONF_PATH}/LocalSettings.local.php:/var/www/w/LocalSettings.local.php"
fi

if [ -f ${CONF_PATH}/LocalSettings.redis.php ]; then
  LOCALSETTINGS_REDIS_MOUNT="-v ${CONF_PATH}/LocalSettings.redis.php:/var/www/w/LocalSettings.redis.php"
fi

if [ -f ${CONF_PATH}/logo.png ]; then
  LOGO_MOUNT="-v ${CONF_PATH}/logo.png:/var/www/w/logo.png"
fi

if [ -n "${SCRATCH}" ] && [ -d "${SCRATCH}" ]; then
  SCRATCH_MOUNT="-v ${SCRATCH}:/scratch"
fi

if [ -d "${CONF_PATH}/customizations" ]; then
  CUSTOMIZATIONS_MOUNT="-v ${CONF_PATH}/customizations:/var/www/w/customizations"
fi

if [ -f "${CONF_PATH}/msmtprc" ]; then
  MSMTP_MOUNT="-v ${CONF_PATH}/msmtprc:/etc/msmtprc"
fi

if [[ $FORCE -eq 1 ]]; then
  docker rm -f $WIKI_CONTAINER
fi

docker run --net=$NETWORK -p $PORT:80 -v ${MW_IMAGES}:/var/www/w/images \
  ${LOCALSETTINGS_MOUNT} ${LOCALSETTINGS_LOCAL_MOUNT} ${LOCALSETTINGS_REDIS_MOUNT} \
  ${LOGO_MOUNT} \
  ${SCRATCH_MOUNT} \
  ${CUSTOMIZATIONS_MOUNT} \
  ${MSMTP_MOUNT} \
  --name $WIKI_CONTAINER --network-alias=$DOMAIN_NAME -d $WIKI_IMAGE

# Maintenance tasks wiki
docker exec $WIKI_CONTAINER php /var/www/w/maintenance/update.php
docker exec $WIKI_CONTAINER php /var/www/w/maintenance/runJobs.php

#bash updateEmail.sh $VARS
echo "Checking SMW API endpoint..."
SMWINFO_JSON=$(curl -s "http://localhost:$PORT/w/api.php?action=smwinfo&format=json")
if echo "$SMWINFO_JSON" | jq -e '.info.propcount' >/dev/null 2>&1; then
  echo "SMW API endpoint is OK."
else
  echo "SMW API endpoint check FAILED."
  exit 1
fi
