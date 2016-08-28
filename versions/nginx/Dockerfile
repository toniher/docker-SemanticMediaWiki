FROM nginx:1.10

# To be changed here
ENV MEDIAWIKI_VERSION 1.27
ENV MEDIAWIKI_FULL_VERSION 1.27.1
ARG MYSQL_DATABASE=mediawiki
ARG MYSQL_USER=mediawiki
ARG MYSQL_PASSWORD=mediawiki
ARG MYSQL_HOST=127.0.0.1
ARG MYSQL_PREFIX=mw_
ARG MW_PASSWORD=prova
ARG MW_SCRIPTPATH=/W
ARG MW_WIKILANG=en
ARG MW_WIKINAME=MyWiki
ARG MW_WIKIUSER=WikiSysop

RUN set -x; \
	gpg --keyserver keys.gnupg.net --recv-key 89DF5277 \
	&& gpg -a --export 89DF5277 | apt-key add - \
	&& echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list

RUN set -x; \
	apt-get update && \
	apt-get install -y nginx php7.0 php7.0-fpm php7.0-gd php7.0-mysql php7.0-cli php7.0-common php7.0-curl php7.0-opcache php7.0-json php7.0-intl php7.0-mbstring php7.0-xml \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libpng12-dev \
	libbz2-dev \
	libxslt-dev \
	libldap2-dev \
	imagemagick \
	curl \
	git \
	subversion \
	unzip \
	wget

RUN set -x; \
	rm -rf /var/lib/apt/lists/*

# Using www-data user
RUN sed -i 's/user  nginx/user  www-data/g' /etc/nginx/nginx.conf

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=1.2.0 && rm -rf /tmp/composer-setup.php

# https://www.mediawiki.org/keys/keys.txt
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
	441276E9CCD15F44F6D97D18C119E1A64D70938E \
	41B2ABE817ADD3E52BDA946F72BC1C5D23107F8A \
	162432D9E81C1C618B301EECEE1F663462D84F01 \
	1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
	3CEF8262806D3F0B6BA1DBDD7956EE477F901A30 \
	280DB7845A1DCAC92BB5A00A946B02565DC00AA7

RUN MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz"; \
	set -x; \
	mkdir -p /usr/src/mediawiki \
	&& curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz \
	&& curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig \
	&& gpg --verify mediawiki.tar.gz.sig \
	&& tar -xf mediawiki.tar.gz -C /usr/src/mediawiki --strip-components=1

COPY composer.local.json /usr/src/mediawiki

RUN set -x; echo "${MYSQL_HOST}"

RUN cd /usr/src/mediawiki; php maintenance/install.php \
		--dbname "$MYSQL_DATABASE" \
		--dbpass "$MYSQL_PASSWORD" \
		--dbserver "$MYSQL_HOST" \
		--dbtype mysql \
		--dbprefix "$MYSQL_PREFIX" \
		--dbuser "$MYSQL_USER" \
		--email mediawiki@localhost \
		--installdbpass "$MYSQL_PASSWORD" \
		--installdbuser "$MYSQL_USER" \
		--pass "$MW_PASSWORD" \
		--scriptpath "$MW_SCRIPTPATH" \
		--lang "$MW_WIKILANG" \
	"$MW_WIKINAME" "$MW_WIKIUSER"


RUN cd /usr/src/mediawiki; composer update --no-dev;

COPY nginx-default.conf /etc/nginx/conf.d/default.conf

