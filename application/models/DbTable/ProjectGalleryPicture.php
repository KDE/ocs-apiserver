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
class Application_Model_DbTable_ProjectGalleryPicture extends Zend_Db_Table_Abstract
{

    protected $_name = "project_gallery_picture";

    public function getGalleryPicturesForProject($projectId)
    {
        $statement = $this->select()
            ->where('project_id=?', $projectId);

        return $this->fetchAll($statement);
    }

    public function clean($projectId)
    {
        $where = $this->getAdapter()->quoteInto("project_id = ?", $projectId);
        $this->delete($where);
    }

    public function insertAll($projectId, $sources)
    {
        $adapter = $this->getAdapter();
        $stmt = $adapter->prepare('INSERT INTO `' . $this->_name . '` (`project_id`, `sequence`, `picture_src`) VALUES (?, ?, ?)');

        $sequenceNr = 1;
        foreach ($sources as $src) {
            if (!isset($src)) {
                continue;
            }
            $stmt->execute(array($projectId, $sequenceNr, $src));
            $sequenceNr++;
        }
    }
}