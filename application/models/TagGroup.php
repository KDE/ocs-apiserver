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

class Application_Model_TagGroup
{

    /**
     * @inheritDoc
     */
    public function __construct() {}

    public function fetchGroupHierarchy() {
        $sql = "
            SELECT `tag_group`.`group_name`, `tag`.`tag_id`, `tag`.`tag_name`
            FROM `tag_group_item`
            JOIN `tag_group` ON `tag_group`.`group_id` = `tag_group_item`.`tag_group_id`
            JOIN `tag` ON `tag`.`tag_id` = `tag_group_item`.`tag_id`
        ";
        $resultSet = $this->getAdapter()->fetchAll($sql);
        $optgroup = array();
        foreach ($resultSet as $item) {
            $optgroup[$item['group_name']][$item['tag_id']] = $item['tag_name'];
        }

        return $optgroup;
    }

    /**
     * @return Zend_Db_Adapter_Abstract
     */
    private function getAdapter() {
        return Zend_Db_Table::getDefaultAdapter();
    }

    /**
     * @param int $group_id
     *
     * @return array
     */
    public function fetchGroupItems($group_id) {
        $sql = "SELECT tag_group_item.tag_group_item_id, tag_group_item.tag_group_id, tag.tag_id, tag.tag_name 
             FROM tag_group_item 
             JOIN tag ON tag.tag_id = tag_group_item.tag_id 
             WHERE tag_group_id = :group_id";
        $resultSet = $this->getAdapter()->fetchAll($sql, array('group_id' => $group_id));

        return $resultSet;
    }

    /**
     * @param int    $group_id
     * @param string $tag_name
     *
     * @return array
     */
    public function assignGroupTag($group_id, $tag_name) {
        $tag_id = $this->saveTag($tag_name);
        $group_tag_id = $this->saveGroupTag($group_id, $tag_id);
        $resultSet = $this->fetchOneGroupItem($group_tag_id);

        return $resultSet;
    }

    /**
     * @param string $tag_name
     *
     * @return int
     */
    public function saveTag($tag_name) {
        $sql = "SELECT tag_id FROM tag WHERE tag_name = :tagName";
        $resultSet = $this->getAdapter()->fetchRow($sql, array('tagName' => $tag_name));
        if (empty($resultSet)) {
            $this->getAdapter()->insert('tag', array('tag_name' => $tag_name));
            $resultId = $this->getAdapter()->lastInsertId();
        } else {
            $resultId = $resultSet['tag_id'];
        }

        return $resultId;
    }

    /**
     * @param int $group_id
     * @param int $tag_id
     *
     * @return int
     */
    public function saveGroupTag($group_id, $tag_id) {
        $sql = "SELECT tag_group_item_id FROM tag_group_item WHERE tag_group_id = :group_id AND tag_id = :tag_id";
        $resultSet = $this->getAdapter()->fetchRow($sql, array('group_id' => $group_id, 'tag_id' => $tag_id));
        if (empty($resultSet)) {
            $this->getAdapter()->insert('tag_group_item', array('tag_group_id' => $group_id, 'tag_id' => $tag_id));
            $resultId = $this->getAdapter()->lastInsertId();
        } else {
            $resultId = $resultSet['tag_group_item_id'];
        }

        return $resultId;
    }

    /**
     * @param int $group_item_id
     *
     * @return array|false
     */
    public function fetchOneGroupItem($group_item_id) {
        $sql = "SELECT `tag_group_item`.`tag_group_item_id`, `tag_group_item`.`tag_group_id`, `tag`.`tag_id`, `tag`.`tag_name` 
             FROM `tag_group_item` 
             JOIN `tag` ON `tag`.`tag_id` = `tag_group_item`.`tag_id` 
             WHERE `tag_group_item_id` = :group_item_id";
        $resultSet = $this->getAdapter()->fetchRow($sql, array('group_item_id' => $group_item_id));

        return $resultSet;
    }

    public function updateGroupTag($tag_id, $tag_name) {
        $this->getAdapter()->update('tag', array('tag_name' => $tag_name), array('tag_id = ?' => $tag_id));
    }

    public function deleteGroupTag($groupItemId) {
        $this->getAdapter()->delete('tag_group_item', array('tag_group_item_id = ?' => $groupItemId));
    }

}