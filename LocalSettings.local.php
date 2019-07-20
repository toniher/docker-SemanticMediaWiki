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
$wgVirtualRestConfig['modules']['parsoid'] = array(
    'url' => 'http://parsoid:8000',
    'domain' => 'localhost',
    'prefix' => ''
);
$wgSessionsInObjectCache = true;
$wgVirtualRestConfig['modules']['parsoid']['forwardCookies'] = true;
