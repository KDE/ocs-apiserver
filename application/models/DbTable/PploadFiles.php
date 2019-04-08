<?php

/**
 *  ocs-webserver
 *
 *  Copyright 2016 by pling GmbH.
 *
 *    This file is part of ocs-webserver.
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
class Application_Model_DbTable_PploadFiles extends Local_Model_Table
{
    /** @var  Zend_Cache_Core */
    protected $cache; 
    
    protected $_name = "ppload_files";

    protected $_keyColumnsForRow = array('id');

    protected $_key = 'id';

    


    /**
     * @inheritDoc
     */
    public function init()
    {
        parent::init(); // TODO: Change the autogenerated stub
        $this->cache = Zend_Registry::get('cache');
    }
    
    
    /**
     * @param int $projectId Description   
     * @return array
     */
    public function fetchFilesForProject($collection_id)
    {

        if(empty($collection_id)) {
            return null;
        }
        
        $sql = " select * 
                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id     
                     order by f.created_timestamp desc               
                   ";        
        /*
        $sql = " select * 
                     ,
                     (select tag.tag_fullname from tag_object, tag where tag_type_id = 3 and tag_group_id = 8 and tag_object.tag_id = tag.tag_id and tag_object.is_deleted = 0
                     and tag_object_id = f.id ) packagename
                    ,
                    (select tag.tag_fullname from tag_object, tag where tag_type_id = 3 and tag_group_id = 9 and tag_object.tag_id = tag.tag_id and tag_object.is_deleted = 0
                    and tag_object_id = f.id ) archname

                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id     
                     order by f.created_timestamp desc               
                   ";        
         * 
         */
        $result = $this->_db->query($sql,array('collection_id' => $collection_id))->fetchAll();      
        return $result;
    }        

    public function fetchFilesCntForProject($collection_id)
    {

        if(empty($collection_id)) {
            return 0;
        }
        
        $sql = " select  count(1) as cnt
                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id and f.active = 1                  
                   ";        
        $result = $this->_db->query($sql,array('collection_id' => $collection_id))->fetchAll();      
        return $result[0]['cnt'];
    }     
    
    
    public function fetchCountDownloadsTodayForProject($collection_id)
    {
        if(empty($collection_id)) {
            return 0;
        }
        
        $today = (new DateTime())->modify('-1 day');
        $filterDownloadToday = $today->format("Y-m-d H:i:s");

        $sql = "    SELECT COUNT(1) AS cnt
                    FROM ppload.ppload_files_downloaded f
                    WHERE f.collection_id = " . $collection_id . " 
                    AND f.downloaded_timestamp >= '" . $filterDownloadToday . "'               
                   ";        
        $result = $this->_db->query($sql)->fetchAll();      
        return $result[0]['cnt'];
    }     

    
    private function fetchAllFiles($collection_id, $ignore_status = true, $activeFiles = false)
    {
        
        if(empty($collection_id)) {
            return null;
        }

        $sql = "    select  *
                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id 
                   ";        
        if($ignore_status == FALSE && $activeFiles == TRUE) {
           $sql .= " and f.active = 1";
        }
        if($ignore_status == FALSE && $activeFiles == FALSE) {
           $sql .= " and f.active = 0";
        }
        $result = $this->_db->query($sql,array('collection_id' => $collection_id, ))->fetchAll();      
        return $result;
    }
    
    public function fetchAllFilesForProject($collection_id)
    {
        return $this->fetchAllFiles($collection_id, true);
    }   
    
    public function fetchAllActiveFilesForProject($collection_id)
    {
        return $this->fetchAllFiles($collection_id, false, true);
    }   

    public function fetchAllInactiveFilesForProject($collection_id)
    {
        return $this->fetchAllFiles($collection_id, false, false);
    }  
    
    public function fetchAllActiveFilesForFileInfo($collection_id, $fileIds = null) {
        
        if(empty($collection_id)) {
            return null;
        }

        $sql = "    select  *
                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id 
                     and f.active = 1
                   ";        
        if(null != $fileIds && count($fileIds) > 0) {
           //$sql .= " and f.id in (".$fileIds.")";
        }
        $result = $this->_db->query($sql,array('collection_id' => $collection_id, ))->fetchAll();      
        return $result;
        
    }
    
    public function getFilesTest(array $params = null)
    {
        
        $collection_id = null;
        if(!empty($params['collection_id'])) {
            $collection_id = $params['collection_id'];
        }
        
        $ocs_compatibility = null;
        if(!empty($params['ocs_compatibility'])) {
            $ocs_compatibility = $params['ocs_compatibility'] == 'compatible';
        }
        
        if(empty($collection_id)) {
            return null;
        }

        $sql = "    SELECT  f.*,
                    (
                     select GROUP_CONCAT(ta.tag_name) AS file_tags FROM tag_object t 
                     LEFT JOIN tag ta ON ta.tag_id = t.tag_id AND ta.is_active = 1
                     WHERE t.tag_type_id = 3 AND t.tag_object_id = f.id AND t.is_deleted = 0

                    ) AS file_tags

                    from ppload.ppload_files f 
                    where 1=1
                   ";      
        
        if($collection_id) {
            $sql .= " and f.collection_id = ".$collection_id;
        }
        if($ocs_compatibility && $ocs_compatibility == true) {
            $sql .= " and f.ocs_compatible = 1";
        }
        
        $result = $this->_db->query($sql)->fetchAll();      
        return $result;
        
        return $this->_request('GET', 'files/index', $params);
    }
    
    
    public function getFiles($originId = null, $status = 'active', $clientId = null, $ownerId = null, $collectionId = null, $collectionStatus = 'active', $collectionCategory = null, $collectionTags = null, $collectionContentId = null, $types = null, $category = null, $tags = null, $ocsCompatibility = 'all', $contentId = null, $search = null, $ids = null, array $favoriteIds = null, $downloadedTimeperiodBegin = null, $downloadedTimeperiodEnd = null, $sort = 'name', $perpage = 20, $page = 1)
    {
        $prefix = 'ppload_';
        $name = 'ppload.files';
        $columns = $this->getColumns();

        $statementOption = '';
        $where = array();
        $values = array();
        $order = "{$prefix}files.name ASC";
        $offset = 0;

        if ($originId) {
            $where[] = "{$prefix}files.origin_id = :origin_id";
            $values[':origin_id'] = $originId;
        }
        if ($status != 'all') {
            $active = 1;
            if ($status == 'inactive') {
                $active = 0;
            }
            $where[] = "{$prefix}files.active = :active";
            $values[':active'] = $active;
        }
        if ($clientId) {
            $where[] = "{$prefix}files.client_id = :client_id";
            $values[':client_id'] = $clientId;
        }
        if ($ownerId) {
            $where[] = "{$prefix}files.owner_id = :owner_id";
            $values[':owner_id'] = $ownerId;
        }
        if ($collectionId) {
            $where[] = "{$prefix}files.collection_id = :collection_id";
            $values[':collection_id'] = $collectionId;
        }
        if ($collectionStatus != 'all') {
            $collectionActive = 1;
            if ($collectionStatus == 'inactive') {
                $collectionActive = 0;
            }
            $where[] = "{$prefix}collections.active = :collection_active";
            $values[':collection_active'] = $collectionActive;
        }
        if ($collectionCategory !== null && $collectionCategory !== '') {
            $where[] = "{$prefix}collections.category = :collection_category";
            $values[':collection_category'] = $collectionCategory;
        }
        if ($collectionTags !== null && $collectionTags !== '') {
            foreach (explode(',', $collectionTags) as $tag) {
                $tag = trim($tag);
                if ($tag) {
                    $where[] = "({$prefix}collections.tags = " . $this->getDb()->quote($tag)
                        . " OR {$prefix}collections.tags LIKE " . $this->getDb()->quote("$tag,%")
                        . " OR {$prefix}collections.tags LIKE " . $this->getDb()->quote("%,$tag,%")
                        . " OR {$prefix}collections.tags LIKE " . $this->getDb()->quote("%,$tag") . ')';
                }
            }
        }
        if ($collectionContentId !== null && $collectionContentId !== '') {
            $where[] = "{$prefix}collections.content_id = :collection_content_id";
            $values[':collection_content_id'] = $collectionContentId;
        }
        if ($types) {
            $_types = array();
            foreach (explode(',', $types) as $type) {
                $type = trim($type);
                if ($type) {
                    $_types[] = $this->getDb()->quote($type);
                }
            }
            if ($_types) {
                $where[] = "{$prefix}files.type IN (" . implode(',', $_types) . ')';
            }
        }
        if ($category !== null && $category !== '') {
            $where[] = "{$prefix}files.category = :category";
            $values[':category'] = $category;
        }
        if ($tags !== null && $tags !== '') {
            foreach (explode(',', $tags) as $tag) {
                $tag = trim($tag);
                if ($tag) {
                    $where[] = "({$prefix}files.tags = " . $this->getDb()->quote($tag)
                        . " OR {$prefix}files.tags LIKE " . $this->getDb()->quote("$tag,%")
                        . " OR {$prefix}files.tags LIKE " . $this->getDb()->quote("%,$tag,%")
                        . " OR {$prefix}files.tags LIKE " . $this->getDb()->quote("%,$tag") . ')';
                }
            }
        }
        if ($ocsCompatibility != 'all') {
            $ocsCompatible = null;
            if ($ocsCompatibility == 'compatible') {
                $ocsCompatible = 1;
            }
            else if ($ocsCompatibility == 'incompatible') {
                $ocsCompatible = 0;
            }
            if ($ocsCompatible !== null) {
                $where[] = "{$prefix}files.ocs_compatible = :ocs_compatible";
                $values[':ocs_compatible'] = $ocsCompatible;
            }
        }
        if ($contentId !== null && $contentId !== '') {
            $where[] = "{$prefix}files.content_id = :content_id";
            $values[':content_id'] = $contentId;
        }
        if ($search) {
            $isSearchable = false;
            foreach (explode(' ', $search) as $keyword) {
                if ($keyword && strlen($keyword) > 2) {
                    $keyword = $this->getDb()->quote("%$keyword%");
                    $where[] = "({$prefix}files.name LIKE $keyword"
                        . " OR {$prefix}files.title LIKE $keyword"
                        . " OR {$prefix}files.description LIKE $keyword)";
                    $isSearchable = true;
                }
            }
            if (!$isSearchable) {
                return null;
            }
        }
        if ($ids) {
            $_ids = array();
            foreach (explode(',', $ids) as $id) {
                $id = trim($id);
                if ($id) {
                    $_ids[] = $this->getDb()->quote($id);
                }
            }
            if ($_ids) {
                $where[] = "{$prefix}files.id IN (" . implode(',', $_ids) . ')';
            }
        }
        if (!empty($favoriteIds['ownerIds'])
            || !empty($favoriteIds['collectionIds'])
            || !empty($favoriteIds['fileIds'])
        ) {
            $where[] = $this->_convertFavoriteIdsToStatement(
                $favoriteIds,
                array(
                    'ownerId' => "{$prefix}files.owner_id",
                    'collectionId' => "{$prefix}files.collection_id",
                    'fileId' => "{$prefix}files.id"
                )
            );
        }

        if ($where) {
            $statementOption = 'WHERE ' . implode(' AND ', $where);
        }

        if ($sort == 'newest') {
            $order = "{$prefix}files.id DESC";
        }
        else if ($sort == 'recent') {
            $order = "{$prefix}files.downloaded_timestamp DESC";
        }
        else if ($sort == 'frequent') {
            $order = "{$prefix}files.downloaded_count DESC";
        }

        if ($page > 1) {
            $offset = ($page - 1) * $perpage;
        }

        $files = null;
        $pagination = null;

        if ($downloadedTimeperiodBegin || $downloadedTimeperiodEnd) {
            $_downloadedTimeperiodBegin = $this->_getTimestamp(0);
            if ($downloadedTimeperiodBegin) {
                $_downloadedTimeperiodBegin = $downloadedTimeperiodBegin;
            }
            $_downloadedTimeperiodBegin = $this->getDb()->quote($_downloadedTimeperiodBegin);

            $_downloadedTimeperiodEnd = $this->_getTimestamp();
            if ($downloadedTimeperiodEnd) {
                $_downloadedTimeperiodEnd = $downloadedTimeperiodEnd;
            }
            $_downloadedTimeperiodEnd = $this->getDb()->quote($_downloadedTimeperiodEnd);

            $_from = '('
                . " SELECT {$prefix}files_downloaded.file_id AS file_id,"
                . " COUNT({$prefix}files_downloaded.file_id) AS count"
                . " FROM {$prefix}files_downloaded"
                . " WHERE {$prefix}files_downloaded.downloaded_timestamp"
                . " BETWEEN {$_downloadedTimeperiodBegin} AND {$_downloadedTimeperiodEnd}"
                . " GROUP BY {$prefix}files_downloaded.file_id"
                . ') AS downloaded_timeperiod';

            $_join = "LEFT OUTER JOIN {$prefix}files"
                . " ON {$prefix}files.id = downloaded_timeperiod.file_id"
                . ' ' . $this->_join;

            $_columns = str_replace(
                "{$prefix}files.downloaded_count AS downloaded_timeperiod_count",
                'downloaded_timeperiod.count AS downloaded_timeperiod_count',
                $this->_columns
            );

            if ($sort == 'frequent') {
                $order = 'downloaded_timeperiod.count DESC';
            }

            $this->setPrefix('');
            $this->setName($_from);
            $this->setColumns($_columns);

            $files = $this->fetchRowset(
                $_join . ' ' . $statementOption
                . " ORDER BY $order LIMIT $perpage OFFSET $offset",
                $values
            );

            $this->setPrefix($prefix);
            $this->setName($name);
            $this->setColumns($columns);

            if (!$files) {
                return null;
            }

            $this->setPrefix('');
            $this->setName($_from);
            $this->setColumns($_columns);

            $pagination = Flooer_Utility_Pagination::paginate(
                $this->count($_join . ' ' . $statementOption, $values),
                $perpage,
                $page
            );

            $this->setPrefix($prefix);
            $this->setName($name);
            $this->setColumns($columns);
        }
        else {
            $this->setColumns($this->_columns);
            $files = $this->fetchRowset(
                $this->_join . ' ' . $statementOption
                . " ORDER BY $order LIMIT $perpage OFFSET $offset",
                $values
            );
            $this->setColumns($columns);

            if (!$files) {
                return null;
            }

            $this->setColumns($this->_columns);
            $pagination = Flooer_Utility_Pagination::paginate(
                $this->count($this->_join . ' ' . $statementOption, $values),
                $perpage,
                $page
            );
            $this->setColumns($columns);
        }

        return array(
            'files' => $files,
            'pagination' => $pagination
        );
    }

    public function getFile($id)
    {
        $prefix = $this->getPrefix();
        $columns = $this->getColumns();

        $this->setColumns($this->_columns);
        $file = $this->fetchRow(
            $this->_join
            . " WHERE {$prefix}files.id = :id"
            . ' LIMIT 1',
            array(':id' => $id)
        );
        $this->setColumns($columns);

        if ($file) {
            return $file;
        }
        return null;
    }
}