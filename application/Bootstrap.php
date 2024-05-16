<?php
/**
 * open content store api - part of Opendesktop.org platform project <https://www.opendesktop.org>.
 *
 * Copyright (c) 2016-2024 pling GmbH.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    /**
     * @var Zend_Controller_Router_Rewrite
     */
    protected $_router = false;

    /**
     * @throws Zend_Exception
     * @throws Zend_Session_Exception
     */
    protected function _initSessionManagement() {
        Zend_Auth::getInstance()->setStorage(new Zend_Auth_Storage_NonPersistent());
    }

    /**
     * @return mixed
     */
    protected function _initConfig() {
        /** $config Zend_Config */
        $config = $this->getApplication()->getApplicationConfig();
        Zend_Registry::set('config', $config);

        return $config;
    }

    /**
     * @throws Zend_Application_Bootstrap_Exception
     */
    protected function _initLogger() {
        /** @var Zend_Log $logger */
        $logger = $this->getPluginResource('log')->getLog();
        $logger->registerErrorHandler();
        Zend_Registry::set('logger', $logger);
    }

    /**
     * @return mixed|null|Zend_Cache_Core|Zend_Cache_Frontend
     * @throws Zend_Cache_Exception
     * @throws Zend_Exception
     */
    protected function _initCache() {
        if (Zend_Registry::isRegistered('cache')) {
            return Zend_Registry::get('cache');
        }

        $cache = null;
        $options = $this->getOption('settings');

        if (true == $options['cache']['enabled']) {
            $cache = Zend_Cache::factory($options['cache']['frontend']['type'],
                                         $options['cache']['backend']['type'],
                                         $options['cache']['frontend']['options'],
                                         $options['cache']['backend']['options']);
        } else {
            // Fallback settings for some (maybe development) environments which have no cache management installed.

            if (false === is_writeable(APPLICATION_CACHE)) {
                error_log('directory for cache files does not exists or not writable: ' . APPLICATION_CACHE);
                exit('directory for cache files does not exists or not writable: ' . APPLICATION_CACHE);
            }

            $frontendOptions = array(
                'lifetime'                => 600,
                'automatic_serialization' => true,
                'cache_id_prefix'         => 'front_cache',
                'cache'                   => true
            );

            $backendOptions = array(
                'cache_dir'              => APPLICATION_CACHE,
                'file_locking'           => true,
                'read_control'           => true,
                'read_control_type'      => 'crc32',
                'hashed_directory_level' => 1,
                'hashed_directory_perm'  => 0700,
                'file_name_prefix'       => 'ocs',
                'cache_file_perm'        => 0700
            );

            $cache = Zend_Cache::factory('Core', 'File', $frontendOptions, $backendOptions);
        }

        Zend_Registry::set('cache', $cache);

        Zend_Locale::setCache($cache);
        Zend_Locale_Data::setCache($cache);
        Zend_Currency::setCache($cache);
        Zend_Translate::setCache($cache);
        Zend_Translate_Adapter::setCache($cache);
        Zend_Db_Table_Abstract::setDefaultMetadataCache($cache);
        Zend_Paginator::setCache($cache);

        return $cache;
    }

    /**
     * @throws Zend_Application_Bootstrap_Exception
     * @throws Zend_Exception
     */
    protected function _initDbAdapter() {
        $db = $this->bootstrap('db')->getResource('db');

        if ((APPLICATION_ENV == 'development')) {
            $profiler = new Zend_Db_Profiler_Firebug('All DB Queries');
            $profiler->setEnabled(true);

            // Attach the profiler to your db adapter
            $db->setProfiler($profiler);
        }

        Zend_Registry::set('db', $db);
        Zend_Db_Table::setDefaultAdapter($db);
        Zend_Db_Table_Abstract::setDefaultAdapter($db);


        $config = Zend_Registry::get('config');
        try {
            $db2 = Zend_Db::factory($config->settings->db2->adapter, array(
                'host'                  => $config->settings->db2->params->host,
                'username'              => $config->settings->db2->params->username,
                'password'              => $config->settings->db2->params->password,
                'dbname'                => $config->settings->db2->params->dbname,
                'charset'               => $config->settings->db2->params->charset,
                'type'                  => $config->settings->db2->params->type,
                'persistent'            => $config->settings->db2->params->persistent,
                'isDefaultTableAdapter' => FALSE
            ));

            Zend_Registry::set('db2', $db2);

            $db2->getConnection();

        } catch (Zend_Db_Adapter_Exception $e) {
            Zend_Registry::get('logger')->err('Error Init DB2: ' . $e->getTraceAsString());
        } catch (Zend_Exception $e) {
            Zend_Registry::get('logger')->err('Error Init DB2: ' . $e->getTraceAsString());
        }

    }

    protected function _initRouter() {
        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');

        $this->_router = $cache->load('ocs_api_router');

        $bootstrap = $this;
        $bootstrap->bootstrap('FrontController');
        if (false === $this->_router) {
            $this->_router = $bootstrap->getContainer()->frontcontroller->getRouter();

            $options = $this->getOptions()['resources']['router'];
            if (!isset($options['routes'])) {
                $options['routes'] = array();
            }

            if (isset($options['chainNameSeparator'])) {
                $this->_router->setChainNameSeparator($options['chainNameSeparator']);
            }

            if (isset($options['useRequestParametersAsGlobal'])) {
                $this->_router->useRequestParametersAsGlobal($options['useRequestParametersAsGlobal']);
            }

            $this->_router->addConfig(new Zend_Config($options['routes']));
            $cache->save($this->_router, 'ocs_api_router', array(), 7200);
        }

        $this->getContainer()->frontcontroller->setRouter($this->_router);

        return $this->_router;
    }

    protected function _initGlobalAppConst() {
        $appConfig = $this->getResource('config');

        $imageConfig = $appConfig->images;
        defined('IMAGES_UPLOAD_PATH') || define('IMAGES_UPLOAD_PATH', $imageConfig->upload->path);
        defined('IMAGES_MEDIA_SERVER') || define('IMAGES_MEDIA_SERVER', $imageConfig->media->server);

        // ppload
        $configFileserver = $appConfig->settings->server->files;
        defined('PPLOAD_API_URI') || define('PPLOAD_API_URI', $configFileserver->api->uri);
        defined('PPLOAD_CLIENT_ID') || define('PPLOAD_CLIENT_ID', $configFileserver->api->client_id);
        defined('PPLOAD_SECRET') || define('PPLOAD_SECRET', $configFileserver->api->client_secret);
        defined('PPLOAD_HOST') || define('PPLOAD_HOST', $configFileserver->host);
        defined('PPLOAD_DOWNLOAD_SECRET') || define('PPLOAD_DOWNLOAD_SECRET', $configFileserver->download_secret);
    }

    protected function _initGlobalApplicationVars() {
        $modelDomainConfig = new Application_Model_DbTable_ConfigStore();
        Zend_Registry::set('application_store_category_list', $modelDomainConfig->fetchAllStoresAndCategories());
        Zend_Registry::set('application_store_config_list', $modelDomainConfig->fetchAllStoresConfigArray());
        Zend_Registry::set('application_store_config_id_list', $modelDomainConfig->fetchAllStoresConfigByIdArray());
    }

    protected function _initStoreDependentVars() {
        /** @var $front Zend_Controller_Front */
        $front = $this->bootstrap('frontController')->getResource('frontController');
        $front->registerPlugin(new Application_Plugin_InitGlobalStoreVars());
    }

}

