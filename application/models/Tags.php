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
 * Created: 11.09.2017
 */

class Application_Model_Tags
{
    const TAG_TYPE_PROJECT = 1;
    const TAG_TYPE_FILE = 3;

    /**
     * Application_Model_Tags constructor.
     */
    public function __construct()
    {

    }

    /**
     * @param int    $object_id
     * @param string $tags
     * @param int    $tag_type
     */
    public function processTags($object_id, $tags, $tag_type)
    {
        $this->assignTags($object_id, $tags, $tag_type);
        $this->deassignTags($object_id, $tags, $tag_type);
    }

    /**
     * @param int    $object_id
     * @param string $tags
     * @param int    $tag_type
     */
    public function assignTags($object_id, $tags, $tag_type)
    {
        $new_tags = array_diff(explode(',', $tags), explode(',', $this->getTags($object_id, $tag_type)));

        $tableTags = new Application_Model_DbTable_Tags();
        $listIds = $tableTags->storeTags(implode(',', $new_tags));

        $prepared_insert =
            array_map(function ($id) use ($object_id, $tag_type) { return "({$id}, {$tag_type}, {$object_id})"; },
                $listIds);
        $sql = "INSERT IGNORE INTO tag_object (tag_id, tag_type_id, tag_object_id) VALUES " . implode(',',
                $prepared_insert);
        $this->getAdapter()->query($sql);
    }

    /**
     * @param int $object_id
     * @param int $tag_type
     *
     * @return string|null
     */
    public function getTags($object_id, $tag_type)
    {
        $sql = "
            SELECT GROUP_CONCAT(tag.tag_name) AS tag_names 
            FROM tag_object
            JOIN tag ON tag.tag_id = tag_object.tag_id
            WHERE tag_type_id = :type AND tag_object_id = :object_id
            GROUP BY tag_object.tag_object_id
        ";

        $result = $this->getAdapter()->fetchRow($sql, array('type' => $tag_type, 'object_id' => $object_id));
        if (isset($result['tag_names'])) {
            return $result['tag_names'];
        }

        return null;
    }
    
    
    /**
     * @param int $object_id
     * @param int $tag_type
     *
     * @return string|null
     */
    public function getTagsAsArray($object_id, $tag_type)
    {
        $sql = "
            SELECT tag.tag_name
            FROM tag_object
            JOIN tag ON tag.tag_id = tag_object.tag_id
            WHERE tag_type_id = :type 
            AND tag_object_id = :object_id
            AND tag_object.is_deleted = 0
        ";

        $result = $this->getAdapter()->fetchAll($sql, array('type' => $tag_type,'object_id' => $object_id));
        $returnArray = array();
        if (isset($result)) {
            foreach ($result as $tag) {
                $returnArray[] = $tag['tag_name'];
            }
            return $returnArray;
        }

        return null;
    }
    
    /**
     * @return array|null
     */
    public function getAllFilePackageTypeTags()
    {
        $sql = "
            select t.tag_name from tag t
            join tag_group_item tgi on tgi.tag_id = t.tag_id
            join tag_group tg on tg.group_id = tgi.tag_group_id
            where tgi.tag_group_id = 8
        ";

        $result = $this->getAdapter()->fetchAll($sql);
        $returnArray = array();
        if (isset($result)) {
            foreach ($result as $tag) {
                $returnArray[] = $tag['tag_name'];
            }
            return $returnArray;
        }

        return null;
    }
    
    /**
     * @return array|null
     */
    public function getAllFileArchitectureTags()
    {
        $sql = "
            select t.tag_name from tag t
            join tag_group_item tgi on tgi.tag_id = t.tag_id
            join tag_group tg on tg.group_id = tgi.tag_group_id
            where tgi.tag_group_id = 9
        ";

        $result = $this->getAdapter()->fetchAll($sql);
        $returnArray = array();
        if (isset($result)) {
            foreach ($result as $tag) {
                $returnArray[] = $tag['tag_name'];
            }
            return $returnArray;
        }

        return null;
    }
    
    
    /**
     * @return array|null
     */
    public function getAllFilePlasmaVersionTags()
    {
        $playsmavesionTagGroup = Zend_Registry::get('config')->settings->client->default->tag_group_plasmaversion_id;
        
        $sql = "
            select t.tag_name from tag t
            join tag_group_item tgi on tgi.tag_id = t.tag_id
            join tag_group tg on tg.group_id = tgi.tag_group_id
            where tgi.tag_group_id = ".$playsmavesionTagGroup."
        ";

        $result = $this->getAdapter()->fetchAll($sql);
        $returnArray = array();
        if (isset($result)) {
            foreach ($result as $tag) {
                $returnArray[] = $tag['tag_name'];
            }
            return $returnArray;
        }

        return null;
    }
    
    
    /**
     * @return array|null
     */
    public function fetchAllFileTagNamesAsArray()
    {
        $sql = "
            select t.tag_name from tag t
            join tag_group_item tgi on tgi.tag_id = t.tag_id
            join tag_group tg on tg.group_id = tgi.tag_group_id
            where tgi.tag_group_id in (8,9)

        ";

        $result = $this->getAdapter()->fetchAll($sql);
        $returnArray = array();
        if (isset($result)) {
            foreach ($result as $tag) {
                $returnArray[] = $tag['tag_name'];
            }
            return $returnArray;
        }

        return null;
    }
    
    
    /**
     * @param int $object_id ProjectId
     * @param int $whereStatement SQl-Where-Statement
     *
     * @return string|null
     */
    public function getFilesForTags($object_id, $whereStatement)
    {
        $sql = "
            select * from stat_file_tags
            where project_id = :project_id 
        ";
        $sql .= $whereStatement;
        
        //var_dump($sql);
        
        $result = $this->getAdapter()->fetchAll($sql, array('project_id' => $object_id));
        if (isset($result)) {
            return $result;
        }

        return null;
    }
    
    
    /**
     * @param int $object_id
     * @param int $tag_type
     *
     * @return string|null
     */
    public function getTag($tag_id)
    {
        $sql = "
            SELECT *
            FROM tag
            WHERE tag_id = :tag_id
        ";

        $result = $this->getAdapter()->fetchRow($sql, array('tag_id' => $tag_id));
        if (isset($result)) {
            return $result;
        }

        return null;
    }

    /**
     * @return Zend_Db_Adapter_Abstract
     */
    private function getAdapter()
    {
        return Zend_Db_Table::getDefaultAdapter();
    }

    /**
     * @param int    $object_id
     * @param string $tags
     * @param int    $tag_type
     */
    public function deassignTags($object_id, $tags, $tag_type)
    {
        $removable_tags = array_diff(explode(',', $this->getTags($object_id, $tag_type)), explode(',', $tags));

        $sql = "DELETE tag_object FROM tag_object JOIN tag ON tag.tag_id = tag_object.tag_id WHERE tag.tag_name = :name";
        foreach ($removable_tags as $removable_tag) {
            $this->getAdapter()->query($sql, array('name' => $removable_tag));
        }
        $this->updateChanged($object_id, $tag_type);
    }

    private function updateChanged($object_id, $tag_type)
    {
        $sql = "UPDATE tag_object SET tag_changed = NOW() WHERE tag_object_id = :tagObjectId AND tag_type_id = :tagType";
        $this->getAdapter()->query($sql, array('tagObjectId' => $object_id, 'tagType' => $tag_type));
    }

}