#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' vars.env)

bash smw-start-db.sh

bash smw-start-wiki.sh

