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

class Application_Model_DbRow_Project extends Zend_Db_Table_Row_Abstract implements Local_Db_Table_Row_ValidateInterface
{
    const CATEGORY_DEFAULT_PROJECT = 0;
    const STATUS_PROJECT_ACTIVE = 10;
    const DEFAULT_AVATAR_IMAGE = 'std_avatar_80.png';
    const PERSONAL_PROJECT_TITLE = 'Personal Page';

    protected $_data = array(
        'id'               => null,
        'owner'            => null,
        'category'         => null,
        'title'            => '',
        'amount_received'  => 0,
        'collectAmount'    => 0,
        'collectPlings'    => 0,
        'collectPlingsSum' => 0,
        'description'      => '',
        'created_date'     => null,
        'changed_date'     => null,
        'deleted_date'     => null,
        'image_big'        => '',
        'image_small'      => '',
        'status'           => 0,
        'visits'           => 0,
        'facebook'         => '',
        'type_id'          => 1,
        'amount'           => null
    );

    public function getCatTitle() {
        return $this->_data['category']->title;
    }

    /**
     * @param boolean $status
     * @return mixed
     */
    public function setVerifiedStatus($status) {
        $this->validated = (int)$status;
        $this->validated_at = new Zend_Db_Expr('NOW()');
        if (false === $this->isConnected()) {
            $this->setTable(new Application_Model_DbTable_Project());
        }

        return parent::save();
    }

}

