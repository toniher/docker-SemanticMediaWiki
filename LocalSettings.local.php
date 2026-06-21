<?php

#  Local configuration for MediaWiki

ini_set( 'max_execution_time', 1000 );
ini_set('memory_limit', '-1');

$wgEnableUploads = true;

wfLoadExtension('ParserFunctions');
wfLoadExtension('WikiEditor');

$wgArticlePath = "/wiki/$1";

wfLoadExtension( 'CodeEditor' );
$wgDefaultUserOptions['usebetatoolbar'] = 1; // user option provided by WikiEditor extension

wfLoadExtension('VisualEditor');
$wgDefaultUserOptions['visualeditor-enable'] = 1;

wfLoadExtension( 'Bootstrap' );
wfLoadSkin( 'chameleon' );

$wgDefaultSkin='chameleon';

// SemanticMediaWiki — pass the wiki's public hostname (no scheme).
// Reads DOMAIN_NAME env var set on the container; falls back to 'localhost'.
enableSemantics( getenv('DOMAIN_NAME') ?: 'localhost' );
