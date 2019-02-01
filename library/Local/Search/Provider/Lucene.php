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

class Local_Search_Provider_Lucene implements Local_Search_ProviderInterface
{

    /** @var  Zend_Search_Lucene */
    protected $_index;
    /** @var Zend_Config */
    protected $config;
    /** @var Zend_Log|Zend_Log_Writer_Abstract */
    protected $logger;

    /**
     * @param array|Zend_config $config
     * @param Zend_Log_Writer_Abstract $logger
     * @throws Exception
     */
    function __construct($config, $logger)
    {
        
    }

    /**
     * @throws Zend_Db_Table_Row_Exception
     * @deprecated
     */
    public function createIndex()
    {
    }

    /**
     * @param $storeId
     * @param $searchIndexId
     * @deprecated
     */
    public function createStoreSearchIndex($storeId, $searchIndexId)
    {
        
    }


    /**
     * @param array $element
     * @return Zend_Search_Lucene_Document
     */
    protected function createIndexDocument($element)
    {
        $doc = new Zend_Search_Lucene_Document();
        return $doc;
    }

}