#!/usr/bin/env bash
EXTENSION=$1
BRANCH=$2
EXTDIR=$3

TAR_URL=$(curl -s "https://www.mediawiki.org/w/api.php?action=query&list=extdistbranches&edbexts=$EXTENSION&formatversion=2&format=json" | jq -r ".query.extdistbranches.extensions.$EXTENSION.REL$BRANCH")
echo $TAR_URL
curl -s "$TAR_URL" -o "/tmp/$EXTENSION".tar.gz

tar -xzf /tmp/$EXTENSION.tar.gz -C $EXTDIR && \
    rm /tmp/$EXTENSION.tar.gz

