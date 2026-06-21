#!/bin/sh
# Runtime entrypoint for the docker-SemanticMediaWiki image.
#
# On first boot (LocalSettings.php absent on the config volume):
#   - waits for the DB to accept connections,
#   - runs maintenance/install.php,
#   - moves the generated LocalSettings.php onto the config volume,
#   - appends include_once lines for each bind-mounted LocalSettings.*.php.
#
# On every boot (including first):
#   - runs maintenance/update.php --quick so schema changes apply when the
#     image is upgraded.
#   - runs SMW rebuildData.php once (marker $CONFIG_DIR/.smw-rebuilt guards
#     subsequent boots). Delete the marker to force a re-run.
#
# Then exec's the CMD (supervisord -> nginx + php-fpm).
set -eu

CONFIG_DIR=/var/www/w/config
LOCAL_SETTINGS="$CONFIG_DIR/LocalSettings.php"
WIKI_DIR=/var/www/w

mkdir -p "$CONFIG_DIR"
chown www-data:www-data "$CONFIG_DIR"

# If a LocalSettings.php already exists on the config volume, expose it at the
# canonical $IP location via a symlink (idempotent).
if [ -f "$LOCAL_SETTINGS" ] && [ ! -e "$WIKI_DIR/LocalSettings.php" ]; then
  ln -sf "$LOCAL_SETTINGS" "$WIKI_DIR/LocalSettings.php"
fi

wait_for_db() {
  [ -n "${MYSQL_HOST:-}" ] || return 0
  echo "Waiting for ${MYSQL_HOST} to accept connections..."
  i=0
  until php -r "new PDO('mysql:host=${MYSQL_HOST};dbname=${MYSQL_DATABASE}','${MYSQL_USER}','${MYSQL_PASSWORD}');" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -gt 60 ]; then
      echo "Timed out waiting for ${MYSQL_HOST}" >&2
      exit 1
    fi
    sleep 2
  done
  echo "${MYSQL_HOST} is up."
}

run_install() {
  echo "No LocalSettings.php found; running maintenance/install.php"
  cd "$WIKI_DIR"
  runuser -u www-data -- php maintenance/install.php \
    --dbname "$MYSQL_DATABASE" \
    --dbpass "$MYSQL_PASSWORD" \
    --dbserver "$MYSQL_HOST" \
    --dbtype mysql \
    --dbprefix "${MYSQL_PREFIX:-mw_}" \
    --dbuser "$MYSQL_USER" \
    --installdbpass "$MYSQL_PASSWORD" \
    --installdbuser "$MYSQL_USER" \
    --pass "$MW_PASSWORD" \
    --scriptpath "${MW_SCRIPTPATH:-/w}" \
    --lang "${MW_WIKILANG:-en}" \
    "$MW_WIKINAME" "$MW_WIKIUSER"

  mv "$WIKI_DIR/LocalSettings.php" "$LOCAL_SETTINGS"
  ln -sf "$LOCAL_SETTINGS" "$WIKI_DIR/LocalSettings.php"

  # Append include_once lines for every layered config that's bind-mounted in.
  for f in LocalSettings.local.php LocalSettings.redis.php; do
    if [ -f "$WIKI_DIR/$f" ]; then
      echo "include_once \"\$IP/$f\";" >>"$LOCAL_SETTINGS"
    fi
  done

  chown www-data:www-data "$LOCAL_SETTINGS"
}

run_update() {
  echo "Running maintenance/update.php --quick"
  cd "$WIKI_DIR"
  runuser -u www-data -- php maintenance/update.php --quick
}

# Rebuilds SMW's semantic data store. Runs once automatically (guarded by a
# marker file); delete $CONFIG_DIR/.smw-rebuilt to force a re-run (e.g. after
# enabling SMW on an existing wiki or changing smwgNamespacesWithSemanticLinks).
# No-ops silently when SemanticMediaWiki is not installed in the image.
run_smw_rebuild() {
  local script="$WIKI_DIR/extensions/SemanticMediaWiki/maintenance/rebuildData.php"
  [ -f "$script" ] || return 0
  if [ -f "$CONFIG_DIR/.smw-rebuilt" ]; then
    echo "SMW data already rebuilt (marker exists); skipping."
    return 0
  fi
  echo "Rebuilding SMW semantic data store..."
  cd "$WIKI_DIR"
  runuser -u www-data -- php "$script" --quiet
  touch "$CONFIG_DIR/.smw-rebuilt"
  chown www-data:www-data "$CONFIG_DIR/.smw-rebuilt"
}

# Only manage MediaWiki state when DB env is present. This lets the image be
# used for ad-hoc maintenance shells (`docker run --rm ... bash`) without
# triggering install/update.
if [ -n "${MYSQL_HOST:-}" ]; then
  wait_for_db
  if [ ! -f "$LOCAL_SETTINGS" ]; then
    run_install
    run_update
    run_smw_rebuild
  else
    run_update
    run_smw_rebuild
  fi
fi

chown -R www-data:www-data "$WIKI_DIR/images" "$CONFIG_DIR" 2>/dev/null || true

exec "$@"
