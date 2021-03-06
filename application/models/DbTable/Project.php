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
class Application_Model_DbTable_Project extends Local_Model_Table
{

    const PROJECT_TYPE_PERSONAL = 0;
    const PROJECT_TYPE_STANDARD = 1;
    const PROJECT_TYPE_UPDATE = 2;
    const PROJECT_FAULTY = 0;       // project data contains errors
    const PROJECT_INCOMPLETE = 10;  // process for adding the product was not successfully completed
    const PROJECT_ILLEGAL = 20;     // project data is complete, but the project doesn't accord to our rules
    const PROJECT_DELETED = 30;     // owner or staff deleted the product
    const PROJECT_INACTIVE = 40;    // project is not visible to the world, but for the owner and staff
    const PROJECT_ACTIVE = 100;     // project is active and visible to the world
    const PROJECT_CLAIMED = 1;
    const PROJECT_CLAIMABLE = 1;
    const PROJECT_DEFAULT = null;
    const MYSQL_DATE_FORMAT = "Y-m-d H:i:s";
    const PROJECT_SPAM_CHECKED = 1;
    const PROJECT_SPAM_UNCHECKED = 0;

    protected $_keyColumnsForRow = array('project_id');
    protected $_key = 'project_id';
    protected $_name = "project";
    protected $_rowClass = 'Application_Model_DbRow_Project';

    protected $_referenceMap = array(
        'Owner'       => array(
            'columns'       => 'member_id',
            'refTableClass' => 'Application_Model_DbTable_Member',
            'refColumns'    => 'member_id'
        ),
        'Category'    => array(
            'columns'       => 'project_category_id',
            'refTableClass' => 'Application_Model_DbTable_ProjectCategory',
            'refColumns'    => 'project_category_id'
        ),
        'MainProject' => array(
            'columns'       => 'project_id',
            'refTableClass' => 'Application_Model_Member',
            'refColumns'    => 'main_project_id'
        )
    );

    protected $_types = array(
        'person'     => self::PROJECT_TYPE_PERSONAL,
        'collection' => self::PROJECT_TYPE_STANDARD,
        'item'       => self::PROJECT_TYPE_UPDATE
    );

    protected $_allowedStatusTypes = array(
        self::PROJECT_FAULTY,
        self::PROJECT_INCOMPLETE,
        self::PROJECT_ILLEGAL,
        self::PROJECT_INACTIVE,
        self::PROJECT_ACTIVE,
        self::PROJECT_DELETED
    );

    /**
     * Override the insert method.
     *
     * @see Zend_Db_Table_Abstract::insert()
     *
     * @param array $data
     *
     * @return mixed
     */
    public function insert(array $data)
    {
        //Insert
        if (!isset($data['description'])) {
            $data['description'] = null;
        }

        if (!isset($data['title'])) {
            $data['title'] = null;
        }

        if (!isset($data['image_small'])) {
            $data['image_small'] = null;
        }

        if (!isset($data['project_category_id'])) {
            if ($data['type_id'] == 2) {
                // Find parent...
                $parent = $this->getParent($data['pid']);
                $data['project_category_id'] = $parent['project_category_id'];
            }
        }

        return parent::insert($data);
    }

    public function getParent($pid)
    {
        $parent = $this->select()->where('project_id = ?', $pid)->query()->fetchAll();
        if (!empty($parent)) {
            return $parent[0];
        } else {
            return false;
        }
    }

    public function setSpamChecked($projectId, $spamChecked = 1)
    {
        $sql = "update {$this->_name} set spam_checked = :spam_checked where project_id = :project_id";
        $this->_db->query($sql, array('spam_checked' => $spamChecked, 'project_id' => $projectId))->execute();
    }

    /**
     * @param array $affectedRows
     *
     * @return bool
     */
    public function deleteLikes($affectedRows)
    {
        if (false === is_array($affectedRows) OR (count($affectedRows) == 0)) {
            return false;
        }

        foreach ($affectedRows as $affected_row) {
            $projectData = $this->fetchRow(array('project_id = ?' => $affected_row['project_id']));
            if ($affected_row['user_like']) {
                $projectData->count_likes -= 1;
            }
            if ($affected_row['user_dislike']) {
                $projectData->count_dislikes -= 1;
            }
            $projectData->save();
        }

        return true;
    }

}