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
 *
 *    Created: 22.10.2016
 **/
class Local_Auth_Adapter_SsoToken implements Local_Auth_Adapter_Interface
{

    protected $_identity;
    protected $_credential;
    protected $_db;
    protected $_resultRow;

    /**
     * __construct() - Sets configuration options
     *
     * @param  Zend_Db_Adapter_Abstract $dbAdapter If null, default database adapter assumed
     * @param string                    $tableName
     *
     * @throws Zend_Auth_Adapter_Exception
     */
    public function __construct(Zend_Db_Adapter_Abstract $dbAdapter = null, $tableName = null)
    {
        $this->_db = $dbAdapter;
        if (empty($this->_db)) {
            $this->_db = Zend_Db_Table_Abstract::getDefaultAdapter();
            if (empty($this->_db)) {
                throw new Zend_Auth_Adapter_Exception('No database adapter present');
            }
        }
    }

    /**
     * @param string $identity
     *
     * @return Zend_Auth_Adapter_Interface
     * @throws Zend_Exception
     */
    public function setIdentity($identity)
    {
        $this->_identity = $identity;

        return $this;
    }

    /**
     * @param string $credential
     *
     * @return Zend_Auth_Adapter_Interface
     * @throws Zend_Exception
     */
    public function setCredential($credential)
    {
        $this->_credential = $credential;

        return $this;
    }

    /**
     * Performs an authentication attempt
     *
     * @return Zend_Auth_Result
     * @throws Zend_Exception
     */
    public function authenticate()
    {
        $resultSet = $this->fetchUserData();

        if (count($resultSet) == 0) {
            return $this->createAuthResult(Zend_Auth_Result::FAILURE_IDENTITY_NOT_FOUND, $this->_identity,
                array('A record with the supplied identity could not be found.'));
        }

        if (count($resultSet) > 1) {
            return $this->createAuthResult(Zend_Auth_Result::FAILURE_IDENTITY_AMBIGUOUS, $this->_identity,
                array('More than one record matches the supplied identity.'));
        }

        $this->_resultRow = array_shift($resultSet);

        return $this->createAuthResult(Zend_Auth_Result::SUCCESS, $this->_identity, array('Authentication successful.'));
    }

    /**
     * @return array
     * @throws Zend_Exception
     */
    private function fetchUserData()
    {
        $sql = "
            SELECT `member`.*
            FROM `member`
            WHERE `member`.`is_active` = :active
            AND `member`.`is_deleted` = :deleted
            AND `member`.`login_method` = :login
            AND `member`.`member_id` = :memberId
            ";

        $this->_db->getProfiler()->setEnabled(true);
        $resultSet = $this->_db->fetchAll($sql, array(
            'active'   => Application_Model_DbTable_Member::MEMBER_ACTIVE,
            'deleted'  => Application_Model_DbTable_Member::MEMBER_NOT_DELETED,
            'login'    => Application_Model_DbTable_Member::MEMBER_LOGIN_LOCAL,
            'memberId' => $this->_identity
        ));
        Zend_Registry::get('logger')->debug(__METHOD__ . ' - sql take seconds: ' . $this->_db->getProfiler()
                                                                                             ->getLastQueryProfile()
                                                                                             ->getElapsedSecs())
        ;
        $this->_db->getProfiler()->setEnabled(false);

        return $resultSet;
    }

    /**
     * @param $code
     * @param $identity
     * @param $messages
     *
     * @return Zend_Auth_Result
     */
    protected function createAuthResult($code, $identity, $messages)
    {
        return new Zend_Auth_Result($code, $identity, $messages);
    }

    /**
     * getResultRowObject() - Returns the result row as a stdClass object
     *
     * @param  string|array $returnColumns
     * @param  string|array $omitColumns
     *
     * @return stdClass|boolean
     */
    public function getResultRowObject($returnColumns = null, $omitColumns = null)
    {
        if (!$this->_resultRow) {
            return false;
        }

        $returnObject = new stdClass();

        if (null !== $returnColumns) {

            $availableColumns = array_keys($this->_resultRow);
            foreach ((array)$returnColumns as $returnColumn) {
                if (in_array($returnColumn, $availableColumns)) {
                    $returnObject->{$returnColumn} = $this->_resultRow[$returnColumn];
                }
            }

            return $returnObject;
        } else if (null !== $omitColumns) {

            $omitColumns = (array)$omitColumns;
            foreach ($this->_resultRow as $resultColumn => $resultValue) {
                if (!in_array($resultColumn, $omitColumns)) {
                    $returnObject->{$resultColumn} = $resultValue;
                }
            }

            return $returnObject;
        } else {

            foreach ($this->_resultRow as $resultColumn => $resultValue) {
                $returnObject->{$resultColumn} = $resultValue;
            }

            return $returnObject;
        }
    }

}