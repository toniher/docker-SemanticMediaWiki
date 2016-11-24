<?php

#  Local configuration for MediaWiki

ini_set( 'max_execution_time', 1000 );
ini_set('memory_limit', '-1'); 

$wgEnableUploads = true;

wfLoadExtension('ParserFunctions');
wfLoadExtension('WikiEditor');

$wgArticlePath = "/wiki/$1";


