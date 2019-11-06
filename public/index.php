<?php
/**
 *
 *   ocs-apiserver
 *
 *   Copyright 2016 by pling GmbH.
 *
 *    This file is part of ocs-apiserver.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Affero General Public License as
 *    published by the Free Software Foundation, either version 3 of the
 *    License, or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Affero General Public License for more details.
 *
 *    You should have received a copy of the GNU Affero General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

defined('APPLICATION_TIMEZONE')
|| define('APPLICATION_TIMEZONE', (getenv('APPLICATION_TIMEZONE') ? getenv('APPLICATION_TIMEZONE') : 'UTC'));

date_default_timezone_set(APPLICATION_TIMEZONE);

// Define path to application directory
defined('APPLICATION_PATH')
|| define('APPLICATION_PATH', realpath(dirname(__FILE__) . '/../application'));

// Define application environment
defined('APPLICATION_ENV')
|| define('APPLICATION_ENV', (getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : 'production'));

// Define path to application cache
defined('APPLICATION_CACHE')
|| define('APPLICATION_CACHE', realpath(dirname(__FILE__) . '/../data/cache'));

// Define path to application cache
defined('APPLICATION_DATA')
|| define('APPLICATION_DATA', realpath(dirname(__FILE__) . '/../data'));

// Define path to application library
defined('APPLICATION_LIB')
|| define('APPLICATION_LIB', realpath(dirname(__FILE__) . '/../library'));


// Ensure library/ is on include_path
set_include_path(implode(PATH_SEPARATOR, array(
    realpath(APPLICATION_PATH . '/../library'),
    get_include_path(),
)));

//require_once realpath(APPLICATION_PATH . '/../vendor/autoload.php');

// Initialising Autoloader
require APPLICATION_LIB . '/Zend/Loader/SplAutoloader.php';
require APPLICATION_LIB . '/Zend/Loader/StandardAutoloader.php';
require APPLICATION_LIB . '/Zend/Loader/AutoloaderFactory.php';
Zend_Loader_AutoloaderFactory::factory(array(
    'Zend_Loader_StandardAutoloader' => array(
        'autoregister_zf' => true,
        'namespaces'      => array(
            'Application' => APPLICATION_PATH
        )
    )
));

// Including plugin cache file
if (file_exists(APPLICATION_CACHE . DIRECTORY_SEPARATOR . 'pluginLoaderCache.php')) {
    include_once APPLICATION_CACHE . DIRECTORY_SEPARATOR . 'pluginLoaderCache.php';
}
Zend_Loader_PluginLoader::setIncludeFileCache(APPLICATION_CACHE . DIRECTORY_SEPARATOR . 'pluginLoaderCache.php');

// Set configuration
$configuration = APPLICATION_PATH . '/configs/application.ini';
// Merge an existing local configuration file (application.local.ini) with global config
if (file_exists(APPLICATION_PATH . '/configs/application.local.ini')) {
    $configuration = array(
        'config' => array(
            APPLICATION_PATH . '/configs/application.ini',
            APPLICATION_PATH . '/configs/application.local.ini'
        )
    );
}

// Init and start Zend_Application
require_once APPLICATION_LIB . '/Local/Application.php';
// Create application, bootstrap, and run
$application = new Local_Application(APPLICATION_ENV, $configuration);
$application->bootstrap();
$application->run();
