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
class Application_Model_Member extends Application_Model_DbTable_Member
{

    

    /**
     * @param $data
     *
     * @return Zend_Db_Table_Rowset
     */
    protected function generateRowSet($data)
    {
        $classRowSet = $this->getRowsetClass();

        $returnRowSet = new $classRowSet(array(
            'table'    => $this,
            'rowClass' => $this->getRowClass(),
            'stored'   => true,
            'data'     => $data
        ));

        return $returnRowSet;
    }


    /**
     * @param int $member_id
     *
     * @return Zend_Db_Table_Row
     */
    public function fetchMemberData($member_id)
    {
        if (null === $member_id) {
            return null;
        }

        $sql = '
                SELECT 
                    `member`.*
                FROM
                    `member`
                WHERE
                    (member_id = :memberId) AND (is_deleted = :deletedVal)
        ';

        $result =
            $this->getAdapter()->query($sql, array('memberId' => $member_id, 'deletedVal' => self::MEMBER_NOT_DELETED))
                 ->fetch()
        ;

        $classRow = $this->getRowClass();

        return new $classRow(array('table' => $this, 'stored' => true, 'data' => $result));
    }


    /**
     * Finds an active user by given username or email ($identity)
     *
     * @param string $identity could be the username or users mail address
     * @param bool   $withLoginLocal
     *
     * @return Zend_Db_Table_Row_Abstract
     */
    public function findActiveMemberByIdentity($identity, $withLoginLocal = false)
    {
        $sqlName = "SELECT * FROM member WHERE is_active = :active AND is_deleted = :deleted AND username = :identity";
        $sqlMail = "SELECT * FROM member WHERE is_active = :active AND is_deleted = :deleted AND mail = :identity";
        if ($withLoginLocal) {
            $sqlName .= " AND login_method = '" . self::MEMBER_LOGIN_LOCAL . "'";
            $sqlMail .= " AND login_method = '" . self::MEMBER_LOGIN_LOCAL . "'";
        }
        $resultName = $this->getAdapter()->fetchRow($sqlName,
            array('active' => self::MEMBER_ACTIVE, 'deleted' => self::MEMBER_NOT_DELETED, 'identity' => $identity))
        ;
        $resultMail = $this->getAdapter()->fetchRow($sqlMail,
            array('active' => self::MEMBER_ACTIVE, 'deleted' => self::MEMBER_NOT_DELETED, 'identity' => $identity))
        ;

        if ((false !== $resultName) AND (count($resultName) > 0)) {
            return $this->generateRowClass($resultName);
        }
        if ((false !== $resultMail) AND (count($resultMail) > 0)) {
            return $this->generateRowClass($resultMail);
        }

        return $this->createRow();
    }

    /**
     * @param Zend_Db_Table_Row_Abstract $memberData
     *
     * @return bool
     */
    public function isHiveUser($memberData)
    {
        if (empty($memberData)) {
            return false;
        }
        if ($memberData->source_id == self::SOURCE_HIVE) {
            return true;
        }

        return false;
    }
}
