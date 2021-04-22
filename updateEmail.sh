#!/bin/bash

VARS=${1:-vars.env}

source <(sed -E -n 's/[^#]+/export &/ p' $VARS)

mysql -u${MYSQL_USER} -P${PORT_DB} -p${MYSQL_PASSWORD} -h${MARIADB_HOST:-0.0.0.0} ${MYSQL_DATABASE} -e "update mw_user set user_email=\"${MW_EMAIL}\" where user_name=\"${MW_WIKIUSER}\"; "

