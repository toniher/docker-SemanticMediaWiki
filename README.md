# docker-SemanticMediaWiki

A Docker-based MediaWiki setup with Semantic MediaWiki and the Chameleon skin.

| Component | Version |
|---|---|
| MediaWiki | 1.43.x |
| Semantic MediaWiki | 6.0.1 |
| Chameleon skin | 5.0.3 |
| PHP | 8.4 |
| MariaDB | 10.11 |

## Architecture

The image is a **stateless build** — no database connection is needed at build time. `docker-entrypoint.sh` handles all runtime state:

- **First boot**: waits for the DB, runs `maintenance/install.php`, writes `LocalSettings.php` to a persistent config volume, appends `include_once` lines for the layered config files.
- **Every boot**: runs `maintenance/update.php --quick` (schema migrations on upgrade), then a one-time `SMW rebuildData.php` (guarded by a marker file; delete `config/.smw-rebuilt` to force a re-run).

Configuration is layered via bind-mounted PHP files:

| File | Purpose |
|---|---|
| `LocalSettings.local.php` | Core extensions, Chameleon skin, `enableSemantics()` |
| `LocalSettings.redis.php` | Object cache / session store |

## Prerequisites

- Docker Engine 24+ with the Compose plugin (`docker compose version`)
- (Production) a pre-created Docker network matching `NETWORK` in `.env`

## Quick start (development)

```bash
git clone <repo>
cd docker-SemanticMediaWiki.mw-1.43-smw-6.0

cp example.env .env
# Edit .env — at minimum set MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MW_PASSWORD

docker compose up --build
```

The wiki will be available at `http://localhost:10081/wiki/Main_Page` once the healthcheck passes (adjust the port if you changed `PORT` in `.env`). First boot takes a minute while the entrypoint installs MediaWiki.

## Configuration

All tuneable variables live in `.env` (copy from `example.env`):

| Variable | Default | Description |
|---|---|---|
| `MEDIAWIKI_VERSION` | `1.43` | MW minor version (build arg) |
| `MEDIAWIKI_FULL_VERSION` | `1.43.8` | MW patch version (build arg) |
| `DOMAIN_NAME` | `localhost` | Public hostname, no scheme |
| `NETWORK` | `smwnet` | Docker network name |
| `MARIADB_TAG` | `10.11` | MariaDB image tag |
| `REDIS_TAG` | `8` | Valkey image tag |
| `MYSQL_ROOT_PASSWORD` | — | **Set this** |
| `MYSQL_DATABASE` | `mediawiki` | DB name |
| `MYSQL_USER` | `mediawiki` | DB user |
| `MYSQL_PASSWORD` | — | **Set this** |
| `MYSQL_PREFIX` | `mw_` | Table prefix |
| `MW_PASSWORD` | — | **Set this** (admin password) |
| `MW_SCRIPTPATH` | `/w` | MediaWiki script path |
| `MW_WIKINAME` | `MyWiki` | Wiki name |
| `MW_WIKIUSER` | `WikiSysop` | Admin username |
| `MW_EMAIL` | `admin@example.com` | Admin e-mail |
| `MW_WIKILANG` | `en` | Wiki language |
| `PORT` | `10081` | Host port |

## Production deployment

Add the bind-mount paths to `.env`:

```dotenv
DB_DATA_DIR=/srv/smw/db
MW_IMAGES_DIR=/srv/smw/images
```

Create the external network if it does not exist:

```bash
docker network create smwnet
```

Then deploy with both compose files:

```bash
docker compose -f compose.yaml -f compose.prod.yaml up --build -d
```

`compose.prod.yaml` overrides the named volumes with host bind mounts and marks the network as external so compose does not try to manage it.

## Useful commands

```bash
# Rebuild the wiki image only
docker compose build wiki

# Follow entrypoint logs on first boot
docker compose logs -f wiki

# Run a maintenance script
docker compose exec wiki php maintenance/runJobs.php

# Force SMW data rebuild on next boot
docker compose exec wiki rm config/.smw-rebuilt
docker compose restart wiki

# Stop and remove containers (keep volumes)
docker compose down

# Stop and remove containers AND volumes (destructive — wipes DB and wiki data)
docker compose down -v
```

## Upgrading MediaWiki or SMW

1. Update `MEDIAWIKI_FULL_VERSION` (and `mediawiki/semantic-media-wiki` in `composer.local.json`) in your `.env` / source files.
2. Rebuild: `docker compose build wiki`
3. Restart: `docker compose up -d wiki`

The entrypoint runs `maintenance/update.php --quick` on every boot, so schema migrations apply automatically.

## Composer lock file

Commit `composer.lock` for reproducible builds. If it is absent the image falls back to `composer update` and logs a warning. To regenerate it:

```bash
docker run --rm -v "$(pwd):/work" -w /work composer:2 \
    composer update --no-dev --no-interaction --prefer-dist
```
