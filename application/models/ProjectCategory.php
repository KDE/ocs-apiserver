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
class Application_Model_ProjectCategory
{
    const CACHE_TREE_STORE = 'store_cat_tree';

    /** @var string */
    protected $_dataTableName;
    /** @var  Application_Model_DbTable_ProjectCategory */
    protected $_dataTable;

    /**
     * PHP 5 allows developers to declare constructor methods for classes.
     * Classes which have a constructor method call this method on each newly-created object,
     * so it is suitable for any initialization that the object may need before it is used.
     *
     * Note: Parent constructors are not called implicitly if the child class defines a constructor.
     * In order to run a parent constructor, a call to parent::__construct() within the child constructor is required.
     *
     * param [ mixed $args [, $... ]]
     *
     * @param string $_dataTableName
     *
     * @link http://php.net/manual/en/language.oop5.decon.php
     */
    public function __construct($_dataTableName = 'Application_Model_DbTable_ProjectCategory')
    {
        $this->_dataTableName = $_dataTableName;
        $this->_dataTable = new $this->_dataTableName;
    }

    private function buildTree($list, $parent_id = null, $store_id = null)
    {
        if (false === is_array($list)) {
            $list = array($list);
        }
        $modelCategories = new Application_Model_DbTable_ProjectCategory();
        $result = array();
        foreach ($list as $cat_id) {
            $currentCategory = $modelCategories->fetchElement($cat_id);

            $result_element = array(
                'id'            => $cat_id,
                'title'         => $currentCategory['title'],
                'xdg_type'      => $currentCategory['xdg_type'],
                'name_legacy'   => $currentCategory['name_legacy'],
                'has_children'  => false
            );

            if (isset($parent_id)) {
                $result_element['parent_id'] = $parent_id;
            }

            //has children?
            if (($currentCategory['rgt'] - $currentCategory['lft']) > 1) {
                $result_element['has_children'] = true;
                $ids = $modelCategories->fetchImmediateChildrenIds($currentCategory['project_category_id'],
                    $modelCategories::ORDERED_TITLE);
                $result_element['children'] = $this->buildTree($ids, $currentCategory['project_category_id'], $store_id);
            }
            $result[] = $result_element;
        }

        return $result;
    }

    public function fetchCategoryTreeCurrentStore($clearCache = false)
    {
        $store_config = Zend_Registry::get('store_config');
        $store_id = $store_config['store_id'];

        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cache_id = self::CACHE_TREE_STORE . "_{$store_id}";

        if ($clearCache) {
            $cache->remove($cache_id);
        }

        if (false === ($tree = $cache->load($cache_id))) {
            $list_cat_id = self::fetchCatIdsForCurrentStore();
            $tree = $this->buildTree($list_cat_id);
            $cache->save($tree, $cache_id, array(), 120);
        }

        return $tree;
    }

    public static function fetchCatIdsForCurrentStore()
    {
        return Zend_Registry::isRegistered('store_category_list') ? Zend_Registry::get('store_category_list') : null;
    }

}