FROM toniher/nginx-php:nginx-1.16-php-7.3

ARG MEDIAWIKI_VERSION=1.31
ARG MEDIAWIKI_FULL_VERSION=1.31.7
ARG DB_CONTAINER=db
ARG PARSOID_CONTAINER=parsoid
ARG MYSQL_HOST=127.0.0.1
ARG MYSQL_DATABASE=mediawiki
ARG MYSQL_USER=mediawiki
ARG MYSQL_PASSWORD=mediawiki
ARG MYSQL_PREFIX=mw_
ARG MW_PASSWORD=prova
ARG MW_SCRIPTPATH=/w
ARG MW_WIKILANG=en
ARG MW_WIKINAME=Test
ARG MW_WIKIUSER=WikiSysop
ARG MW_EMAIL=hello@localhost
ARG DOMAIN_NAME=localhost
ARG PROTOCOL=http://
ARG MW_NEW=true

# Forcing Invalidate cache
ARG CACHE_INSTALL=2020-06-19

RUN set -x; \
    apt-get update && apt-get -y upgrade;
RUN set -x; \
    apt-get install -y gnupg jq php-redis;
RUN set -x; \
    rm -rf /var/lib/apt/lists/*

# Starting processes
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy helpers
COPY download-extension.sh /usr/local/bin/

COPY nginx-default.conf /etc/nginx/conf.d/default.conf
# Adding extra domain name
RUN sed -i "s/localhost/localhost $DOMAIN_NAME/" /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www/w; chown www-data:www-data /var/www/w
USER www-data

WORKDIR /tmp

ENV GNUPGHOME /tmp

# https://www.mediawiki.org/keys/keys.txt
RUN gpg --no-tty --fetch-keys "https://www.mediawiki.org/keys/keys.txt"

RUN MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz"; \
	set -x; \
	curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz \
	&& curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig \
	&& gpg --verify mediawiki.tar.gz.sig \
	&& tar -xf mediawiki.tar.gz -C /var/www/w --strip-components=1 \
	&& rm -f mediawiki*

COPY composer.local.json /var/www/w

RUN set -x; echo "Host is $MYSQL_HOST"

RUN if [ "$MW_NEW" = "true" ] ; then cd /var/www/w; php maintenance/install.php \
		--dbname "$MYSQL_DATABASE" \
		--dbpass "$MYSQL_PASSWORD" \
		--dbserver "$MYSQL_HOST" \
		--dbtype mysql \
		--dbprefix "$MYSQL_PREFIX" \
		--dbuser "$MYSQL_USER" \
		--installdbpass "$MYSQL_PASSWORD" \
		--installdbuser "$MYSQL_USER" \
		--pass "$MW_PASSWORD" \
		--scriptpath "$MW_SCRIPTPATH" \
		--lang "$MW_WIKILANG" \
"${MW_WIKINAME}" "${MW_WIKIUSER}" ; fi

# VisualEditor extension
RUN ENVEXT=$MEDIAWIKI_VERSION && ENVEXT=$(echo $ENVEXT | sed -r "s/\./_/g") && bash /usr/local/bin/download-extension.sh VisualEditor $ENVEXT /var/www/w/extensions


# Addding extra stuff to LocalSettings. Only if new installation
RUN if [ "$MW_NEW" = "true" ] ; then echo "\n\
enableSemantics( '${DOMAIN_NAME}' );\n " >> /var/www/w/LocalSettings.php ; fi

RUN cd /var/www/w; composer update --no-dev;

RUN cd /var/www/w; php maintenance/update.php

# Update Semantic MediaWiki
RUN cd /var/www/w; php extensions/SemanticMediaWiki/maintenance/rebuildData.php -ftpv
RUN cd /var/www/w; php extensions/SemanticMediaWiki/maintenance/rebuildData.php -v

RUN cd /var/www/w; php maintenance/runJobs.php

RUN sed -i "s/$MYSQL_HOST/$DB_CONTAINER/" /var/www/w/LocalSettings.php 

# Volume LocalSettings.local.php
VOLUME /var/www/w/LocalSettings.local.php
RUN if [ "$MW_NEW" = "true" ] ; then echo "\n\
include_once \"\$IP/LocalSettings.local.php\"; " >> /var/www/w/LocalSettings.php ; fi

# Redis configuration
# Volume LocalSettings.redis.php
VOLUME /var/www/w/LocalSettings.redis.php

# Adding redis config. Only if new installation
RUN if [ "$MW_NEW" = "true" ] ;  then echo "\n\
include_once \"\$IP/LocalSettings.redis.php\"; " >> /var/www/w/LocalSettings.php ; fi

# VOLUME image
VOLUME /var/www/w/images

WORKDIR /var/www/w

USER root
RUN mkdir -p /run/php

CMD ["/usr/bin/supervisord"]


