<?php

#  Local configuration for MediaWiki

ini_set( 'max_execution_time', 1000 );
ini_set('memory_limit', '-1'); 

$wgEnableUploads = true;

require_once "$IP/extensions/ParserFunctions/ParserFunctions.php";
require_once "$IP/extensions/PdfHandler/PdfHandler.php";
require_once "$IP/extensions/WikiEditor/WikiEditor.php";

$wgArticlePath = "/wiki/$1";

#Editor
$wgDefaultUserOptions['usebetatoolbar'] = 1;
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;



