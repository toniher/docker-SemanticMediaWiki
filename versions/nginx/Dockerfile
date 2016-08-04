FROM nginx:1.10

# To be changed here
ENV MEDIAWIKI_VERSION 1.27
ENV MEDIAWIKI_FULL_VERSION 1.27.0

RUN set -x; \
	gpg --keyserver keys.gnupg.net --recv-key 89DF5277 \
	&& gpg -a --export 89DF5277 | apt-key add - \
	&& echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list \

RUN set -x; \
	&& apt-get update \
	apt-get install -y nginx php7.0 php7.0-fpm php7.0-gd php7.0-mysql php7.0-cli php7.0-common php7.0-curl php7.0-opcache php7.0-json php7.0-intl \
	&& rm -rf /var/lib/apt/lists/*

RUN set -x; \
	apt-get update \
	&& apt-get install -y --no-install-recommends \
		g++ \
		libicu52 \
		libicu-dev \
	&& apt-get purge -y --auto-remove g++ libicu-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN set -x; \
	apt-get update \
	&& apt-get install -y --no-install-recommends imagemagick \
	&& rm -rf /var/lib/apt/lists/*

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

