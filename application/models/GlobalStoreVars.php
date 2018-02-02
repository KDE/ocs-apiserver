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
 *
 * Created: 08.12.2017
 */

class Application_Model_GlobalStoreVars
{

    /**
     * @param $storeHostName
     *
     * @return array
     * @throws Zend_Exception
     */
    public static function getStoreConfig($storeHostName)
    {
        $storeConfig = array();

        $storeConfigArray = Zend_Registry::get('application_store_config_list');

        if (isset($storeConfigArray[$storeHostName])) {
            $storeConfig = $storeConfigArray[$storeHostName];
        } else {
            Zend_Registry::get('logger')->warn(__METHOD__ . '(' . __LINE__ . ') - ' . $storeHostName
                . ' :: no domain config context configured')
            ;
        }

        return $storeConfig;
    }

}