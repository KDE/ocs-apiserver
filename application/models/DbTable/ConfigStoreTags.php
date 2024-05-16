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

class Application_Model_DbTable_ConfigStoreTags extends Local_Model_Table
{

    protected $_name = "config_store_tag";

    protected $_keyColumnsForRow = array('config_store_tag_id');

    protected $_key = 'config_store_tag_id';

    public function delete($where) {
        $where = parent::_whereExpr($where);

        /**
         * Build the DELETE statement
         */
        $sql = "UPDATE " . parent::getAdapter()->quoteIdentifier($this->_name,
                                                                 true) . " SET `is_active` = 0, `deleted_at` = NOW() " . (($where) ? " WHERE $where" : '');

        /**
         * Execute the statement and return the number of affected rows
         */
        $stmt = parent::getAdapter()->query($sql);
        $result = $stmt->rowCount();

        return $result;
    }

} 