<?php

# Redis configuration

$wgObjectCaches['redis'] = [
	'class' => 'RedisBagOStuff',
	'servers'=> [ 'redis:6379' ],
];
$wgMainCacheType = 'redis';
$wgSessionCacheType = 'redis';
$wgMainStash = 'redis';

$wgJobTypeConf['default'] = [
	'class' => 'JobQueueRedis',
	'redisServer' => 'redis:6379',
	'redisConfig' => [],
	'claimTTL' => 3600,
	'daemonized' => true
];
