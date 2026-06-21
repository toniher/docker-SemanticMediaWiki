# syntax=docker/dockerfile:1.6
#
# docker-SemanticMediaWiki — stateless build.
#
# This image bakes only OS packages, MediaWiki source, and composer dependencies.
# Database installation, schema updates, and LocalSettings.php generation happen
# at run time via docker-entrypoint.sh.

FROM toniher/nginx-php:nginx-1.29-php-8.4-sury

ARG MEDIAWIKI_VERSION=1.43
ARG MEDIAWIKI_FULL_VERSION=1.43.8
ARG DB_CONTAINER=db
ARG DOMAIN_NAME=localhost

# OS packages (single layer, no `apt-get upgrade`)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gnupg \
        jq \
        php8.4-redis \
        php8.4-zip; \
    rm -rf /var/lib/apt/lists/*

# Supervisor and nginx config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
RUN sed -i "s/localhost/localhost $DOMAIN_NAME/" /etc/nginx/conf.d/default.conf

# Extension / skin download helpers
COPY download-extension.sh /usr/local/bin/
COPY download-extension-git.sh /usr/local/bin/
COPY download-extension-github.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/download-extension.sh \
             /usr/local/bin/download-extension-git.sh \
             /usr/local/bin/download-extension-github.sh

# Wiki working directory + php-fpm runtime dir
RUN set -eux; \
    mkdir -p /var/www/w /run/php; \
    chown www-data:www-data /var/www/w

USER www-data
WORKDIR /tmp
ENV GNUPGHOME=/tmp

# MediaWiki release (signature verified against the upstream keyring)
RUN set -eux; \
    curl -fsSL -o /tmp/mediawiki-keys.txt https://www.mediawiki.org/keys/keys.txt; \
    gpg --no-tty --import /tmp/mediawiki-keys.txt; \
    rm /tmp/mediawiki-keys.txt; \
    MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_VERSION}/mediawiki-${MEDIAWIKI_FULL_VERSION}.tar.gz"; \
    curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz; \
    curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig; \
    gpg --verify mediawiki.tar.gz.sig; \
    tar -xf mediawiki.tar.gz -C /var/www/w --strip-components=1; \
    rm -f mediawiki*

WORKDIR /var/www/w

# Composer-managed extensions. Commit composer.lock for reproducible installs.
# Generate one with:
#   docker run --rm -v $(pwd):/work -w /work composer:2 \
#       composer update --no-dev --no-interaction --prefer-dist
COPY --chown=www-data:www-data composer.local.json /var/www/w/composer.local.json
COPY --chown=www-data:www-data composer.loc[k] /var/www/w/composer.lock

RUN set -eux; \
    if [ -s composer.lock ]; then \
        composer install --no-dev --no-interaction --prefer-dist; \
    else \
        echo "WARNING: composer.lock is missing; falling back to composer update." >&2; \
        composer update --no-dev --no-interaction --prefer-dist; \
    fi

USER root

# Runtime entrypoint: installs / updates MediaWiki against the linked DB,
# then exec's the CMD (supervisord -> nginx + php-fpm).
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Uploaded files live on a named volume; LocalSettings.php is persisted on
# a separate volume populated by the entrypoint on first boot.
VOLUME /var/www/w/images
VOLUME /var/www/w/config

WORKDIR /var/www/w

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsS "http://localhost/w/api.php?action=query&format=json" >/dev/null || exit 1
