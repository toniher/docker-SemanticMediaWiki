#!/bin/bash

VARS=${1:-vars.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MARIADB_HOST} ${MYSQL_DATABASE} -e "update mw_user set user_email=\"${MW_EMAIL}\" where user_name=\"${MW_WIKIUSER}\"; "

