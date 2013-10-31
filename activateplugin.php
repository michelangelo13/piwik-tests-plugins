<?php

if (empty($argv[1])) {
    echo "No plugin name specified.\nTry 'activateplugin.php {PluginName}'\n";
    exit(1);
}

$pluginName = $argv[1];

define('PIWIK_DOCUMENT_ROOT', dirname(__FILE__) == '/' ? '' : dirname(__FILE__));
define('PIWIK_INCLUDE_PATH', PIWIK_DOCUMENT_ROOT);
define('PIWIK_USER_PATH', PIWIK_DOCUMENT_ROOT);

require_once PIWIK_DOCUMENT_ROOT . '/vendor/autoload.php';
require_once PIWIK_DOCUMENT_ROOT . '/core/Loader.php';
require_once PIWIK_INCLUDE_PATH . '/libs/upgradephp/upgrade.php';

use \Piwik\Config;
use \Piwik\Filesystem;

$plugins = Config::getInstance()->Plugins['Plugins'];
if (!in_array($pluginName, $plugins)) {
    $plugins[] = $pluginName;
    $section = Config::getInstance()->Plugins;
    $section['Plugins'] = $plugins;
    Config::getInstance()->Plugins = $section;
}

Config::getInstance()->forceSave();
Filesystem::deleteAllCacheOnUpdate();
