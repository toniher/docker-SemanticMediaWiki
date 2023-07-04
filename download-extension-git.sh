#!/usr/bin/env bash
EXTENSION=$1
TARGET=$2
OUTDIR=$3
TAG=${4:-0}
SKIN=${5:-0}
TYPEDIR=${6:-extensions}

OUT="REL$TARGET"
if [ "$TAG" = "1" ]; then
  OUT=$TARGET
fi

if [ "$SKIN" = "1" ]; then
  TYPEDIR=skins
fi

TAR_URL="https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/$TYPEDIR/$EXTENSION/+archive/$OUT.tar.gz"
echo $TAR_URL
curl -s "$TAR_URL" -o "/tmp/$EXTENSION".tar.gz

mkdir -p $OUTDIR
tar -xzf /tmp/$EXTENSION.tar.gz -C $OUTDIR && \
  rm /tmp/$EXTENSION.tar.gz

