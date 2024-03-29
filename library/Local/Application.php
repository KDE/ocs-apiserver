<?php

/**
 *  ocs-apiserver
 *
 *  Copyright 2016 by pling GmbH.
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
 **/
class Local_Application extends Zend_Application
{
    const CACHE_APP_INI = 'cache_api_ini';

    /**
     *
     * @var Zend_Cache_Core|null
     */
    protected $_configCache;

    /**
     * Constructor
     *
     * Initialize application. Potentially initializes include_paths, PHP
     * settings, and bootstrap class.
     *
     * @param string                   $environment
     * @param string|array|Zend_Config $options String path to configuration file, or array/Zend_Config of
     *                                          configuration options
     *
     * @throws Zend_Application_Exception
     * @throws Zend_Cache_Exception
     */
    public function __construct($environment, $options = null)
    {
        $this->_configCache = $this->_initCache();
        parent::__construct($environment, $options);
    }

    /**
     * @throws Zend_Cache_Exception
     */
    protected function _initCache()
    {
        $frontendOptions = array('lifetime'                => null,
                                 'automatic_serialization' => true);

        $backendOptions = array('cache_dir'              => APPLICATION_CACHE,
                                'file_locking'           => true,
                                'read_control'           => true,
                                'read_control_type'      => 'crc32',
                                'hashed_directory_level' => 0,
                                'hashed_directory_perm'  => 0700,
                                'file_name_prefix'       => 'ocs',
                                'cache_file_perm'        => 0700);

        return Zend_Cache::factory('Core', 'File', $frontendOptions, $backendOptions);
    }

    /**
     * @throws Zend_Cache_Exception
     */
    public function getApplicationConfig()
    {
        $cacheName = APPLICATION_ENV . '_' . self::CACHE_APP_INI;
        if (false === ($config = $this->_configCache->load($cacheName))) {
            $config = new Zend_Config($this->getOptions(), true);
            $this->_configCache->save($config, $cacheName, array(), 300);
        }

        return $config;
    }

    /**
     * Load configuration file of options
     *
     * @param string $file
     *
     * @return array
     * @throws Zend_Application_Exception When invalid configuration file is provided
     * @throws Zend_Cache_Exception
     */
    protected function _loadConfig($file)
    {
        $suffix = strtolower(pathinfo($file, PATHINFO_EXTENSION));

        if ($this->_configCache === null or $suffix == 'php' or $suffix == 'inc') { //No need for caching those
            return parent::_loadConfig($file);
        }

        $cacheId = $this->_cacheId($file);

        if (false === ($config = $this->_configCache->load($cacheId))) {
            $config = parent::_loadConfig($file);
            $this->_configCache->save($config, $cacheId, array(), null);
        }

        return $config;
    }

    protected function _cacheId($file)
    {
        return 'config_' . $this->getEnvironment() . '_' . md5_file($file);
    }

    /**
     * @param string $file
     * @param        $cacheId
     *
     * @return bool
     */
    protected function _testCache($file, $cacheId)
    {
        $configMTime = filemtime($file);

        $cacheLastMTime = $this->_configCache->test($cacheId);

        if ($cacheLastMTime !== false and $configMTime < $cacheLastMTime) { //Valid cache?
            return true;
        }

        return false;
    }

} 