#!/usr/bin/env bash
EXTENSION=$1
BRANCH=$2
EXTDIR=$3

TAR_URL="https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/$EXTENSION/+archive/REL$BRANCH.tar.gz"
echo $TAR_URL
curl -s "$TAR_URL" -o "/tmp/$EXTENSION".tar.gz

mkdir -p $EXTDIR
tar -xzf /tmp/$EXTENSION.tar.gz -C $EXTDIR && \
    rm /tmp/$EXTENSION.tar.gz
