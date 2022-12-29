#!/usr/bin/env bash
EXTENSION=$1
RELEASE=$2
EXTDIR=$3

TAR_URL="https://github.com/wikimedia/mediawiki-extensions-$EXTENSION/archive/$RELEASE.tar.gz"
echo $TAR_URL
curl -L -s "$TAR_URL" -o "/tmp/$EXTENSION".tar.gz

mkdir -p $EXTDIR
tar -xzf /tmp/$EXTENSION.tar.gz -C $EXTDIR && \
    mv $EXTDIR/mediawiki-extensions-$EXTENSION-$RELEASE $EXTDIR/$EXTENSION && \
    rm /tmp/$EXTENSION.tar.gz
